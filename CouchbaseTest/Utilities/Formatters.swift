//
//  Formatters.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 17/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class Formatters {
    
    // MARK: - Attributes
    static let dataMessageDateFormatter: DateFormatter = {
       
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy HH:mm:sss"
        return df
    }()
    
    static let domainMessageDateFormatter: DateFormatter = {
       
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy HH:mm"
        return df
    }()
}
