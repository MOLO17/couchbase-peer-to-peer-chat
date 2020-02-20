//
//  BeerMaster.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 20/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

class BeerMasterViewController: UIViewController {
    
    // MARK: - Private attributes
    private let viewModel: BeerMasterViewModel
    private let reuseIdentifier = "BeerCell"
    private var categories: [String] = []
    private var beers: [Beer] = []
    private var filteredBeers: [Beer] = []
    private let refreshControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return r
    }()
    
    private lazy var addBeerAlert = AddBeerViewController()
    
    private lazy var searchViewController: UISearchController = {

    let searchVC = UISearchController(searchResultsController: nil)
        searchVC.obscuresBackgroundDuringPresentation = false
        searchVC.delegate = self
        searchVC.searchBar.delegate = self
        return searchVC
    }()
    
    private lazy var tableView: UITableView = {
        
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = .white
        t.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        t.rowHeight = UITableView.automaticDimension
        t.tableFooterView = UIView()
        t.refreshControl = self.refreshControl
        t.dataSource = self
        t.delegate = self
        return t
    }()
    
    private lazy var addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    
    
    // MARK: - Methods
    init(viewModel: BeerMasterViewModel) {
        
        self.viewModel = viewModel
        self.filteredBeers = beers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.view = UIView()
        self.view.backgroundColor = .white
        
        self.setupViews()
        self.setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.didUpdateValue = { [weak self] beer in
            
            guard let self = self else { return }
            
            if !self.categories.contains(beer.category) {
                self.categories.append(beer.category)
            }
            
            if !self.beers.contains(beer) {
                self.beers.append(beer)
                self.filteredBeers = self.beers
            }
            
            self.tableView.reloadData()
        }
        
        self.addBeerAlert.didTapOnSaveButton = { [weak self] beer in
            self?.viewModel.addBeer(beer: beer)
            self?.navigationController?.dismiss(animated: true)
        }
        self.addBeerAlert.didTapOnCancelButton = { [weak self] in
            self?.navigationController?.dismiss(animated: true)
        }
        self.addBeerAlert.isModalInPresentation = true
        
        self.navigationItem.searchController = self.searchViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItems = [self.addBarButtonItem]
        self.beers = self.viewModel.getBeers()
        self.filteredBeers = self.beers
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if beers.count != tableView.visibleCells.count {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Private methods
    private func setupViews() {
        self.view.addSubview(self.tableView)
    }
    
    private func setupConstraints() {
        self.tableView.edgesToSuperview()
    }
    
    @objc private func addButtonTapped() {
        self.navigationController?.present(self.addBeerAlert, animated: true)
    }
    
    @objc private func refreshData() {
        
        self.beers = self.viewModel.getBeers()
        self.filteredBeers = self.beers
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
}

protocol BeerMasterFactory {
    
    func makeBeerMasterViewController(viewModel: BeerMasterViewModel) -> BeerMasterViewController
    func makeBeerMasterViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> BeerMasterViewModel
}

extension BeerMasterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var set = Set<String>()
        beers.map { $0.category }.forEach { set.insert($0) }
        self.categories = Array(set).sorted(by: { $0.lowercased() < $1.lowercased() })
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        !self.filteredBeers.isEmpty ? self.filteredBeers.filter { $0.category == Array(self.categories)[section] }.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        let category = Array(categories)[indexPath.section]
        let beer = self.filteredBeers.filter { $0.category == category }.sorted(by: { $0.name < $1.name })[indexPath.row]
        cell.textLabel?.text = beer.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let container = UIView()
        container.backgroundColor = .systemGray6
        
        let l = UILabel()
        l.text = Array(self.categories)[section]
        l.font = UIFont.boldSystemFont(ofSize: 18)
        
        container.addSubview(l)
        l.edgesToSuperview(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        return container
    }
}

extension BeerMasterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = Array(self.categories)[indexPath.section]
        let beer = self.beers.filter { $0.category == category }.sorted(by: { $0.name < $1.name })[indexPath.row]
        self.viewModel.toDetail(beer: beer)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            let category = self.categories[indexPath.section]
            guard !category.isEmpty else { return }
            
            let beer = self.beers.filter { $0.category == category }[indexPath.row]
            self.viewModel.removeBeer(beer: beer)
            
            self.beers.removeAll(where: { $0 == beer } )
            self.filteredBeers.removeAll(where: { $0 == beer } )
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if (self.beers.filter { $0.category == category }.isEmpty) {
                self.categories.removeAll(where: { $0 == category })
                tableView.deleteSections(IndexSet(indexPath.section...indexPath.section), with: .automatic)
            }
            tableView.endUpdates()
        }
    }
}

extension BeerMasterViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            
            self.filteredBeers = self.beers
        } else {
            self.filteredBeers = self.beers.filter { $0.category.contains(searchText) || $0.name.contains(searchText) }
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filteredBeers = beers
    }
}
