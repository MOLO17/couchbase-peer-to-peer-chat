//
//  BeerMasterViewModel.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 20/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class BeerMasterViewModel {
    
    // MARK: - Private attributes
    private let useCases: BeerUseCases
    private let coordinator: MasterDetailFlowCoordinatorProtocol
    
    
    // MARK: - Attributes
    var didUpdateValue: ((Beer) -> Void)?
    
    
    // MARK: - Methods
    init(beerUseCases: BeerUseCases, masterDetailFlowCoordinator: MasterDetailFlowCoordinatorProtocol) {
        
        self.useCases = beerUseCases
        self.coordinator = masterDetailFlowCoordinator
        self.useCases.didUpdateValue = { [weak self] beer in
            
            guard let self = self else { return }
            self.didUpdateValue?(beer)
        }
    }
    
    func getBeers() -> [Beer] {
        self.useCases.getAllBeers()
    }
    
    func toDetail(beer: Beer) {
        self.coordinator.toBeerDetail(beer: beer)
    }
    
    func addBeer(beer: Beer) {
        self.useCases.storeBeer(beer: beer)
    }
    
    func removeBeer(beer: Beer) {
        self.useCases.removeBeer(beer: beer)
    }
}
