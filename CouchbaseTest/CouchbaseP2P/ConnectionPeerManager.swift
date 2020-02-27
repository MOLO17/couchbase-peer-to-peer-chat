//
//  ConnectionPeerManager.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 13/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity


class ConnectionPeerManager: ConnectionPeerManagerProtocol {
    
    // MARK: - Private attributes
    private let target: MCPeerID
    private var replicator: Replicator?
    private var connection: MessageEndpointConnection?
    private var replicatorConnection: ReplicatorConnection?
    
    
    // MARK: - Attributes
    var send: ((Data) -> Void)?
    
    
    // MARK: - Methods
    init(database: Database, target: MCPeerID) {
        self.target = target
        self.setupConnection(database: database, target: target)
    }
    
    func didReceive(message: Message) {
        self.replicatorConnection?.receive(message: message)
    }
    
    func stopReplicationSync(forTarget target: MCPeerID) {
        
        if target == self.target {
            self.connection?.close(error: nil) {}
            self.replicator?.stop()
            self.replicatorConnection?.close(error: nil)
        }
    }
    
    
    // MARK: - Private methods
    private func setupConnection(database: Database, target: MCPeerID) {
        
        let messageTarget = MessageEndpoint(uid: "AP:\(UIDevice.current.identifierForVendor?.uuidString ?? "ID")", target: target, protocolType: .messageStream, delegate: self)
        let config = ReplicatorConfiguration(database: database, target: messageTarget)
        config.continuous = true
        config.replicatorType = .pushAndPull
        
        self.replicator = Replicator(config: config)
        self.replicator?.start()
    }
}

extension ConnectionPeerManager: Equatable {
    
    static func == (lhs: ConnectionPeerManager, rhs: ConnectionPeerManager) -> Bool {
        lhs.target == rhs.target
    }
}

extension ConnectionPeerManager: MessageEndpointDelegate {
    
    func createConnection(endpoint: MessageEndpoint) -> MessageEndpointConnection {
        
        let connection = PeerConnection()
        self.connection = connection
        
        connection.didConnect = { [weak self] conn in
            self?.replicatorConnection = conn
        }
        connection.readyToSend = { [weak self] data in
            self?.send?(data)
        }
        return connection
    }
}
