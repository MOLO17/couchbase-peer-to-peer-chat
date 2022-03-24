//
//  ActivePeerManager.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 13/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity


class ActivePeerManager: ConnectionPeerManagerProtocol {
    
    // MARK: - Private attributes
    private var replicator: Replicator?
    private var connection: MessageEndpointConnection?
    private var replicatorConnection: ReplicatorConnection?
    
    
    // MARK: - Attributes
    var target: [MCPeerID]
    var send: ((Data) -> Void)?
    
    
    // MARK: - Methods
    init(database: Database, target: [MCPeerID]) {
        self.target = target
        self.setupConnection(database: database, target: target)
    }
    
    func didReceive(message: Message) {
        self.replicatorConnection?.receive(message: message)
    }
    
    func stopReplicationSync() {
        
        self.connection?.close(error: nil) {}
        self.replicator?.stop()
        self.replicatorConnection?.close(error: nil)
    }
    
    
    // MARK: - Private methods
    private func setupConnection(database: Database, target: [MCPeerID]) {
        
        let messageTarget = MessageEndpoint(uid: "AP:\(UUID().uuidString.dropLast(28))", target: target, protocolType: .messageStream, delegate: self)
        let config = ReplicatorConfiguration(database: database, target: messageTarget)
        config.continuous = true
        config.replicatorType = .pushAndPull
        
        self.replicator = Replicator(config: config)
        self.replicator?.start()
    }
}

extension ActivePeerManager: Equatable {
    
    static func == (lhs: ActivePeerManager, rhs: ActivePeerManager) -> Bool {
        lhs.target == rhs.target
    }
}

extension ActivePeerManager: MessageEndpointDelegate {
    
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
