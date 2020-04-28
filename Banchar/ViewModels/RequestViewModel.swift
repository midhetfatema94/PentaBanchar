//
//  RequestViewModel.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/20/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation
import UIKit

class RequestViewModel {
    
    var userId: String!
    var location: (Double, Double)!
    var address: String!
    var problem: String!
    var price: String!
    var description: String!
    var statusImage: String!
    var statusString: String!
    
    convenience init(data: RequestOrder) {
        self.init()
        
        userId = data.id
        location = (data.lat, data.long)
        address = data.address
        problem = data.problem
        price = "\(data.cost) KD"
        description = data.description
        statusString = data.status.rawValue
    }
}
