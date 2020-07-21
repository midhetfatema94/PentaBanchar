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
