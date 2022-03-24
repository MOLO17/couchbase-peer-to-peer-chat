//
//  ViewControllerDependencyResolver.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class ViewControllerDependencyResolver {
    
    private let factory: FactoryProtocol
    
    init(factory: FactoryProtocol) {
        self.factory = factory
    }
}

extension ViewControllerDependencyResolver: MasterFactory {
    
    func makeMasterViewController(viewModel: MasterViewModel) -> MasterViewController {
        self.factory.getMasterViewController(viewModel: viewModel)
    }
    
    func makeMasterViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> MasterViewModel {
        self.factory.getMasterViewModel(masterDetailCoordinator: masterDetailCoordinator)
    }
}

extension ViewControllerDependencyResolver: DetailFactory {
    
    func makeDetailViewController(viewModel: DetailViewModel) -> DetailViewController {
        self.factory.getDetailViewController(viewModel: viewModel)
    }
    
    func makeDetailViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> DetailViewModel {
        self.factory.getDetailViewModel(masterDetailCoordinator: masterDetailCoordinator)
    }
}

extension ViewControllerDependencyResolver: BeerMasterFactory {
    
    func makeBeerMasterViewController(viewModel: BeerMasterViewModel) -> BeerMasterViewController {
        self.factory.getBeerMasterViewController(viewModel: viewModel)
    }
    
    func makeBeerMasterViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> BeerMasterViewModel {
        self.factory.getBeerMasterViewModel(masterDetailCoordinator: masterDetailCoordinator)
    }
}

extension ViewControllerDependencyResolver: BeerDetailFactory {
    
    func makeBeerDetailViewController(viewModel: BeerDetailViewModel) -> BeerDetailViewController {
        self.factory.getBeerDetailViewController(viewModel: viewModel)
    }
    
    func makeBeerDetailViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> BeerDetailViewModel {
        self.factory.getBeerDetailViewModel(masterDetailCoordinator: masterDetailCoordinator)
    }
}

extension ViewControllerDependencyResolver: MainPeerToPeerFactory {
    
    func makeMainPeerToPeerViewController(viewModel: MainPeerToPeerViewModel) -> MainPeerToPeerViewController {
        self.factory.getMainPeerToPeerViewController(viewModel: viewModel)
    }
    
    func makeMainPeerToPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> MainPeerToPeerViewModel {
        self.factory.getMainPeerToPeerViewModel(peerToPeerCoordinator: peerToPeerCoordinator)
    }
}

extension ViewControllerDependencyResolver: ChatPeerFactory {
    
    func makeChatPeerViewController(viewModel: ChatPeerViewModel) -> ChatPeerViewController {
        self.factory.getChatPeerViewController(viewModel: viewModel)
    }
    
    func makeChatPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> ChatPeerViewModel {
        self.factory.getChatPeerViewModel(peerToPeerCoordinator: peerToPeerCoordinator)
    }
}
