//
//  DetailViewModel.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class DetailViewModel {
    
    // MARK: - Private Attributes
    private let useCases: PersonUseCases
    private let coordinator: MasterDetailFlowCoordinatorProtocol
    
    // MARK: - Methods
    init(detailUseCases: PersonUseCases, masterDetailFlowCoordinator: MasterDetailFlowCoordinatorProtocol) {
        
        self.useCases = detailUseCases
        self.coordinator = masterDetailFlowCoordinator
    }
    
    func updatePerson(person: Person) {
        self.useCases.updatePerson(person: person)
    }
}
