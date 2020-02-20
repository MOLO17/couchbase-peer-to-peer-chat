//
//  BeerDetailViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 20/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

class BeerDetailViewController: UIViewController {
    
    // MARK: - Private attributes
    private let viewModel: BeerDetailViewModel
    
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
        
        s.addArrangedSubview(self.categoryLabel)
        s.addArrangedSubview(self.abvLabel)
        s.addArrangedSubview(self.styleLabel)
        return s
    }
    
    private var trailingColumn: UIStackView {
        
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.distribution = .fillEqually
        
        s.addArrangedSubview(self.categoryValueTextField)
        s.addArrangedSubview(self.abvValueTextField)
        s.addArrangedSubview(self.styleValueLabel)
        return s
    }
    
    private var valueTextField: UITextField {
        
        let l = UITextField()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 17)
        l.isUserInteractionEnabled = false
        l.delegate = self
        return l
    }
    
    private lazy var titleLabel: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.boldSystemFont(ofSize: 21)
        return l
    }()
    
    private lazy var descriptionLabel: UILabel = {
        
        let description = UILabel()
        description.text = "Description"
        description.font = UIFont.italicSystemFont(ofSize: 18)
        description.numberOfLines = 0
        description.lineBreakMode = .byWordWrapping
        description.textAlignment = .center
        return description
    }()
    
    private lazy var categoryLabel: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Category: "
        return l
    }()
    
    private lazy var categoryValueTextField: UITextField = {

        let category = valueTextField
        category.placeholder = "Category"
        category.returnKeyType = .done
        return category
    }()
    
    private lazy var abvLabel: UILabel = {

        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Abv: "
        return l
    }()
    
    private lazy var abvValueTextField: UITextField = {
        
        let abv = valueTextField
        abv.placeholder = "Abv"
        return abv
    }()
    
    private lazy var styleLabel: UILabel = {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Style:"
        return l
    }()
    
    private lazy var styleValueLabel: UILabel = {
        
        let style = UILabel()
        style.font = UIFont.boldSystemFont(ofSize: 17)
        style.numberOfLines = 0
        style.lineBreakMode = .byWordWrapping
        return style
    }()
    
    var detail: Beer? {
        didSet {
            self.titleLabel.text = detail?.name
            self.descriptionLabel.text = detail?.description
            self.categoryValueTextField.text = detail?.category
            self.abvValueTextField.text = "\(detail?.abv ?? 0.0)"
            self.styleValueLabel.text = detail?.style
        }
    }

    
    // MARK - Methods
    init(viewModel: BeerDetailViewModel) {
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
    
    
    // MARK: - Private methods
    private func setupViews() {
        
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.descriptionLabel)
        self.view.addSubview(self.containerStackView)
        self.containerStackView.addArrangedSubview(self.leadingColumn)
        self.containerStackView.addArrangedSubview(self.trailingColumn)
    }
    
    private func setupConstraints() {
        
        let topSafeArea: CGFloat = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 0
        let topInset = (self.navigationController?.navigationBar.bounds.height ?? 0) + topSafeArea
        
        self.titleLabel.topToSuperview(offset: 8 + topInset)
        self.titleLabel.centerXToSuperview()
        
        self.descriptionLabel.topToBottom(of: self.titleLabel, offset: 8)
        self.descriptionLabel.leadingToSuperview(offset: 16)
        self.descriptionLabel.trailingToSuperview(offset: 16)
            
        self.containerStackView.topToBottom(of: self.descriptionLabel, offset: 16)
        self.containerStackView.leadingToSuperview(offset: 8)
        self.containerStackView.trailingToSuperview(offset: 8)
        self.containerStackView.bottomToSuperview(offset: -8, relation: .equalOrLess)
    }
}

protocol BeerDetailFactory {
    
    func makeBeerDetailViewController(viewModel: BeerDetailViewModel) -> BeerDetailViewController
    func makeBeerDetailViewModel(masterDetailCoordinator: MasterDetailFlowCoordinatorProtocol) -> BeerDetailViewModel
}

extension BeerDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
