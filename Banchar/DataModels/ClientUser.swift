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
    var orders: [RequestOrder] = []
    
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
    var id: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    var address: String = ""
    var problem: String = ""
    var description: String = ""
    var cost: Float = 0.0
    var status: ServiceStatus = .unknown
    
    init(details: [String: Any]) {
        let geoLocation = details["location"] as? GeoPoint
        lat = geoLocation?.latitude ?? 0.0
        long = geoLocation?.longitude ?? 0.0
        address = details["address"] as? String ?? ""
        description = details["description"] as? String ?? ""
        problem = details["problem"] as? String ?? ""
        cost = Float(details["cost"] as? Int ?? 0)
        status = ServiceStatus(rawValue: (details["status"] as? String ?? "").capitalized) ?? .processing
    }
}

enum ServiceStatus: String {
    case processing = "Processing"
    case success = "Success"
    case cancelled = "Cancelled"
    case failed = "Failed"
    case unknown = "Unknown"
}
