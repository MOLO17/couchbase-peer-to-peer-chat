//
//  RootViewController.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 22/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

final class RootViewController: UIViewController {
    
    // MARK: - Private attributes
    private let rootCoordinator: RootFlowCoordinatorProtocol
    
    private lazy var containerStackView: UIView = {
    
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.distribution = .fillEqually
        s.spacing = UIScreen.main.bounds.height / 4
        
        s.addArrangedSubview(self.CRUDButton)
        s.addArrangedSubview(self.peerToPeerButton)
        return s
    }()
    
    private lazy var peerToPeerButton: UIButton = {
        
        let b = UIButton()
        b.setTitle("PeerToPeer", for: UIControl.State())
        b.setTitleColor(.systemBlue, for: UIControl.State())
        b.addTarget(self, action: #selector(peerButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var CRUDButton: UIButton = {
    
        let b = UIButton()
        b.setTitle("CRUD", for: UIControl.State())
        b.setTitleColor(.systemBlue, for: UIControl.State())
        b.addTarget(self, action: #selector(CRUDButtonTapped), for: .touchUpInside)
        return b
    }()
    
    
    // MARK: - Methods
    init(rootCoordinator: RootFlowCoordinatorProtocol) {
        self.rootCoordinator = rootCoordinator
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
    
    
    // MARK: - Private methods
    private func setupViews() {
        
        self.view = UIView()
        self.view.backgroundColor = .white
        self.view.addSubview(self.containerStackView)
    }
    
    private func setupConstraints() {
        
        self.containerStackView.centerInSuperview()
        self.containerStackView.topToSuperview(offset: 8, relation: .equalOrGreater, usingSafeArea: true)
        self.containerStackView.leadingToSuperview(offset: 8)
        self.containerStackView.trailingToSuperview(offset: 8)
        self.containerStackView.bottomToSuperview(offset: -8, relation: .equalOrLess, usingSafeArea: true)
    }
    
    @objc private func peerButtonTapped() {
        self.rootCoordinator.toPeerToPeer()
    }
    
    @objc private func CRUDButtonTapped() {
        self.rootCoordinator.toMaster()
    }
}
