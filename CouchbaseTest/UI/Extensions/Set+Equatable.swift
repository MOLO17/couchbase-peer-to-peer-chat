//
//  Set.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 26/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

extension Set where Element: Equatable {
    
    func toArray() -> [Element] {
        Array(self)
    }
}
