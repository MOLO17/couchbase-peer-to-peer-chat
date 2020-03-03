//
//  ChatPeerViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 10/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity
import UIKit

class ChatPeerViewController: UIViewController {
    
    // MARK: - Private Attributes

    private let viewModel: ChatPeerViewModel
    private var keyboardManager: TextFieldsKeyboardManager!
    private let multiPeerManager = MultiPeerConnectivityManager.shared
    private let reuseIdentifier = "PeerCell"
    private let messageReuseIdentifier = "MessageCell"
    private var isFirstTime =  true
    private var didConnect: ((MCPeerID) -> Void)?
    
    private lazy var receivedData: ((Data) -> Void)? = { [weak self] data in
        
        guard let self = self else { return }
        self.activePeerManager?.didReceive(message: Message.fromData(data))
    }
    
    private var totalMessages: [ChatMessage] = [] {
        didSet {
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if !self.multiPeerManager.session.connectedPeers.isEmpty,
                    !self.tableView.visibleCells.isEmpty {
                    self.tableView.scrollToRow(at: IndexPath(row: self.totalMessages.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
    
    private lazy var tableView: UITableView = {
        
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        t.register(MessageTableViewCell.self, forCellReuseIdentifier: self.messageReuseIdentifier)
        t.rowHeight = UITableView.automaticDimension
        t.tableFooterView = UIView()
        t.separatorStyle = .none
        t.allowsSelection = false
        t.dataSource = self
        t.delegate = self
        return t
    }()
    
    private lazy var messageTextfield: UITextField = {
        
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.returnKeyType = .done
        t.leftView = UIView()
        return t
    }()
    
    private lazy var sendButton: UIButton = {
        
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        b.setTitle("Send", for: UIControl.State())
        b.backgroundColor = .systemBlue
        b.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var stackView: UIStackView = {
        
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .equalCentering
        s.addArrangedSubview(self.disconnectButton)
        return s
    }()
    
    private lazy var disconnectButton: UIButton = {
        
        let b = UIButton()
        b.setTitle("Disconnect", for: UIControl.State())
        b.setTitleColor(.systemBlue, for: UIControl.State())
        b.addTarget(self, action: #selector(disconnectButtonPressed), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        
        return b
    }()
    
    private lazy var trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapOnTrashButton))
    
    
    // MARK: - Attributes
    var activePeerManager: ActivePeerManager? {
        didSet { self.activePeerManager.flatMap(self.setupConnectionManager) }
    }
    
    private var passivePeerManager: PassivePeerManager? {
        didSet { self.passivePeerManager.flatMap(self.setupConnectionManager) }
    }
    
    // MARK: - Methods
    init(viewModel: ChatPeerViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.keyboardManager = TextFieldsKeyboardManager(viewController: self)
        self.keyboardManager.addtextFields(textField: self.messageTextfield)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.setupViews()
        self.setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        self.multiPeerManager.delegate = self
        
        self.activePeerManager = ActivePeerManager(database: self.viewModel.getDB(), target: self.multiPeerManager.session.connectedPeers)
        self.passivePeerManager = PassivePeerManager(database: self.viewModel.getDB(), target: self.multiPeerManager.session.connectedPeers)
        
        self.viewModel.update { [weak self] messages in
            DispatchQueue.main.async { self?.totalMessages = messages }
        }
        
        self.didConnect = { [weak self] peer in
            
            guard let self = self else { return }
            self.activePeerManager?.stopReplicationSync()
            self.passivePeerManager?.stopReplicationSync()
            self.activePeerManager = ActivePeerManager(database: self.viewModel.getDB(), target: self.multiPeerManager.session.connectedPeers)
            self.passivePeerManager = PassivePeerManager(database: self.viewModel.getDB(), target: self.multiPeerManager.session.connectedPeers)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.applyStyle()
    }
    
    
    // MARK: - Private Methods
    private func setupConnectionManager(peerManager: ConnectionPeerManagerProtocol) {
        
        var manager = peerManager
        manager.send = { [weak self] data in
            
            guard let self = self else { return }
            do {
                try self.multiPeerManager.session.send(data, toPeers: peerManager.target, with: .reliable)
            } catch {
                
                DispatchQueue.main.async {
                    let alert = makeInfoAlert(title: nil, message: error.localizedDescription)
                    self.navigationViewController?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func setupTableView() {
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(tableViewLongPressed))
        gesture.minimumPressDuration = 1
        gesture.delegate = self
        tableView.addGestureRecognizer(gesture)
    }
    
    private func setupViews() {
        
        self.view = UIView()
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.messageTextfield)
        self.view.addSubview(self.sendButton)
        self.view.addSubview(self.stackView)
    }
    
    private func setupConstraints() {
        
        self.tableView.edgesToSuperview(excluding: .bottom)
        self.tableView.bottomToTop(of: self.messageTextfield)
        
        self.messageTextfield.leadingToSuperview(offset: 8, usingSafeArea: true)
        self.messageTextfield.bottomToTop(of: self.stackView)
        self.messageTextfield.setCompressionResistance(.required, for: .horizontal)
        self.messageTextfield.height(to: self.sendButton, relation: .equalOrGreater)
        self.messageTextfield.widthToSuperview(multiplier: 0.75)
        
        self.sendButton.centerY(to: self.messageTextfield)
        self.sendButton.leadingToTrailing(of: self.messageTextfield)
        self.sendButton.trailingToSuperview(offset: 8)
        self.sendButton.setHugging(.required, for: .horizontal)
        self.sendButton.setCompressionResistance(.required, for: .horizontal)
        
        self.stackView.edgesToSuperview(excluding: .top, usingSafeArea: true)
    }
    
    @objc private func sendButtonTapped() {
        
        if let text = self.messageTextfield.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            if self.messageTextfield.isFirstResponder { self.messageTextfield.resignFirstResponder() }
            print("Active: \(self.activePeerManager), target: \(self.activePeerManager?.target)")
            print("Passive: \(self.passivePeerManager), target: \(self.passivePeerManager?.target)")
            self.messageTextfield.text = ""
            self.viewModel.store(message: text) { [weak self] error in
                
                if let e = error {
                    
                    DispatchQueue.main.async {
                        let alert = makeInfoAlert(title: nil, message: e.localizedDescription)
                        self?.navigationViewController?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func disconnectButtonPressed() {
        self.multiPeerManager.session.disconnect()
    }
    
    @objc private func tableViewLongPressed(gesture: UILongPressGestureRecognizer) {
        
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = true
        
        let p = gesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if gesture.state == .began {
            
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            if let iP = indexPath {
                let cell = self.tableView.cellForRow(at: iP)
                cell?.accessoryType = .checkmark
            }
            self.navigationItem.rightBarButtonItems = [self.trashButton]
        }
    }
    
    @objc private func didTapOnTrashButton() {
        
        self.tableView.beginUpdates()
        self.tableView.indexPathsForSelectedRows?.map { self.totalMessages[$0.row] }.forEach { self.viewModel.remove(message: $0) { [weak self] e in
            
            if let error = e {
                if self?.navigationViewController?.presentedViewController != nil {
                    self?.navigationViewController?.present(makeInfoAlert(title: nil, message: error.localizedDescription), animated: true)
                }
            } else {
                if self?.navigationViewController?.presentedViewController != nil {
                    self?.navigationViewController?.present(makeInfoAlert(title: nil, message: "MessageDeleted"), animated: true)
                }
            }}
        }
        self.tableView.endUpdates()
        self.navigationItem.rightBarButtonItems = []
        self.tableView.allowsSelection = false
        self.tableView.allowsMultipleSelection = false
    }
    
    private func applyStyle() {
        
        self.sendButton.layer.cornerRadius = 10
        self.sendButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        self.messageTextfield.layer.cornerRadius = 10
        self.messageTextfield.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        self.messageTextfield.layer.borderWidth = 1
        self.messageTextfield.layer.borderColor = UIColor.lightGray.cgColor
        
    }
}

protocol ChatPeerFactory {
    
    func makeChatPeerViewController(viewModel: ChatPeerViewModel) -> ChatPeerViewController
    func makeChatPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> ChatPeerViewModel
}

extension ChatPeerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.messageReuseIdentifier, for: indexPath) as? MessageTableViewCell else {
            return UITableViewCell()
        }
        let message = self.totalMessages[indexPath.row]
        cell.setupCell(layout: MessageTableViewCell.Layout(text: message.text, type: message.messageType, date: message.creationDate))
        cell.selectionStyle = .none
        return cell
    }
}

extension ChatPeerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        
        if tableView.indexPathsForSelectedRows == nil {
            self.tableView.allowsSelection = false
            self.tableView.allowsMultipleSelection = false
            self.navigationItem.rightBarButtonItems = []
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            let selectedMessage = self.totalMessages[indexPath.row]
            if editingStyle == .delete {
                
                tableView.beginUpdates()
                self.viewModel.remove(message: selectedMessage) { [weak self] e in
                    
                    if let error = e {
                        self?.navigationViewController?.present(makeInfoAlert(title: nil, message: error.localizedDescription), animated: true)
                    } else {
                        self?.navigationViewController?.present(makeInfoAlert(title: nil, message: "MessageDeleted"), animated: true)
                    }
                }
                tableView.endUpdates()
            }
        }
    }
}

extension ChatPeerViewController: MultiPeerConnectivityManagerDelegate {
    
    var didReceive: ((Data) -> Void)? {
        get { self.receivedData }
    }
    
    func didReceiveInvitation(fromPeer peer: MCPeerID, invitationHandler: @escaping ((Bool) -> Void)) {
        
        DispatchQueue.main.async {
            let alert = makeInvitationAlert(title: nil, message: "\(peer.displayName) wants to chat with you", peer: peer, handler: invitationHandler)
            self.navigationViewController?.present(alert, animated: true)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        self.didConnect?(peerID)
    }
    
    func lostPeer(id: MCPeerID) {
        DispatchQueue.main.async {
            self.activePeerManager?.stopReplicationSync()
            self.passivePeerManager?.stopReplicationSync()
        }
    }
    
    func notConnectedToPeer(peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            self.activePeerManager?.stopReplicationSync()
            self.passivePeerManager?.stopReplicationSync()
            self.totalMessages.removeAll()
            self.tableView.reloadData()
            let alert = makeInfoAlert(title: nil, message: "Disconnected from: \(peerID.displayName)")
            self.navigationViewController?.present(alert, animated: true)
        }
    }
}

extension ChatPeerViewController: UIGestureRecognizerDelegate {
    
}
