//
//  MainPeerToPeerViewModel.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 23/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import MultipeerConnectivity

class MainPeerToPeerViewModel {
    
    // MARK: - Private attributes
    private let useCases: PeersUseCases
    private let peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol
    
    
    // MARK: - Methods
    init(peersUseCases: PeersUseCases, peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) {
        
        self.useCases = peersUseCases
        self.peerToPeerCoordinator = peerToPeerCoordinator
    }
    
    func getDB() -> Database {
        self.useCases.getDB()
    }
    
    func toChat() {
        self.peerToPeerCoordinator.toChat()
    }
}
