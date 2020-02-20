//
//  MasterDetailFlowCoordinatorProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

protocol MasterDetailFlowCoordinatorProtocol {
    
    // MARK: - Methods
    func toMaster()
    func toBeerMaster()
    func toDetail(person: Person)
    func toBeerDetail(beer: Beer)
    func toPeerToPeer()
}
