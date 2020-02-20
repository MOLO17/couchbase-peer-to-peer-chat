//
//  ModelMapper.swift
//  CouchbaseTest
//
//  Created by Gabriele Nardi on 17/01/2020.
//  Copyright © 2020 MOLO17. All rights reserved.
//

import CouchbaseLiteSwift
import Foundation
import UIKit

class ModelMapper {
    
    // MARK: - Methods
    // MARK: - Person
    static func resultToPerson(result: Result) -> DataPerson {
        
        let dict = result.toDictionary()["db"] as? [String: Any]
        return DataPerson(
            name: dict?["name"] as? String ?? "Name",
            surname: dict?["surname"] as? String ?? "Surname",
            mail: dict?["mail"] as? String ?? "Mail",
            creationDate: dict?["creationDate"] as? Date ?? Date()
        )
    }
    
    static func documentToPerson(document: Document) -> DataPerson {
        
        DataPerson(
            name: document.string(forKey: "name") ?? "Name",
            surname: document.string(forKey: "surname") ?? "Surname",
            mail: document.string(forKey: "mail") ?? "Mail",
            creationDate: document.date(forKey: "creationDate") ?? Date()
        )
    }
    
    static func personToDocument(person: DataPerson) -> MutableDocument {
        
        let document = MutableDocument(id: person.mail)
        document.setString(person.surname, forKey: "surname")
        document.setString(person.name, forKey: "name")
        document.setString(person.mail, forKey: "mail")
        document.setDate(person.creationDate, forKey: "creationDate")
        return document
    }
    
    static func dataPersonToPerson(dataPerson: DataPerson) -> Person {
        Person(name: dataPerson.name, surname: dataPerson.surname, mail: dataPerson.mail, creationDate: dataPerson.creationDate)
    }
    
    static func personToDataPerson(person: Person) -> DataPerson {
        DataPerson(name: person.name, surname: person.surname, mail: person.mail, creationDate: person.creationDate)
    }
    
    
    // MARK: - Beer
    static func resultToBeer(result: Result) -> DataBeer {
        
        let dict = result.toDictionary()["beers.db"] as? [String: Any]
        return DataBeer(
            abv: dict?["abv"] as? Float ?? 0.0,
            breweryId: dict?["brewery_id"] as? String ?? "breweryId",
            category: dict?["category"] as? String ?? "category",
            description: dict?["description"] as? String ?? "description",
            ibu: dict?["ibu"] as? Int ?? 0,
            name: dict?["name"] as? String ?? "name",
            srm: dict?["srm"] as? Int ?? 0,
            style: dict?["style"] as? String ?? "style",
            type: dict?["type"] as? String ?? "type",
            upc: dict?["upc"] as? Int ?? 0,
            updated: dict?["updated"] as? Date ?? Date()
        )
    }
    
    static func documentToBeer(document: Document) -> DataBeer {
        
        DataBeer(
            abv: document.float(forKey: "abv"),
            breweryId: document.string(forKey: "brewery_id") ?? "brewery",
            category: document.string(forKey: "category") ?? "category",
            description: document.string(forKey: "description") ?? "description",
            ibu: document.int(forKey: "ibu"),
            name: document.string(forKey: "name") ?? "name",
            srm: document.int(forKey: "srm"),
            style: document.string(forKey: "style") ?? "style",
            type: document.string(forKey: "type") ?? "type",
            upc: document.int(forKey: "upc"),
            updated: document.date(forKey: "updated") ?? Date()
        )
    }
    
    static func dataBeerToBeer(dataBeer: DataBeer) -> Beer {
        Beer(abv: dataBeer.abv, breweryId: dataBeer.breweryId, category: dataBeer.category, description: dataBeer.description, ibu: dataBeer.ibu, name: dataBeer.name, srm: dataBeer.srm, style: dataBeer.style, type: dataBeer.type, upc: dataBeer.upc, updated: dataBeer.updated)
    }
    
    static func beerToDataBeer(beer: Beer) -> DataBeer {
        DataBeer(abv: beer.abv, breweryId: beer.breweryId, category: beer.category, description: beer.description, ibu: beer.ibu, name: beer.name, srm: beer.srm, style: beer.style, type: beer.type, upc: beer.upc, updated: beer.updated)
    }
    
    static func beerToDocument(dataBeer: DataBeer) -> MutableDocument {
        
        let document = MutableDocument(id: "\(dataBeer.name).\(dataBeer.category).\(dataBeer.style)".trimmingCharacters(in: .whitespaces))
        document.setFloat(dataBeer.abv, forKey: "abv")
        document.setString(dataBeer.breweryId, forKey: "brewery_id")
        document.setString(dataBeer.category, forKey: "category")
        document.setString(dataBeer.description, forKey: "description")
        document.setInt(dataBeer.ibu, forKey: "ibu")
        document.setString(dataBeer.name, forKey: "name")
        document.setInt(dataBeer.srm, forKey: "srm")
        document.setString(dataBeer.style, forKey: "style")
        document.setString(dataBeer.type, forKey: "type")
        document.setInt(dataBeer.upc, forKey: "upc")
        document.setDate(dataBeer.updated, forKey: "updated")
        return document
    }
    
    
    // MARK: - Chat
    static func resultsToDataChatMessage(result: Result) -> DataChatMessage {
        
        let dict = result.toDictionary()["peerToPeerSync"] as? [String: Any]
        return DataChatMessage(
            id: dict?["id"] as? String ?? "id",
            text: dict?["text"] as? String ?? "message",
            creatorId: dict?["creatorId"] as? String ?? "creatorId",
            creationDate: Formatters.dataMessageDateFormatter.date(from: dict?["creationDate"] as? String ?? "") ?? Date()
        )
    }
    
    static func dataChatMessageToMutableDocument(dataChatMessage: DataChatMessage) -> MutableDocument {
        
        MutableDocument(id: dataChatMessage.id,
                        data: ["id": dataChatMessage.id,
                               "text": dataChatMessage.text,
                               "creatorId": dataChatMessage.creatorId,
                               "creationDate": dataChatMessage.creationDate,
                               "type": "text"])
    }
    
    static func dataChatMessageToChatMessage(dataChatMessage: DataChatMessage) -> ChatMessage {
        
        ChatMessage(
            id: dataChatMessage.id,
            text: dataChatMessage.text,
            creatorId: dataChatMessage.creatorId,
            messageType: dataChatMessage.creatorId == UIDevice.current.identifierForVendor?.uuidString ? .sent : .received,
            creationDate: dataChatMessage.creationDate
        )
    }
    
    static func chatMessageToDataChatMessage(chatMessage: ChatMessage) -> DataChatMessage {
        
        DataChatMessage(
            id: chatMessage.id,
            text: chatMessage.text,
            creatorId: chatMessage.creatorId,
            creationDate: chatMessage.creationDate
        )
    }
}
