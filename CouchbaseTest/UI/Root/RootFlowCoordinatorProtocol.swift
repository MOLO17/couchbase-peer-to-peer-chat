//
//  RootFlowCoordinatorProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import MultipeerConnectivity
import Foundation

protocol RootFlowCoordinatorProtocol: class {
    
    func toMaster()
    func toBeerMaster()
    func toDetail(person: Person)
    func toBeerDetail(beer: Beer)
    func toPeerToPeer()
    func toChat(selectedPeer: MCPeerID?)
}
