//
//  MasterDetailFlowCoordinator.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

class MasterDetailFlowCoordinator: FlowCoordinatorProtocol {
    
    typealias Factory = MasterFactory &
                        DetailFactory
    
    
    // MARK: - Private attributes
    private var _initialViewController: UIViewController!
    private let factory: Factory
    private weak var rootFlowCoordinator: RootFlowCoordinatorProtocol?
    
    
    // MARK: - Attributes
    var initialViewController: UIViewController {
        get { _initialViewController }
    }
    
    
    // MARK: - Methods
    init(factory: Factory, rootFlowCoordinator: RootFlowCoordinatorProtocol) {
        
        self.factory = factory
        self.rootFlowCoordinator = rootFlowCoordinator
        
        let vm = factory.makeMasterViewModel(masterDetailCoordinator: self)
        let vc = factory.makeMasterViewController(viewModel: vm)
        _initialViewController = vc
    }
    
    func start() {
    }
    
    
}

extension MasterDetailFlowCoordinator: MasterDetailFlowCoordinatorProtocol {

    func toMaster() {
        self.rootFlowCoordinator?.toMaster()
    }
    
    func toBeerMaster() {
        self.rootFlowCoordinator?.toBeerMaster()
    }
    
    func toDetail(person: Person) {
        self.rootFlowCoordinator?.toDetail(person: person)
    }
    
    func toBeerDetail(beer: Beer) {
        self.rootFlowCoordinator?.toBeerDetail(beer: beer)
    }
    
    func toPeerToPeer() {
        self.rootFlowCoordinator?.toPeerToPeer()
    }
}
