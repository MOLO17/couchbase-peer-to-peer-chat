//
//  MainPeerToPeerViewModel.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 23/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MainPeerToPeerViewModel {
    
    // MARK: - Private attributes
    private let peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol
    
    
    // MARK: - Methods
    init(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) {
        self.peerToPeerCoordinator = peerToPeerCoordinator
    }
    
    func toChat(selectedPeer: MCPeerID?) {
        self.peerToPeerCoordinator.toChat(selectedPeer: selectedPeer)
    }
}
