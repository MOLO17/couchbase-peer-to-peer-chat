//
//  PeersRepositoryProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 13/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation

protocol PeersRepositoryProtocol {
    
    // MARK: - Methods
    func getDB() -> Database
    func getAllTextType() -> [String]
    func findTextType(byId id: String, callback: @escaping(([DataChatMessage]) -> Void))
    func store(message: String, completion: ((Error?) -> Void)?)
    func remove(message: DataChatMessage, completion: ((Error?) -> Void)?)
}
