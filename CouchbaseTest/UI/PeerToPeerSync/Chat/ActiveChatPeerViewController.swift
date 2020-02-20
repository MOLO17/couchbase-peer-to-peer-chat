//
//  ActiveChatPeerViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 10/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity
import UIKit

class ActiveChatPeerViewController: UIViewController {
    
    // MARK: - Private Attributes
    private let viewModel: ChatPeerViewModel
    private var keyboardManager: TextFieldsKeyboardManager!
    private let multiPeerManager = MultiPeerConnectivityManager.shared
    private let reuseIdentifier = "PeerCell"
    private let messageReuseIdentifier = "MessageCell"
    private var activePeerManager: ActivePeerManager!
    
    private lazy var receivedData: ((Data) -> Void)? = { [weak self] data in
        
        guard let self = self else { return }
        DispatchQueue.main.async {
            self.activePeerManager.didReceive(message: Message.fromData(data))
        }
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
    
    
    // MARK: - Attributes
    var passivePeer: MCPeerID? {
        didSet { self.passivePeer.flatMap(self.setupActivePeerManager) }
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
        
        self.multiPeerManager.delegate = self
        self.viewModel.update { [weak self] messages in
            self?.totalMessages = messages
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.applyStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.multiPeerManager.session.disconnect()
    }
    
    
    // MARK: - Private Methods
    private func setupActivePeerManager(passivePeer: MCPeerID) {
        
        DispatchQueue.main.async {
            self.activePeerManager = ActivePeerManager(database: self.viewModel.getDB(), passivePeer: passivePeer)
            self.activePeerManager.send = { [weak self] data in
                
                guard let self = self else { return }
                do {
                    try self.multiPeerManager.session.send(data, toPeers: self.multiPeerManager.session.connectedPeers, with: .reliable)
                } catch {
                    
                    DispatchQueue.main.async {
                        let alert = makeInfoAlert(title: nil, message: error.localizedDescription)
                        self.navigationViewController?.present(alert, animated: true)
                    }
                }
            }
            
            self.tableView.reloadData()
        }
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
    
    private func applyStyle() {
        
        self.sendButton.layer.cornerRadius = 10
        self.sendButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        self.messageTextfield.layer.cornerRadius = 10
        self.messageTextfield.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        self.messageTextfield.layer.borderWidth = 1
        self.messageTextfield.layer.borderColor = UIColor.lightGray.cgColor
        
    }
}

protocol ActiveChatPeerFactory {
    
    func makeActiveChatPeerViewController(viewModel: ChatPeerViewModel) -> ActiveChatPeerViewController
    func makeChatPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> ChatPeerViewModel
}

extension ActiveChatPeerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.messageReuseIdentifier, for: indexPath) as? MessageTableViewCell else {
            return UITableViewCell()
        }
        let message = self.totalMessages[indexPath.row]
        cell.setupCell(layout: MessageTableViewCell.Layout(text: message.text, type: message.messageType, date: message.creationDate))
        return cell
    }
}

extension ActiveChatPeerViewController: UITableViewDelegate {
    
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

extension ActiveChatPeerViewController: MultiPeerConnectivityManagerDelegate {
    
    var didReceive: ((Data) -> Void)? {
        get { self.receivedData }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        DispatchQueue.main.async { self.navigationViewController?.present(makeInfoAlert(title: nil, message: "Connected to: \(peerID.displayName)"), animated: true) }
    }
    
    func lostPeer(id: MCPeerID) {
        DispatchQueue.main.async { self.activePeerManager.stopReplicationSync() }
    }
    
    func notConnectedToPeer(peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            self.activePeerManager.stopReplicationSync()
            self.totalMessages.removeAll()
            self.tableView.reloadData()
            let alert = makeInfoAlert(title: nil, message: "Disconnected from: \(peerID.displayName)")
            self.navigationViewController?.present(alert, animated: true)
        }
    }
}
