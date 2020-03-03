//
//  PassivePeerManager.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 28/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity

class PassivePeerManager: ConnectionPeerManagerProtocol {
    
    // MARK: - Private attributes
    private let listener: MessageEndpointListener
    private var connection: MessageEndpointConnection?
    private var replicatorConnection: ReplicatorConnection?
    
    
    // MARK: - Attributes
    var target: [MCPeerID]
    var send: ((Data) -> Void)?
    
    
    // MARK: - Methods
    init(database: Database, target: [MCPeerID]) {
        self.target = target
        self.listener = MessageEndpointListener(config: MessageEndpointListenerConfiguration(database: database, protocolType: .messageStream))
        self.setupConnection(database: database)
    }
    
    func didReceive(message: Message) {
        self.replicatorConnection?.receive(message: message)
    }
    
    func stopReplicationSync() {
        
        self.connection?.close(error: nil) {}
        self.replicatorConnection?.close(error: nil)
    }
    
    
    // MARK: - Private methods
    private func setupConnection(database: Database) {
        
        let connection = PeerConnection()
        self.connection = connection
        listener.accept(connection: connection)
        
        connection.didConnect = { [weak self] conn in
            self?.replicatorConnection = conn
        }
        connection.readyToSend = { [weak self] data in
            self?.send?(data)
        }
    }
}

extension PassivePeerManager: Equatable {
    
    static func == (lhs: PassivePeerManager, rhs: PassivePeerManager) -> Bool {
        lhs.target == rhs.target
    }
}
