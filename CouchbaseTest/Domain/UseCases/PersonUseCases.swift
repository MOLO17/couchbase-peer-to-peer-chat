//
//  PersonUseCases.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class PersonUseCases {
    
    // MARK: - Private Attributes
    private let repository: PersonRepository
    
    
    // MARK: - Attributes
    var didUpdateValue: ((Person) -> Void)?
    
    
    // MARK: - Methods
    init(personRepository: PersonRepository) {
        
        self.repository = personRepository
        self.repository.didUpdateValue = { [weak self] data in
            
            guard let self = self else { return }
            self.didUpdateValue?(ModelMapper.dataPersonToPerson(dataPerson: data))
        }
    }
    
    func getAllPersons() -> [Person] {
        self.repository.getAllPersons().map(ModelMapper.dataPersonToPerson)
    }
    
    func getPerson(byId id: String) -> Person? {
        self.repository.getPerson(byId: id).map(ModelMapper.dataPersonToPerson)
    }
    
    func storePerson(person: Person) {
        self.repository.storePerson(person: ModelMapper.personToDataPerson(person: person))
    }
    
    func updatePerson(person: Person) {
        self.repository.updatePerson(person: ModelMapper.personToDataPerson(person: person))
    }
    
    func removePerson(person: Person) {
        self.repository.removePerson(person: ModelMapper.personToDataPerson(person: person))
    }
    
    func removeAll() {
        self.repository.removeAll()
    }
}
