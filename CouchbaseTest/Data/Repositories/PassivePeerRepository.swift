//
//  PassivePeerRepository.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 10/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation

class PassivePeerRepository {
    
        // MARK: - Private attributes
        private let datasource: Database
        private let listener: MessageEndpointListener
        
        // MARK: - Methods
        init() {
            
            self.datasource = try! Database(name: "peerToPeerSync")
            self.listener = MessageEndpointListener(config: MessageEndpointListenerConfiguration(database: datasource, protocolType: .messageStream))
        }
    }
