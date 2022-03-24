//
//  Factory.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

class Factory: FactoryProtocol {
    
    static let shared = Factory()
    
    
    // MARK: - Repositories
    private var personRepository: PersonRepository?
    func getPersonRepository() -> PersonRepository {
        
        if let repo = self.personRepository { return repo }
        else {
            
            self.personRepository = PersonRepository()
            return personRepository!
        }
    }
    
    private var beerRepository: BeerRepository?
    func getBeerRepository() -> BeerRepository {
        
        if let repo = self.beerRepository { return repo } else {
            
            self.beerRepository = BeerRepository()
            return beerRepository!
        }
    }
    
    private var peerRepository: PeersRepository?
    func getPeersRepository() -> PeersRepository {
        
        if let repo = self.peerRepository { return repo } else {
            
            self.peerRepository = PeersRepository()
            return peerRepository!
        }
    }
    
    
    // MARK: - UseCases
    private var personUseCases: PersonUseCases?
    func getPersonUseCases() -> PersonUseCases {
        
        if let useCases = self.personUseCases { return useCases } else {
            
            self.personUseCases = PersonUseCases(personRepository: getPersonRepository())
            return self.personUseCases!
        }
    }
    
    private var beerUseCases: BeerUseCases?
    func getBeerUseCases() -> BeerUseCases {
        
        if let useCases = self.beerUseCases { return useCases } else {
            
            self.beerUseCases = BeerUseCases(beerRepository: getBeerRepository())
            return self.beerUseCases!
        }
    }
    
    private var peersUseCases: PeersUseCases?
    func getPeersUseCases() -> PeersUseCases {
        
        if let useCases = self.peersUseCases { return useCases } else {
            
            self.peersUseCases = PeersUseCases(peersRepository: getPeersRepository())
            return self.peersUseCases!
        }
    }
    
    
    // MARK: - ViewControllers
    // MARK: - Master
    func getMasterViewController(viewModel: MasterViewModel) -> MasterViewController {
        MasterViewController(viewModel: viewModel)
    }
    func getMasterViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> MasterViewModel {
        MasterViewModel(masterUseCases: self.getPersonUseCases(), masterDetailFlowCoordinator: masterDetailCoordinator)
    }
    func getBeerMasterViewController(viewModel: BeerMasterViewModel) -> BeerMasterViewController {
        BeerMasterViewController(viewModel: viewModel)
    }
    
    func getBeerMasterViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> BeerMasterViewModel {
        BeerMasterViewModel(beerUseCases: self.getBeerUseCases(), masterDetailFlowCoordinator: masterDetailCoordinator)
    }
    
    
    // MARK: - Detail
    func getDetailViewController(viewModel: DetailViewModel) -> DetailViewController {
        DetailViewController(viewModel: viewModel)
    }
    func getDetailViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> DetailViewModel {
        DetailViewModel(detailUseCases: self.getPersonUseCases(), masterDetailFlowCoordinator: masterDetailCoordinator)
    }
    func getBeerDetailViewController(viewModel: BeerDetailViewModel) -> BeerDetailViewController {
        BeerDetailViewController(viewModel: viewModel)
    }
    
    func getBeerDetailViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> BeerDetailViewModel {
        BeerDetailViewModel(beerUseCases: self.getBeerUseCases(), masterDetailFlowCoordinator: masterDetailCoordinator)
    }
    
    
    // MARK: - Peer
    func getMainPeerToPeerViewController(viewModel: MainPeerToPeerViewModel) -> MainPeerToPeerViewController {
        MainPeerToPeerViewController(viewModel: viewModel)
    }
    
    func getMainPeerToPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> MainPeerToPeerViewModel {
        MainPeerToPeerViewModel(peerToPeerCoordinator: peerToPeerCoordinator)
    }
    
    
    // MARK: - Chat
    func getChatPeerViewController(viewModel: ChatPeerViewModel) -> ChatPeerViewController {
        ChatPeerViewController(viewModel: viewModel)
    }
    
    func getChatPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> ChatPeerViewModel {
        ChatPeerViewModel(peerToPeerCoordinator: peerToPeerCoordinator, peersUseCases: self.getPeersUseCases())
    }
}
