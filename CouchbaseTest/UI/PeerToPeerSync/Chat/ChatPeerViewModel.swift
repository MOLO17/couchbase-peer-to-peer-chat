//
//  ChatPeerViewModel.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 10/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import UIKit

class ChatPeerViewModel {
    
    // MARK: - Private attributes
    private let peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol
    private let useCases: PeersUseCases
    
    
    // MARK: - Methods
    init(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol, peersUseCases: PeersUseCases) {
        
        self.peerToPeerCoordinator = peerToPeerCoordinator
        self.useCases = peersUseCases
    }
    
    func getDB() -> Database {
        self.useCases.getDB()
    }
    
    func update(callback: @escaping(([ChatMessage]) -> Void)) {
        self.useCases.getAllStrings { callback($0) }
    }
    
    func update(id: String, callback: @escaping(([ChatMessage]) -> Void)) {
        
        if let personalId = UIDevice.current.identifierForVendor?.uuidString {
            self.useCases.getAllStrings { allMessages in
                callback(allMessages.filter { $0.creatorId == id || $0.creatorId == personalId })
            }
        }
    }
    
    func store(message: String, completion: ((Error?) -> Void)?) {
        self.useCases.store(message: message, completion: { completion?($0) })
    }
    
    func remove(message: ChatMessage, completion: ((Error?) -> Void)?) {
        self.useCases.remove(message: message, completion: completion)
    }
}
