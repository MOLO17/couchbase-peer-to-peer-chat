//
//  ActivePeerConnection.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 10/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity

class PeerConnection: MessageEndpointConnection {
    
    // MARK: - Attributes
    var didConnect: ((ReplicatorConnection) -> ())?
    var readyToSend: ((Data) -> Void)?
    
    
    // MARK: - Methods
    func open(connection: ReplicatorConnection, completion: @escaping (Bool, MessagingError?) -> Void) {
        
        didConnect?(connection)
        completion(true, nil)
    }
    
    func close(error: Error?, completion: @escaping () -> Void) {
        completion()
    }
    
    func send(message: Message, completion: @escaping (Bool, MessagingError?) -> Void) {
        
        let data = message.toData()
        self.readyToSend?(data)
        completion(true, nil)
    }
}
