//
//  Controllers.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 13/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit


func makeInfoAlert(title: String?, message: String) -> UIAlertController {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    return alert
}

func makeInvitationAlert(title: String?, message: String, peer: MCPeerID, handler: @escaping((Bool) -> Void)) -> UIAlertController {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
        handler(true)
    }
    let noAction = UIAlertAction(title: "No", style: .default) { _ in
        handler(false)
    }
    alert.addAction(yesAction)
    alert.addAction(noAction)
    return alert
}
