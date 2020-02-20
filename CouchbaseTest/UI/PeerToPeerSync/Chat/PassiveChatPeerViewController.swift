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

class PassiveChatPeerViewController: UIViewController {
    
    // MARK: - Private Attributes
    private let viewModel: ChatPeerViewModel
    private var keyboardManager: TextFieldsKeyboardManager!
    private let multiPeerManager = MultiPeerConnectivityManager.shared
    private let reuseIdentifier = "PeerCell"
    private let messageReuseIdentifier = "MessageCell"
    private var passivePeerManager: PassivePeerManager!

    private lazy var receivedData: ((Data) -> Void)? = { [weak self] data in
        
        guard let self = self else { return }
        DispatchQueue.main.async {
            self.passivePeerManager.didReceive(message: Message.fromData(data))
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
    
    private lazy var messageTextField: UITextField = {
        
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.returnKeyType = .default
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
    
    
    // MARK: - Methods
    init(viewModel: ChatPeerViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.setupPassivePeerManager()
        self.keyboardManager = TextFieldsKeyboardManager(viewController: self)
        self.keyboardManager.addtextFields(textField: self.messageTextField)
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
    private func setupPassivePeerManager() {
        
        DispatchQueue.main.async {
            self.passivePeerManager = PassivePeerManager(database: self.viewModel.getDB())
            self.passivePeerManager.send = { [weak self] data in
                
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
        self.view.addSubview(self.messageTextField)
        self.view.addSubview(self.sendButton)
        self.view.addSubview(self.stackView)
    }
    
    private func setupConstraints() {
        
        self.tableView.edgesToSuperview(excluding: .bottom)
        self.tableView.bottomToTop(of: self.messageTextField)
        
        self.messageTextField.leadingToSuperview(offset: 8, usingSafeArea: true)
        self.messageTextField.bottomToTop(of: self.stackView)
        self.messageTextField.setCompressionResistance(.required, for: .horizontal)
        self.messageTextField.height(to: self.sendButton, relation: .equalOrGreater)
        self.messageTextField.widthToSuperview(multiplier: 0.75)
        
        self.sendButton.centerY(to: self.messageTextField)
        self.sendButton.leadingToTrailing(of: self.messageTextField)
        self.sendButton.trailingToSuperview(offset: 8)
        self.sendButton.setHugging(.required, for: .horizontal)
        self.sendButton.setCompressionResistance(.required, for: .horizontal)
        
        self.stackView.edgesToSuperview(excluding: .top, usingSafeArea: true)
    }
    
    @objc private func sendButtonTapped() {
        
        if let text = self.messageTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            if self.messageTextField.isFirstResponder { self.messageTextField.resignFirstResponder() }
            self.messageTextField.text = ""
            
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
        
        self.messageTextField.layer.cornerRadius = 10
        self.messageTextField.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        self.messageTextField.layer.borderWidth = 1
        self.messageTextField.layer.borderColor = UIColor.lightGray.cgColor
        
    }
}

protocol PassiveChatPeerFactory {
    func makePassiveChatPeerViewController(viewModel: ChatPeerViewModel) -> PassiveChatPeerViewController
}

extension PassiveChatPeerViewController: UITableViewDataSource {
    
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

extension PassiveChatPeerViewController: UITableViewDelegate {
    
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

extension PassiveChatPeerViewController: MultiPeerConnectivityManagerDelegate {
    
    var didReceive: ((Data) -> Void)? {
        get { self.receivedData }
    }
    
    func lostPeer(id: MCPeerID) {
        DispatchQueue.main.async { self.passivePeerManager.stopReplicationSync() }
    }
    
    func notConnectedToPeer(peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            self.passivePeerManager.stopReplicationSync()
            
            self.totalMessages.removeAll()
            self.tableView.reloadData()
            
            let alert = makeInfoAlert(title: nil, message: "Disconnected from: \(peerID.displayName)")
            self.navigationViewController?.present(alert, animated: true)
        }
    }
}
