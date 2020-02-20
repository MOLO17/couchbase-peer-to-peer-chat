//
//  Data.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 19/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

extension Data {
    
    // MARK: - Attributes
    var JSONDictionary: [String: Any]? {
        get {
            
            if let data = String(data: self, encoding: .isoLatin1)?.data(using: .utf8) {
                
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch {
                    print(error.localizedDescription)
                }
            }
            return nil
        }
    }
}
