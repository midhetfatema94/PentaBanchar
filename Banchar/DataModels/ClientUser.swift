//
//  ClientUser.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/2/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation
import Firebase

class Client: User {
    var carDetails: CarDetails = CarDetails(details: [:])
    
    override init(userDetails: [String: Any]) {
        super.init(userDetails: userDetails)
    }
}

struct CarDetails {
    var model: String = ""
    var licensePlate: String = ""
    var manufacturer: String = ""
    
    init(details: [String: Any]) {
        
    }
}

struct RequestOrder {
    var clientUserId: String = ""
    var serviceUserId: String?
    var id: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    var address: String = ""
    var problem: String = ""
    var description: String = ""
    var cost: Float = 0.0
    var status: RequestStatus = .unknown
    var displayStatus: DisplayStatus = .unknown
    var type: RequestType = .service
    var declinedIds: [String] = []
    var rating: Float = 0.0
    var review = ""
    
    init(details: [String: Any]) {
        clientUserId = details["clientUserId"] as? String ?? ""
        serviceUserId = details["serviceUserId"] as? String
        id = details["orderId"] as? String ?? ""
        let geoLocation = details["location"] as? GeoPoint
        lat = geoLocation?.latitude ?? 0.0
        long = geoLocation?.longitude ?? 0.0
        address = details["address"] as? String ?? ""
        description = details["description"] as? String ?? ""
        problem = details["problem"] as? String ?? ""
        cost = details["cost"] as? Float ?? 0
        status = RequestStatus(rawValue: (details["status"] as? String ?? "").lowercased()) ?? .processing
        displayStatus = DisplayStatus(rawValue: (details["displayStatus"] as? String ?? "").lowercased()) ?? .processing
        type = RequestType(rawValue: (details["type"] as? String ?? "").lowercased()) ?? .service
        declinedIds = details["declinedBy"] as? [String] ?? []
        rating = details["rating"] as? Float ?? 0
        review = details["review"] as? String ?? ""
    }
}

enum RequestStatus: String {
    case processing = "processing"
    case completed = "completed"
    case active = "active"
    case unknown = "unknown"
}

enum DisplayStatus: String {
    case accepted = "accepted"
    case success = "success"
    case cancelled = "cancelled"
    case processing = "processing"
    case unknown = ""
}

enum RequestType: String {
    case service = "service"
    case pickup = "pickup"
}
