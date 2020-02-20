//
//  BeerDetailViewModel.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 20/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class BeerDetailViewModel {
    
    // MARK: - Pivate Attributes
    private let useCases: BeerUseCases
    private let coordinator: MasterDetailFlowCoordinatorProtocol
    
    
    // MARK: - Methods
    init(beerUseCases: BeerUseCases, masterDetailFlowCoordinator: MasterDetailFlowCoordinatorProtocol) {
        
        self.useCases = beerUseCases
        self.coordinator = masterDetailFlowCoordinator
    }
    
    func updateBeer(beer: Beer) {
        self.useCases.updateBeer(beer: beer)
    }
}
