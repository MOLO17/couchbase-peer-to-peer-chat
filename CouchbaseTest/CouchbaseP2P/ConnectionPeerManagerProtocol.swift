//
//  ConnectionPeerManagerProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 14/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity

protocol ConnectionPeerManagerProtocol {
    
    // MARK: - Methods
    func didReceive(message: Message)
    func stopReplicationSync(forTarget: MCPeerID)
}
