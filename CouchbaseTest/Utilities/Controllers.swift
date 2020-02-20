//
//  Controllers.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 13/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit


func makeInfoAlert(title: String?, message: String) -> UIAlertController {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    return alert
}
