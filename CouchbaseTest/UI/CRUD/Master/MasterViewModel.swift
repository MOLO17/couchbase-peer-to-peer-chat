//
//  MasterViewModel.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class MasterViewModel {
    
    // MARK: - Private attributes
    private let useCases: PersonUseCases
    private let coordinator: MasterDetailFlowCoordinatorProtocol
    
    
    // MARK: - Attributes
    var didUpdateValue: ((Person) -> Void)?
    
    
    // MARK: - Methods
    init(masterUseCases: PersonUseCases, masterDetailFlowCoordinator: MasterDetailFlowCoordinatorProtocol) {
        
        self.useCases = masterUseCases
        self.coordinator = masterDetailFlowCoordinator
        self.useCases.didUpdateValue = { [weak self] person in
            
            guard let self = self else { return }
            self.didUpdateValue?(person)
        }
    }
    
    func getPersons() -> [Person] {
        self.useCases.getAllPersons()
    }
    
    func addPerson(person: Person) {
        self.useCases.storePerson(person: person)
    }
    
    func removePerson(person: Person) {
        self.useCases.removePerson(person: person)
    }
    
    func toDetail(person: Person) {
        self.coordinator.toDetail(person: person)
    }
    
    func toBeerMaster() {
        self.coordinator.toBeerMaster()
    }
    
    func toPeerToPeer() {
        self.coordinator.toPeerToPeer()
    }
}
