//
//  BeerRepository.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 20/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation

class BeerRepository {
    
    // MARK: - Private attributes
    private let datasource: Database
    private let replicator: Replicator
    
    
    // MARK: - Attributes
    var didUpdateValue: ((DataBeer) -> Void)?
    
    
    // MARK: - Methods
    init() {
        
        self.datasource = try! Database(name: "beers.db", config: DatabaseConfiguration())
        let config = ReplicatorConfiguration(database: datasource, target: URLEndpoint(url: URL(string: "ws://10.17.0.55:4984/beers")!))
        config.continuous = true
        self.replicator = Replicator(config: config)
        self.replicator.start()
        
        self.datasource.addChangeListener() { c in
            
            if let beer = self.getBeer(byId: c.documentIDs[0]) {
                self.didUpdateValue?(beer)
            }
        }
    }
    
    func getAllBeers() -> [DataBeer] {
        
        var beers: [DataBeer] = []
        let query = QueryBuilder
            .select(SelectResult.all())
            .from(DataSource.database(self.datasource))
        
        do {
            beers = try query.execute().allResults().map(ModelMapper.resultToBeer).sorted(by: { $0.category < $1.category })
        } catch {
            print("Retrieving Error:", error.localizedDescription)
        }
        
        return beers
    }
    
    func getBeer(byId id: String) -> DataBeer? {
        
        guard let result = self.datasource.document(withID: id) else { return nil }
        return ModelMapper.documentToBeer(document: result)
    }
    
    func storeBeer(beer: DataBeer) {
        
        do {
            try self.datasource.saveDocument(ModelMapper.beerToDocument(dataBeer: beer))
        } catch {
            print("Store Error:", error.localizedDescription)
        }
    }
    
    func updateBeer(beer: DataBeer) {
        
        if let doc = self.datasource.document(withID: self.makeId(from: beer))?.toMutable() {
            
            doc.setFloat(beer.abv, forKey: "abv")
            doc.setString(beer.breweryId, forKey: "brewery_id")
            doc.setString(beer.category, forKey: "category")
            doc.setString(beer.description, forKey: "description")
            doc.setInt(beer.ibu, forKey: "ibu")
            doc.setString(beer.name, forKey: "name")
            doc.setInt(beer.srm, forKey: "srm")
            doc.setString(beer.style, forKey: "style")
            doc.setString(beer.type, forKey: "type")
            doc.setInt(beer.upc, forKey: "upc")
            doc.setDate(beer.updated, forKey: "updated")
            
            do {
                try self.datasource.saveDocument(doc)
            } catch {
                print("Update Error:", error.localizedDescription)
            }
        }
    }
    
    func removeBeer(beer: DataBeer) {
        
        if let document = self.datasource.document(withID: self.makeId(from: beer)) {
            
            do {
                try self.datasource.deleteDocument(document)
            } catch {
                print("Delete Error:", error.localizedDescription)
            }
        }
    }
    
    func removeAll() {
        
        do {
            try self.getAllBeers().map(ModelMapper.beerToDocument).forEach(self.datasource.deleteDocument)
        } catch {
            print("Delete Error:", error.localizedDescription)
        }
    }
    
    
    // MARK: - Private methods
    private func makeId(from dataBeer: DataBeer) -> String {
        "\(dataBeer.name).\(dataBeer.category).\(dataBeer.style)".trimmingCharacters(in: .whitespaces)
    }
}
