//
//  FlowCoordinatorProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

protocol FlowCoordinatorProtocol {
    
    // MARK: - Attributes
    var initialViewController: UIViewController { get }
    
    
    // MARK: - Methods
    func start()
}
