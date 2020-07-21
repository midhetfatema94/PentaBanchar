//
//  ServiceUser.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/2/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation

class Service: User {
    var rating: Float?
    
    override init(userDetails: [String: Any]) {
        super.init(userDetails: userDetails)
        
        rating = userDetails["overallRating"] as? Float
    }
}
