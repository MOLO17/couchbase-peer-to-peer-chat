//
//  PassivePeerManager.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 13/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation

class PassivePeerManager: PeerManagerProtocol {

    // MARK: - Private attributes
    private var listener: MessageEndpointListener
    private var connection: MessageEndpointConnection?
    private var replicatorConnection: ReplicatorConnection?


    // MARK: - Attributes
    var send: ((Data) -> Void)?


    // MARK: - Methods
    init(database: Database) {

        self.listener = MessageEndpointListener(config: MessageEndpointListenerConfiguration(database: database, protocolType: .messageStream))
        self.setupConnection()
    }

    func sendToEndpoint(message: Message, completion: ((Error?) -> Void)?) {
        self.connection?.send(message: message) { completion?($1?.error) }
    }

    func didReceive(message: Message) {
        self.replicatorConnection!.receive(message: message)
    }

    func stopReplicationSync() {
        
        self.listener.closeAll()
        self.replicatorConnection?.close(error: nil)
    }


    // MARK: - Private methods
    private func setupConnection() {

        let connection = PeerConnection()
        self.connection = connection
        self.listener.accept(connection: connection)

        connection.didConnect = { [weak self] conn in
            self?.replicatorConnection = conn
        }
        connection.readyToSend = { [weak self] data in
             self?.send?(data)
        }
    }
}
