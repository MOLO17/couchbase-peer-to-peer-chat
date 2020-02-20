//
//  PeerManagerProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 14/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation

protocol PeerManagerProtocol {
    
    // MARK: - Methods
    func sendToEndpoint(message: Message, completion: ((Error?) -> Void)?)
    func didReceive(message: Message)
    func stopReplicationSync()
}
