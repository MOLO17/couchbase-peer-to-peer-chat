//
//  MessageTableViewCell.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 24/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation
import UIKit

enum MessageType: String {
    
    case sent = "sent"
    case received = "received"
}

class MessageTableViewCell: UITableViewCell {
    
    struct Layout {
        
        let text: String
        let type: MessageType
        let date: Date
    }
    
    
    // MARK: - Private attributes
    private lazy var containerView: UIView = {
       
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var messageLabel: UILabel = {
       
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints =  false
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        return l
    }()
    
    private lazy var dateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints =  false
        l.textColor = .lightGray
        l.font = UIFont.systemFont(ofSize: 12)
        return l
    }()
 
    
    // MARK: - Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.containerView.removeFromSuperview()
        self.accessoryType = .none
    }
    
    func setupCell(layout: Layout) {
        
        self.setupViews()
        self.setupConstraints()
        
        self.messageLabel.text = layout.text
        self.dateLabel.text = Formatters.domainMessageDateFormatter.string(from: layout.date)
        
        switch layout.type {
        case .sent:
            self.containerView.backgroundColor = .green
            self.messageLabel.textAlignment = .left
            self.containerView.trailingToSuperview(offset: 8)
            self.containerView.leadingToSuperview(offset: 8, relation: .equalOrGreater)
        case .received:
            self.containerView.backgroundColor = .cyan
            self.messageLabel.textAlignment = .left
            self.containerView.leadingToSuperview(offset: 8)
            self.containerView.trailingToSuperview(offset: 8, relation: .equalOrLess)
        }
    }
    
    
    // MARK: - Private methods
    private func setupViews() {
        
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.messageLabel)
        self.containerView.addSubview(self.dateLabel)
    }
    
    private func setupConstraints() {
        
        self.containerView.topToSuperview(offset: 8)
        self.containerView.bottomToSuperview(offset: -8)
        
        self.messageLabel.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8))
        
        self.dateLabel.topToBottom(of: self.messageLabel, offset: 8)
        self.dateLabel.leadingToSuperview(offset: 8)
        self.dateLabel.trailingToSuperview(offset: 8, relation: .equalOrLess)
        self.dateLabel.bottomToSuperview(offset: -8)
    }
}
