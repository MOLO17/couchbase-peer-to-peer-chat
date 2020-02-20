//
//  ChatMessage.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 17/02/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import Foundation

struct ChatMessage {
    
    let id: String
    let text: String
    let creatorId: String
    let messageType: MessageType
    let creationDate: Date
}

extension ChatMessage: Equatable {}
