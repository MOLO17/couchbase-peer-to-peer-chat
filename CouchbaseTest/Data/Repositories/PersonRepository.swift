//
//  PersonRepository.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation

class PersonRepository: PersonRepositoryProtocol {
    
    // MARK: - Private attributes
    private let datasource: Database
    
    
    // MARK: - Attributes
    var didUpdateValue: ((DataPerson) -> Void)?
    
    
    // MARK: - Methods
    init() {
        
        self.datasource = try! Database(name: "db")
        self.datasource.addChangeListener() { c in
            
            if let person = self.getPerson(byId: c.documentIDs[0]) {
                self.didUpdateValue?(person)
            }
        }
    }
    
    func getAllPersons() -> [DataPerson] {
        
        let query = QueryBuilder
            .select(SelectResult.all())
            .from(DataSource.database(self.datasource))
        
        var persons: [DataPerson] = []
        
        do {
            persons = try query.execute().allResults().map(ModelMapper.resultToPerson)
        } catch {
            print("Retrieving Error:", error.localizedDescription)
        }
        
        return persons
    }
    
    func getPerson(byId id: String) -> DataPerson? {
        
        guard let result = self.datasource.document(withID: id) else { return nil }
        return ModelMapper.documentToPerson(document: result)
    }
    
    func storePerson(person: DataPerson) {
        
        do {
            try self.datasource.saveDocument(ModelMapper.personToDocument(person: person))
        } catch {
            print("Store Error:", error.localizedDescription)
        }
    }
    
    func updatePerson(person: DataPerson) {
        
        if let doc = self.datasource.document(withID: person.mail)?.toMutable() {
            
            doc.setString(person.surname, forKey: "surname")
            doc.setString(person.name, forKey: "name")
            doc.setString(person.mail, forKey: "mail")
            doc.setDate(person.creationDate, forKey: "creationDate")
            
            do {
                try self.datasource.saveDocument(doc)
            } catch {
                print("Update Error:", error.localizedDescription)
            }
        }
    }
    
    func removePerson(person: DataPerson) {
        
        if let document = self.datasource.document(withID: person.mail) {
            
            do {
                try self.datasource.deleteDocument(document)
            } catch {
                print("Delete Error:", error.localizedDescription)
            }
        }
    }
    
    func removeAll() {
        
        do {
            try self.getAllPersons().map(ModelMapper.personToDocument).forEach(self.datasource.deleteDocument)
        } catch {
            print("Delete Error:", error.localizedDescription)
        }
    }
}
