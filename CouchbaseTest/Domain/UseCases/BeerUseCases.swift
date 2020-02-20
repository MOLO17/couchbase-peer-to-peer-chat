//
//  BeerUseCases.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 20/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class BeerUseCases {
    
    // MARK: - Private Attributes
    private let repository: BeerRepository
    
    
    // MARK: - Attributes
    var didUpdateValue: ((Beer) -> Void)?
    
    
    // MARK: - Methods
    init(beerRepository: BeerRepository) {
        
        self.repository = beerRepository
        self.repository.didUpdateValue = { [weak self] data in
            
            guard let self = self else { return }
            self.didUpdateValue?(ModelMapper.dataBeerToBeer(dataBeer: data))
        }
    }
    
    func getAllBeers() -> [Beer] {
        self.repository.getAllBeers().map(ModelMapper.dataBeerToBeer)
    }
    
    func getBeer(byId id: String) -> Beer? {
        self.repository.getBeer(byId: id).map(ModelMapper.dataBeerToBeer)
    }
    
    func storeBeer(beer: Beer) {
        self.repository.storeBeer(beer: ModelMapper.beerToDataBeer(beer: beer))
    }
    
    func updateBeer(beer: Beer) {
        self.repository.updateBeer(beer: ModelMapper.beerToDataBeer(beer: beer))
    }
    
    func removeBeer(beer: Beer) {
        self.repository.removeBeer(beer: ModelMapper.beerToDataBeer(beer: beer))
    }
    
    func removeAll() {
        self.repository.removeAll()
    }
}
