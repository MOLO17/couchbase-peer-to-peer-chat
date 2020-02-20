//
//  AddBeerViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 21/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

final class AddBeerViewController: UIViewController {
    
    // MARK: - Private Attributes
    private let formatter: DateFormatter = {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter
    }()
    
    private lazy var containerView: UIView = {
        
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    private lazy var containerStackView: UIStackView = {
       
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .fillEqually
        return s
    }()
    
    private lazy var leadingColumn: UIStackView = {
        
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.distribution = .fillEqually
        
        s.addArrangedSubview(self.nameLabel)
        s.addArrangedSubview(self.descriptionLabel)
        s.addArrangedSubview(self.categoryLabel)
        s.addArrangedSubview(self.abvLabel)
        s.addArrangedSubview(self.brewerIdLabel)
        s.addArrangedSubview(self.ibuLabel)
        s.addArrangedSubview(self.srmLabel)
        s.addArrangedSubview(self.typeLabel)
        s.addArrangedSubview(self.styleLabel)
        s.addArrangedSubview(self.upcLabel)
        s.addArrangedSubview(self.updatedLabel)
        return s
    }()
    
    private lazy var trailingColumn: UIStackView = {
        
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.distribution = .fillEqually
        
        s.addArrangedSubview(self.nameTextField)
        s.addArrangedSubview(self.descriptionTextField)
        s.addArrangedSubview(self.categoryTextField)
        s.addArrangedSubview(self.abvTextField)
        s.addArrangedSubview(self.brewerIdTextField)
        s.addArrangedSubview(self.ibuTextField)
        s.addArrangedSubview(self.srmTextField)
        s.addArrangedSubview(self.typeTextField)
        s.addArrangedSubview(self.styleTextField)
        s.addArrangedSubview(self.upcTextField)
        s.addArrangedSubview(self.updatedTextField)
        return s
    }()
    
    private var label: UILabel {
        
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
    private var textField: UITextField {

        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
    
    private lazy var nameLabel: UILabel = {
       
        let l = label
        l.text = "Name: "
        return l
    }()
    
    private lazy var nameTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Name"
        return tf
    }()
    
    private lazy var descriptionLabel: UILabel = {
       
        let l = label
        l.text = "Description: "
        return l
    }()
    
    private lazy var descriptionTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Description"
        return tf
    }()
    
    private lazy var categoryLabel: UILabel = {
       
        let l = label
        l.text = "Category: "
        return l
    }()
    
    private lazy var categoryTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Category"
        return tf
    }()
    
    private lazy var abvLabel: UILabel = {
       
        let l = label
        l.text = "Abv: "
        return l
    }()
    
    private lazy var abvTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Abv"
        return tf
    }()
    
    private lazy var brewerIdLabel: UILabel = {
       
        let l = label
        l.text = "BrewerId: "
        return l
    }()
    
    private lazy var brewerIdTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "BrewerId"
        return tf
    }()
    
    private lazy var ibuLabel: UILabel = {
       
        let l = label
        l.text = "Ibu: "
        return l
    }()
    
    private lazy var ibuTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Ibu"
        return tf
    }()
    
    private lazy var srmLabel: UILabel = {
       
        let l = label
        l.text = "Srm: "
        return l
    }()
    
    private lazy var srmTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Srm"
        return tf
    }()
    
    private lazy var typeLabel: UILabel = {
       
        let l = label
        l.text = "Type: "
        return l
    }()
    
    private lazy var typeTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Type"
        return tf
    }()
    
    private lazy var styleLabel: UILabel = {
       
        let l = label
        l.text = "Style: "
        return l
    }()
    
    private lazy var styleTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Style"
        return tf
    }()
    
    private lazy var upcLabel: UILabel = {
       
        let l = label
        l.text = "Upc: "
        return l
    }()
    
    private lazy var upcTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "Upc"
        return tf
    }()
    
    private lazy var updatedLabel: UILabel = {
       
        let l = label
        l.text = "UpdatedDate: "
        return l
    }()
    
    private lazy var updatedTextField: UITextField = {
       
        let tf = textField
        tf.placeholder = "UpdatedDate"
        return tf
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.spacing = 16
        
        s.addArrangedSubview(self.saveButton)
        s.addArrangedSubview(self.cancelButton)
        return s
    }()
    
    private lazy var saveButton: UIButton = {
        
        let b = UIButton()
        b.setTitle("Save", for: UIControl.State())
        b.setTitleColor(.systemBlue, for: UIControl.State())
        b.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var cancelButton: UIButton = {
        
        let b = UIButton()
        b.setTitle("Cancel", for: UIControl.State())
        b.setTitleColor(.systemBlue, for: UIControl.State())
        b.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return b
    }()
    
    
    // MARK: - Attributes
    var didTapOnSaveButton: ((Beer) -> Void)?
    var didTapOnCancelButton: (() -> Void)?
    
    
    // MARK: - Methods
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.setupViews()
        self.setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.layer.cornerRadius = 10
    }
    
    
    // MARK: - Private Methods
    @objc private func saveButtonTapped() {
        
        let beer = Beer(
            abv: Float(self.abvTextField.text ?? "0.0") ?? 0.0,
            breweryId: self.brewerIdTextField.text ?? "",
            category: self.categoryTextField.text ?? "",
            description: self.descriptionTextField.text ?? "",
            ibu: Int(self.ibuTextField.text ?? "0") ?? 0,
            name: self.nameTextField.text ?? "",
            srm: Int(self.srmTextField.text ?? "0") ?? 0,
            style: self.styleTextField.text ?? "",
            type: self.typeTextField.text ?? "",
            upc: Int(self.upcTextField.text ?? "0") ?? 0,
            updated: self.formatter.date(from: self.updatedTextField.text ?? "01/01/2001'T'00:00:000") ?? Date()
        )
        
        self.didTapOnSaveButton?(beer)
    }
    
    @objc private func cancelButtonTapped() {
        self.didTapOnCancelButton?()
    }
    
    private func setupViews() {
        
        self.view = UIView()
        self.view.backgroundColor = UIColor.clear
        
        self.view.addSubview(self.containerView)
        self.containerView.addSubview(self.containerStackView)
        self.containerView.addSubview(self.buttonsStackView)
        self.containerStackView.addArrangedSubview(self.leadingColumn)
        self.containerStackView.addArrangedSubview(self.trailingColumn)
    }
    
    private func setupConstraints() {
        
        self.containerView.centerInSuperview()
        self.containerView.topToSuperview(offset: 8, relation: .equalOrGreater)
        self.containerView.leadingToSuperview(offset: 8, relation: .equalOrGreater)
        self.containerView.trailingToSuperview(offset: 8, relation: .equalOrGreater)
        self.containerView.bottomToSuperview(offset: -8, relation: .equalOrLess)
        
        self.containerStackView.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16))
        self.containerStackView.bottomToTop(of: self.buttonsStackView, offset: -16)
        
        self.buttonsStackView.leadingToSuperview(offset: 16, relation: .equalOrGreater)
        self.buttonsStackView.trailingToSuperview(offset: 16)
        self.buttonsStackView.bottomToSuperview(offset: -8, relation: .equalOrLess)
    }
}
