//
//  MainPeerToPeerViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 23/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

class MainPeerToPeerViewController: UIViewController {
    
    
    // MARK: - Private Attributes
    private let viewModel: MainPeerToPeerViewModel
    private let multiPeerManager: MultiPeerConnectivityManager
    private let reuseIdentifier = "PeerCell"
    private var selectedPeers = [MCPeerID]()
    private var connectedPeers = [MCPeerID]()
    private var isPassive: Bool = false
    private lazy var receivedData: ((Data) -> Void)? = { data in
        if let receivedString = String(data: data, encoding: .isoLatin1) {
            print("Received : \(receivedString)")
        } else {
            print("Received : Data, but unable to decode it with .isoLatin1 encoding type.")
        }
    }
    
    private var foundPeers = [MCPeerID]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private lazy var tableView: UITableView = {
        
        let t = UITableView()
        t.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        t.tableFooterView = UIView()
        t.allowsMultipleSelection = true
        t.dataSource = self
        t.delegate = self
        return t
    }()
    
    private lazy var connectBarButton: UIBarButtonItem = {
        
        let b = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(connectBarButtonTapped))
        b.isEnabled = false
        return b
    }()
    
    
    // MARK: - Methods
    init(viewModel: MainPeerToPeerViewModel) {
        self.viewModel = viewModel
        self.multiPeerManager = MultiPeerConnectivityManager.shared
        super.init(nibName: nil, bundle: nil)
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
        
        self.navigationItem.rightBarButtonItems = [self.connectBarButton]
        self.multiPeerManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.multiPeerManager.browser.startBrowsingForPeers()
        self.multiPeerManager.advertiser.startAdvertisingPeer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.multiPeerManager.browser.stopBrowsingForPeers()
//        self.multiPeerManager.advertiser.stopAdvertisingPeer()
    }
    
    
    // MARK: - Private Methods
    private func setupViews() {
        self.view = UIView()
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
    }
    
    private func setupConstraints() {
        self.tableView.edgesToSuperview(usingSafeArea: true)
    }
    
    @objc private func connectBarButtonTapped() {
        
        self.selectedPeers.forEach { selectedPeer in
            self.multiPeerManager.session.nearbyConnectionData(forPeer: selectedPeer) { [weak self] c, e in
                
                guard let self = self else { return }
                if let context = c {
                    self.multiPeerManager.browser.invitePeer(selectedPeer, to: self.multiPeerManager.session, withContext: context, timeout: 30)
                }
                
                if let error = e {
                    
                    DispatchQueue.main.async {
                        
                        let alert = makeInfoAlert(title: nil, message: error.localizedDescription)
                        self.navigationViewController?.present(alert, animated: true)
                    }
                }
            }
        }
        self.viewModel.toChat()
    }
}

protocol MainPeerToPeerFactory {
    
    func makeMainPeerToPeerViewController(viewModel: MainPeerToPeerViewModel) -> MainPeerToPeerViewController
    func makeMainPeerToPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> MainPeerToPeerViewModel
}

extension MainPeerToPeerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.foundPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = self.foundPeers[indexPath.row].displayName
        return cell
    }
}

extension MainPeerToPeerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            let selectedPeer = self.foundPeers[indexPath.row]
            self.selectedPeers.append(selectedPeer)
            self.connectBarButton.isEnabled = true
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                cell.selectionStyle = .none
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            let selectedPeer = self.foundPeers[indexPath.row]
            self.selectedPeers.removeAll(where: { $0 == selectedPeer })
            if self.selectedPeers.isEmpty { self.connectBarButton.isEnabled = false }
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }
        }
    }
}

extension MainPeerToPeerViewController: MultiPeerConnectivityManagerDelegate {
    
    var didReceive: ((Data) -> Void)? {
        get { self.receivedData }
    }
    
    func foundPeer(id: MCPeerID) {
        
        DispatchQueue.main.async {
            
            if !(self.foundPeers.map { $0.displayName }.contains(id.displayName)) {
                self.foundPeers.append(id)
            }
        }
    }
    
    func didReceiveInvitation(fromPeer peer: MCPeerID, invitationHandler: @escaping ((Bool) -> Void)) {
        
        DispatchQueue.main.async {
            self.isPassive = true
            let alert = makeInvitationAlert(title: nil, message: "\(peer.displayName) wants to chat with you", peer: peer, handler: invitationHandler)
            self.navigationViewController?.present(alert, animated: true)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        print("Connected Peers: \(self.connectedPeers.map { $0.displayName })")
        DispatchQueue.main.async { if self.isPassive { self.viewModel.toChat() }}
    }
    
    func lostPeer(id: MCPeerID) {
        
        DispatchQueue.main.async {
            
            if (self.foundPeers.map { $0.displayName }.contains(id.displayName)) {
                self.foundPeers.removeAll(where: { $0 == id })
            }
        }
    }
    
    func notConnectedToPeer(peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            
            self.foundPeers.removeAll()
            self.tableView.reloadData()

            let alert = makeInfoAlert(title: nil, message: "Disconnected from: \(peerID.displayName)")
            self.navigationViewController?.present(alert, animated: true)
        }
    }
}
