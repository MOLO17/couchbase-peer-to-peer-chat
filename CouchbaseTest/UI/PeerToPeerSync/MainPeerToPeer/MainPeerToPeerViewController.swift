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
    private var isBrowsing: Bool = false
    private var isAdvertising: Bool = false
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
    
    private lazy var buttonStackView: UIStackView = {
        
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .equalSpacing
        s.addArrangedSubview(self.startStopBrowsingButton)
        s.addArrangedSubview(self.startStopAdvertisingButton)
        s.addArrangedSubview(self.skipToChatButton)
        return s
    }()
    
    private lazy var startStopBrowsingButton: UIButton = {
        
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Stop Browsing", for: UIControl.State())
        b.setTitleColor(.systemBlue, for: UIControl.State())
        b.addTarget(self, action: #selector(startStopBrowsingButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var startStopAdvertisingButton: UIButton = {
        
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Stop Advertising", for: UIControl.State())
        b.setTitleColor(.systemBlue, for: UIControl.State())
        b.addTarget(self, action: #selector(startStopAdvertisingButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var skipToChatButton: UIButton = {
       
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Skip to chat", for: UIControl.State())
        b.setTitleColor(.systemBlue, for: UIControl.State())
        b.addTarget(self, action: #selector(skipToChatButtonTapped), for: .touchUpInside)
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
        self.isBrowsing = true
        self.multiPeerManager.advertiser.startAdvertisingPeer()
        self.isAdvertising = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.multiPeerManager.browser.stopBrowsingForPeers()
        self.isBrowsing = false
        self.multiPeerManager.advertiser.stopAdvertisingPeer()
        self.isAdvertising = false
    }
    
    
    // MARK: - Private Methods
    private func setupViews() {
        self.view = UIView()
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.buttonStackView)
    }
    
    private func setupConstraints() {
        self.tableView.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        self.tableView.bottomToTop(of: self.buttonStackView)
        
        self.buttonStackView.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8), usingSafeArea: true)
    }
    
    @objc private func connectBarButtonTapped() {
        
        selectedPeers.forEach { [weak self] selectedPeer in
            
            self?.multiPeerManager.session.nearbyConnectionData(forPeer: selectedPeer) { [weak self] c, e in
                
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
    }
    
    @objc private func startStopBrowsingButtonTapped() {
        
        if self.isBrowsing {
            self.multiPeerManager.browser.stopBrowsingForPeers()
            self.isBrowsing = false
            self.startStopBrowsingButton.setTitle("Start Browsing", for: UIControl.State())
        } else {
            DispatchQueue.main.async {
                self.foundPeers.removeAll()
                self.tableView.reloadData()
            }
            self.multiPeerManager.browser.startBrowsingForPeers()
            self.isBrowsing = true
            self.startStopBrowsingButton.setTitle("Stop Browsing", for: UIControl.State())
        }
    }
    
    @objc private func startStopAdvertisingButtonTapped() {
        
        if self.isAdvertising {
            self.multiPeerManager.advertiser.stopAdvertisingPeer()
            self.isAdvertising = false
            self.startStopAdvertisingButton.setTitle("Start Advertising", for: UIControl.State())
        } else {
            self.multiPeerManager.advertiser.startAdvertisingPeer()
            self.isAdvertising = true
            self.startStopAdvertisingButton.setTitle("Stop Advertising", for: UIControl.State())
        }
    }
    
    @objc private func skipToChatButtonTapped() {
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
            self.skipToChatButton.isEnabled = true
            
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                cell.selectionStyle = .none
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            
            self.selectedPeers.remove(at: indexPath.row)
            self.connectBarButton.isEnabled = false
            self.skipToChatButton.isEnabled = false

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
            if self.multiPeerManager.session.connectedPeers.isEmpty {
                self.isPassive = true
                let alert = makeInvitationAlert(title: nil, message: "\(peer.displayName) wants to chat with you", peer: peer, handler: invitationHandler)
                self.navigationViewController?.present(alert, animated: true)
            } else {
                invitationHandler(false)
            }
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        
        print("Connected Peers: \(self.connectedPeers.map { $0.displayName })")
        DispatchQueue.main.async {
        
            if self.isPassive {
                self.viewModel.toChat()
            } else {
                self.viewModel.toChat()
            }
        }
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
