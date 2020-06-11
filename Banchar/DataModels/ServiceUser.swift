//
//  ServiceUser.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/2/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation

class Service: User {
    var rating: Double = 0.0
    
    override init(userDetails: [String: Any]) {
        super.init(userDetails: userDetails)
    }
}
