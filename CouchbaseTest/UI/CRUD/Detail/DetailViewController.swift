//
//  DetailViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 15/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Private attributes
    private let viewModel: DetailViewModel
    private var isEdit = false
    private let formatter: DateFormatter = {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter
    }()
    
    private lazy var editBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        button.possibleTitles = Set(["Edit","Save"])
        return button
    }()
    
    private lazy var containerStackView: UIStackView = {
       
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .fillEqually
        return s
    }()
    
    private var leadingColumn: UIStackView {
        
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.distribution = .fillEqually
        
        s.addArrangedSubview(self.surnameLabel)
        s.addArrangedSubview(self.nameLabel)
        s.addArrangedSubview(self.mailLabel)
        s.addArrangedSubview(self.dateLabel)
        return s
    }
    
    private var trailingColumn: UIStackView {
        
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.distribution = .fillEqually
        
        s.addArrangedSubview(self.surnameValueTextField)
        s.addArrangedSubview(self.nameValueTextField)
        s.addArrangedSubview(self.mailValueTextField)
        s.addArrangedSubview(self.dateValueLabel)
        return s
    }
    
    var valueTextField: UITextField {
        
        let l = UITextField()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 17)
        l.isUserInteractionEnabled = false
        l.delegate = self
        return l
    }
    
    private lazy var surnameLabel: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Surname:"
        return l
    }()
    
    private lazy var surnameValueTextField: UITextField = {
        
        let surname = valueTextField
        surname.placeholder = "Surname"
        surname.returnKeyType = .next
        return surname
    }()
    
    private lazy var nameLabel: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Name:"
        return l
    }()
    
    private lazy var nameValueTextField: UITextField = {
        
        let name = valueTextField
        name.placeholder = "Name"
        name.returnKeyType = .done
        return name
    }()
    
    private lazy var mailLabel: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Mail:"
        return l
    }()
    
    private lazy var mailValueTextField: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 17)
        return l
    }()
    
    private lazy var dateLabel: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Member since:"
        return l
    }()
    
    private lazy var dateValueLabel: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 17)
        return l
    }()
    
    var detail: Person? {
        didSet {
            self.surnameValueTextField.text = detail?.surname
            self.nameValueTextField.text = detail?.name
            self.mailValueTextField.text = detail?.mail
            self.dateValueLabel.text = formatter.string(from: detail?.creationDate ?? Date())
        }
    }

    
    // MARK: - Methods
    init(viewModel: DetailViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItems = [self.editBarButton]
    }
    
    
    // MARK: - Private methods
    private func setupViews() {
        
        self.view.addSubview(self.containerStackView)
        self.containerStackView.addArrangedSubview(self.leadingColumn)
        self.containerStackView.addArrangedSubview(self.trailingColumn)
    }
    
    private func setupConstraints() {
        
        let topSafeArea: CGFloat = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 0
        let topInset = (self.navigationController?.navigationBar.bounds.height ?? 0) + topSafeArea
            
            self.containerStackView.topToSuperview(offset: 8 + topInset)
            self.containerStackView.leadingToSuperview(offset: 8)
            self.containerStackView.trailingToSuperview(offset: 8)
            self.containerStackView.bottomToSuperview(offset: -8, relation: .equalOrLess)
    }
    
    @objc private func editButtonTapped() {
        
        self.isEdit = !self.isEdit
        if self.isEdit == true {
            
            self.surnameValueTextField.isUserInteractionEnabled = true
            self.nameValueTextField.isUserInteractionEnabled = true
            self.editBarButton.title = "Save"
            self.surnameValueTextField.becomeFirstResponder()
        } else {
            
            if let person = self.detail,
                let newPerson = self.preparePersonToBeSaved(person: person) {
                
                self.viewModel.updatePerson(person: newPerson)
                self.surnameValueTextField.isUserInteractionEnabled = false
                self.nameValueTextField.isUserInteractionEnabled = false
                self.editBarButton.title = "Edit"
                self.resignFirstResponder()
            }
        }
    }
    
    private func preparePersonToBeSaved(person: Person) -> Person? {
        
        if let name = nameValueTextField.text, !name.isEmpty,
            let surname = surnameValueTextField.text, !surname.isEmpty {
            return Person(name: name, surname: surname, mail: person.mail, creationDate: person.creationDate)
        }
        self.navigationController?.present(makeErrorAlertController(), animated: true)
        return nil
    }
    
    private func makeErrorAlertController() -> UIAlertController {
        
        let alert = UIAlertController(title: "Error", message: "One or more field left blank.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        
        alert.addAction(okAction)
        return alert
    }
}

protocol DetailFactory {
    
    func makeDetailViewController(viewModel: DetailViewModel) -> DetailViewController
    func makeDetailViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> DetailViewModel
}

extension DetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
