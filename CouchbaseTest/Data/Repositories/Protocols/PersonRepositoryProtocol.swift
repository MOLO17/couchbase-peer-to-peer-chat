//
//  PersonRepositoryProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 16/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

protocol PersonRepositoryProtocol {
    
    // MARK: - Attributes
    var didUpdateValue: ((DataPerson) -> Void)? { get set }
    
    
    // MARK: - Methods
    func getAllPersons() -> [DataPerson]
    
    func getPerson(byId id: String) -> DataPerson?
    
    func storePerson(person: DataPerson)
    
    func updatePerson(person: DataPerson)
    
    func removePerson(person: DataPerson)
    
    func removeAll()
}
