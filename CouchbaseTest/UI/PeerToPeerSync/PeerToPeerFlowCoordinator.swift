//
//  PeerToPeerFlowCoordinator.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 22/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

class PeerToPeerFlowCoordinator: FlowCoordinatorProtocol {

    typealias Factory = MainPeerToPeerFactory &
                        ChatPeerFactory
    
    
    // MARK: - Private attributes
    private var factory: Factory
    private weak var rootFlowCoordinator: RootFlowCoordinatorProtocol?
    private var _initialViewController: UIViewController!
    
    
    // MARK: - Attributes
    var initialViewController: UIViewController {
        get { _initialViewController }
    }
    
    
    // MARK: - Methods
    init(factory: Factory, rootFlowCoordinator: RootFlowCoordinatorProtocol) {
        
        self.factory = factory
        self.rootFlowCoordinator = rootFlowCoordinator
        
        let vm = self.factory.makeMainPeerToPeerViewModel(peerToPeerCoordinator: self)
        let vc = self.factory.makeMainPeerToPeerViewController(viewModel: vm)
        self._initialViewController = vc
    }
    
    func start() {
        
    }
}

extension PeerToPeerFlowCoordinator: PeerToPeerFlowCoordinatorProtocol {
    
    func toChat() {
        self.rootFlowCoordinator?.toChat()
    }
}
