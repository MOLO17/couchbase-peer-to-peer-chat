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


class ActivePeerManager: PeerManagerProtocol {
    
    // MARK: - Private attributes
    private var replicator: Replicator?
    private var connection: MessageEndpointConnection?
    private var replicatorConnection: ReplicatorConnection?
    
    
    // MARK: - Attributes
    var send: ((Data) -> Void)?
    
    
    // MARK: - Methods
    init(database: Database, passivePeer: MCPeerID) {
        self.setupConnection(database: database, target: passivePeer)
    }
    
    func sendToEndpoint(message: Message, completion: ((Error?) -> Void)?) {
        self.connection?.send(message: message) { completion?($1?.error) }
    }
    
    func didReceive(message: Message) {
        self.replicatorConnection?.receive(message: message)
    }
    
    func stopReplicationSync() {
        
        self.connection?.close(error: nil) {}
        self.replicator?.stop()
    }
    
    
    // MARK: - Private methods
    private func setupConnection(database: Database, target: MCPeerID) {
        
        let target = MessageEndpoint(uid: "AP:\(UUID().uuidString)", target: target, protocolType: .messageStream, delegate: self)
        let config = ReplicatorConfiguration(database: database, target: target)
        config.continuous = true
        config.replicatorType = .pushAndPull
        
        self.replicator = Replicator(config: config)
        self.replicator?.start()
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
