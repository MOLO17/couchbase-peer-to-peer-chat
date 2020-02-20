//
//  MasterViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import TinyConstraints
import UIKit

class MasterViewController: UIViewController {
    
    // MARK: - Private attributes
    private let viewModel: MasterViewModel
    private let reuseIdentifier = "Cell"
    private var persons: [Person] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    private let refreshControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return r
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
    
    private lazy var beerButton: UIButton = {
       
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("\u{1F37A}", for: UIControl.State())
        b.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        b.addTarget(self, action: #selector(beerButtonTapped), for: .touchUpInside)
        b.width(42)
        b.height(42)
        return b
    }()
    
    
    // MARK: - Methods
    init(viewModel: MasterViewModel) {
        
        self.viewModel = viewModel
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
        
        self.viewModel.didUpdateValue = { [weak self] person in
            
            guard let self = self else { return }
            
            if !self.persons.contains(person) {
                self.persons.append(person)
            } else {
                if let rowIndex = self.persons.firstIndex(of: person) {
                    self.tableView.reloadRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItems = [self.addBarButtonItem]
        self.persons = self.viewModel.getPersons().sorted(by: { $0.surname < $1.surname })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.beerButton.layer.cornerRadius = self.beerButton.bounds.height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if persons.count != tableView.visibleCells.count {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Private methods
    private func setupViews() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.beerButton)
    }
    
    private func setupConstraints() {
        
        self.tableView.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8))
        self.tableView.bottomToTop(of: self.beerButton, offset: -8)
        
        self.beerButton.centerXToSuperview()
        self.beerButton.bottomToSuperview(offset: -8, usingSafeArea: true)
    }
    
    @objc private func addButtonTapped() {
        self.navigationController?.present(makeAddPersonAlertController(), animated: true)
    }
    
    @objc private func beerButtonTapped() {
        self.viewModel.toBeerMaster()
    }
    
    @objc private func peerToPeerButtonTapped() {
        self.viewModel.toPeerToPeer()
    }
    
    private func makeAddPersonAlertController() -> UIAlertController {
        
        let alert = UIAlertController(title: "Add a person", message: "Fill all the blank to add a person", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        if let surnameTextField = alert.textFields?[0] {
            surnameTextField.placeholder = "Surname"
        }
        if let nameTextField = alert.textFields?[1] {
            nameTextField.placeholder = "Name"
        }
        if let mailTextField = alert.textFields?[2] {
            mailTextField.placeholder = "Mail"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            
            if let surnameTextField = alert.textFields?[0],
                let nameTextField = alert.textFields?[1],
                let mailTextField = alert.textFields?[2],
                let surname = surnameTextField.text,
                let name = nameTextField.text,
                let mail = mailTextField.text {
            
                let person = Person(name: name, surname: surname, mail: mail, creationDate: Date())
                self?.viewModel.addPerson(person: person)
                alert.dismiss(animated: true) { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        return alert
    }
    
    @objc private func refreshData() {
        self.persons = self.viewModel.getPersons()
        self.refreshControl.endRefreshing()
    }
}

protocol MasterFactory {
    
    func makeMasterViewController(viewModel: MasterViewModel) -> MasterViewController
    func makeMasterViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> MasterViewModel
}

extension MasterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        !self.persons.isEmpty ? self.persons.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        let person = persons[indexPath.row]
        cell.textLabel?.text = "\(person.surname) \(person.name)"
        return cell
    }
}

extension MasterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let person = persons[indexPath.row]
        self.viewModel.toDetail(person: person)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            self.viewModel.removePerson(person: persons[indexPath.row])
            self.persons.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
    }
}
