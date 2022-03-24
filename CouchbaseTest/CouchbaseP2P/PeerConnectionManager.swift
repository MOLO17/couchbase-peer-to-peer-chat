//
//  PeerConnectionManager.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 25/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity


class PeerConnectionManager: PeerConnectionProtocol {
    
    // MARK: - Private attributes
    private var replicators = [Replicator]()
    private var listener: MessageEndpointListener
    private var connections = [MessageEndpointConnection]()
    private var replicatorConnections = [ReplicatorConnection]()
    
    
    // MARK: - Attributes
    var send: ((Data) -> Void)?
    
    
    // MARK: - Methods
    init(database: Database, passivePeers: [MCPeerID]) {
        self.listener = MessageEndpointListener(config: MessageEndpointListenerConfiguration(database: database, protocolType: .messageStream))
        self.setupConnection(database: database, target: passivePeers)
    }
    
    func sendToEndpoint(message: Message, completion: ((Error?) -> Void)?) {
        self.connections.forEach { $0.send(message: message) { completion?($1?.error) } }
    }
    
    func didReceive(message: Message) {
        self.replicatorConnections.forEach { $0.receive(message: message) }
    }
    
    func stopReplicationSync() {
        
        self.connections.forEach { $0.close(error: nil) {} }
        self.replicators.forEach { $0.stop() }
        
        self.listener.closeAll()
        self.replicatorConnections.forEach{ $0.close(error: nil) }
    }
    
    
    // MARK: - Private methods
    private func setupConnection(database: Database, target: [MCPeerID]) {
        
        target.forEach {
            
            let target = MessageEndpoint(uid: "AP:\(UUID().uuidString)", target: $0, protocolType: .messageStream, delegate: self)
            let config = ReplicatorConfiguration(database: database, target: target)
            config.continuous = true
            config.replicatorType = .pushAndPull
            
            let replicator = Replicator(config: config)
            self.replicators.append(replicator)
            replicator.start()
        }
    }
}

extension  PeerConnectionManager: MessageEndpointDelegate {
    
    func createConnection(endpoint: MessageEndpoint) -> MessageEndpointConnection {
        
        let connection = PeerConnection()
        self.connections.append(connection)
        self.connections.forEach(self.listener.accept)
        
        connection.didConnect = { [weak self] conn in
            self?.replicatorConnections.append(conn)
        }
        connection.readyToSend = { [weak self] data in
            self?.send?(data)
        }
        return connection
    }
}
