//
//  PeersUseCases.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 13/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation


class PeersUseCases {
    
    // MARK: - Private Attributes
    private let repository: PeersRepository
    
    
    // MARK: - Methods
    init(peersRepository: PeersRepository) {
        self.repository = peersRepository
    }
    
    func getDB() -> Database {
        self.repository.getDB()
    }
    
    func getAllStrings(callback: @escaping(([ChatMessage]) -> Void)) {
        self.repository.getAllTextType { callback($0.map(ModelMapper.dataChatMessageToChatMessage)) }
    }
    
    func getAllMessages(byCreatorId id: String, callback: @escaping(([ChatMessage]) -> Void)) {
        self.repository.findTextType(byId: id) { callback($0.map(ModelMapper.dataChatMessageToChatMessage)) }
    }
    
    func store(message: String, completion: ((Error?) -> Void)?) {
        self.repository.store(message: message, completion: { completion?($0) })
    }
    
    func remove(message: ChatMessage, completion: ((Error?) -> Void)?) {
        self.repository.remove(message: ModelMapper.chatMessageToDataChatMessage(chatMessage: message), completion: completion)
    }
}
