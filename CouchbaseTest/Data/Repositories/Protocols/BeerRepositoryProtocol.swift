//
//  BeerRepositoryProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 20/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

protocol BeerRepositoryProtocol {
    
    // MARK: - Attributes
    var didUpdateValue: ((DataBeer) -> Void)? { get set }
    
    
    // MARK: - Methods
    func getAllBeers() -> [DataBeer]
    
    func getBeer(byId id: String) -> DataBeer?
    
    func storeBeer(person: DataBeer)
    
    func updateBeer(person: DataBeer)
    
    func removeBeer(person: DataBeer)
    
    func removeAll()
}
