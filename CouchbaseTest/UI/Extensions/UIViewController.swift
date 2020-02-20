//
//  UIViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 23/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: - Attributes
    var navigationViewController: UINavigationController? {
        get {
            if let nc = self.navigationController {
                return nc
            } else if UIApplication.shared.windows[0].rootViewController is UINavigationController,
                let nc = UIApplication.shared.windows[0].rootViewController as? UINavigationController {
                return nc
            }
            return nil
        }
    }
}
