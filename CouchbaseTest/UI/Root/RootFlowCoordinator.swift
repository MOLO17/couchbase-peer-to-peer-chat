//
//  RootFlowCoordinator.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import MultipeerConnectivity
import Foundation
import UIKit

class RootFlowCoordinator: FlowCoordinatorProtocol {
    
    // MARK: - Private attributes
    private var _initialViewController: UIViewController!
    private let factory: FactoryProtocol
    private var masterDetailCoordinator: MasterDetailFlowCoordinator!
    private var peerToPeerCoordinator: PeerToPeerFlowCoordinator!
    private lazy var currentVC = self._initialViewController
    
    
    // MARK: - Attributes
    var initialViewController: UIViewController {
        get { _initialViewController }
    }
    
    
    // MARK: - Methods
    init(factory: FactoryProtocol) {
        
        self.factory = factory
        self.masterDetailCoordinator = MasterDetailFlowCoordinator(factory: ViewControllerDependencyResolver(factory: factory), rootFlowCoordinator: self)
        self.peerToPeerCoordinator = PeerToPeerFlowCoordinator(factory: ViewControllerDependencyResolver(factory: factory), rootFlowCoordinator: self)
        self._initialViewController =  UINavigationController(rootViewController: RootViewController(rootCoordinator: self))
    }
    
    func start() {
        
    }
    
    
    // MARK: - Private methods
}

extension RootFlowCoordinator: RootFlowCoordinatorProtocol {
     
    func toMaster() {
        
        if let nc = self.currentVC as? UINavigationController {
            
            if nc.topViewController is DetailViewController {
                nc.popViewController(animated: true)
            }
            else {
                let vm = self.factory.getMasterViewModel(masterDetailCoordinator: self.masterDetailCoordinator)
                let vc = self.factory.getMasterViewController(viewModel: vm)
                nc.pushViewController(vc, animated: true)
            }
        }
    }
    
    func toBeerMaster() {
        
        let vm = self.factory.getBeerMasterViewModel(masterDetailCoordinator: self.masterDetailCoordinator)
        let vc = self.factory.getBeerMasterViewController(viewModel: vm)
        
        if let nc = self.currentVC as? UINavigationController {
            if nc.topViewController is MasterViewController {
                nc.pushViewController(vc, animated: true)
            } else {
                
            }
        }
    }
    
    func toDetail(person: Person) {
        
        let vm = self.factory.getDetailViewModel(masterDetailCoordinator: self.masterDetailCoordinator)
        let vc = self.factory.getDetailViewController(viewModel: vm)
        vc.detail = person
        
        if let nc = self.currentVC as? UINavigationController {
            nc.pushViewController(vc, animated: true)
        }
    }
    
    func toBeerDetail(beer: Beer) {
        
        let vm = self.factory.getBeerDetailViewModel(masterDetailCoordinator: self.masterDetailCoordinator)
        let vc = self.factory.getBeerDetailViewController(viewModel: vm)
        vc.detail = beer
        
        if let nc = self.currentVC as? UINavigationController {
            nc.pushViewController(vc, animated: true)
        }
    }
    
    func toPeerToPeer() {
        
        let vm = self.factory.getMainPeerToPeerViewModel(peerToPeerCoordinator: self.peerToPeerCoordinator)
        let vc = self.factory.getMainPeerToPeerViewController(viewModel: vm)
        
        if let nc = self.currentVC as? UINavigationController {
            nc.pushViewController(vc, animated: true)
        }
    }
    
    func toChat() {
        
        let vm = self.factory.getChatPeerViewModel(peerToPeerCoordinator: self.peerToPeerCoordinator)
        let vc = self.factory.getChatPeerViewController(viewModel: vm)
        
        if let nc = self.currentVC as? UINavigationController {
            nc.pushViewController(vc, animated: true)
        }
    }
}
