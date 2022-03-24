//
//  FactoryProtocol.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

protocol FactoryProtocol {
    
    // MARK: - Repositories
    func getPersonRepository() -> PersonRepository
    func getBeerRepository() -> BeerRepository
    
    
    // MARK: - UseCases
    func getPersonUseCases() -> PersonUseCases
    func getBeerUseCases() -> BeerUseCases
    
    
    // MARK: - ViewControllers
    // MARK: - Master
    func getMasterViewController(viewModel: MasterViewModel) -> MasterViewController
    func getMasterViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> MasterViewModel
    
    // MARK: - BeerMaster
    func getBeerMasterViewController(viewModel: BeerMasterViewModel) -> BeerMasterViewController
    func getBeerMasterViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> BeerMasterViewModel
    
    // MARK: - Detail
    func getDetailViewController(viewModel: DetailViewModel) -> DetailViewController
    func getDetailViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> DetailViewModel
    
    // MARK: - BeerDetail
    func getBeerDetailViewController(viewModel: BeerDetailViewModel) -> BeerDetailViewController
    func getBeerDetailViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> BeerDetailViewModel
    
    // MARK: - MainPeerToPeer
    func getMainPeerToPeerViewController(viewModel: MainPeerToPeerViewModel) -> MainPeerToPeerViewController
    func getMainPeerToPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> MainPeerToPeerViewModel
    
    // MARK: - Chat
    func getChatPeerViewController(viewModel: ChatPeerViewModel) -> ChatPeerViewController
    func getChatPeerViewModel(peerToPeerCoordinator: PeerToPeerFlowCoordinatorProtocol) -> ChatPeerViewModel
}
