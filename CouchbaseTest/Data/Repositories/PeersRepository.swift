//
//  PeersRepository.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 10/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import UIKit

class PeersRepository {
    
    // MARK: - Private attributes
    private let database: Database
    private var token: ListenerToken?

    
    // MARK: - Methods
    init() {
        self.database = try! Database(name: "peerToPeerSync")
    }
    
    func getDB() -> Database {
        self.database
    }
    
    func getAllTextType(callback: @escaping(([DataChatMessage]) -> Void)) {
        
        let query = QueryBuilder.select(SelectResult.all())
            .from(DataSource.database(self.database))
            .where(Expression.property("type")
            .equalTo(Expression.string("text")))
        
        self.token = query.addChangeListener { (query) in
            
            let messages = query.results?.allResults().compactMap(ModelMapper.resultsToDataChatMessage)
            messages.flatMap(callback)
        }
    }
    
    func findTextType(byId id: String, callback: @escaping(([DataChatMessage]) -> Void)) {
        
        let query = QueryBuilder.select(SelectResult.all())
            .from(DataSource.database(self.database))
            .where(Expression.property("type")
            .equalTo(Expression.string("text"))
            .and(Expression.property("creatorId")
            .equalTo(Expression.string(id))))
        
        self.token = query.addChangeListener { (query) in
            
            let messages = query.results?.allResults().compactMap(ModelMapper.resultsToDataChatMessage)
            messages.flatMap(callback)
        }
    }
    
    func store(message: String, completion: ((Error?) -> Void)? ) {
        
        let id = UUID().uuidString
        let doc = MutableDocument(id: id,
                                  data: ["id": id,
                                         "text": message,
                                         "creatorId": UIDevice.current.identifierForVendor?.uuidString ?? "iPhone",
                                         "creationDate": Formatters.dataMessageDateFormatter.string(from: Date()),
                                         "type": "text"])
        do {
            try self.database.saveDocument(doc)
            completion?(nil)
        } catch {
            completion?(error)
        }
    }
    
    func remove(message: DataChatMessage, completion: ((Error?) -> Void)?) {
        
        if let document = self.database.document(withID: message.id) {
            
            do {
                try self.database.deleteDocument(document)
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
}
