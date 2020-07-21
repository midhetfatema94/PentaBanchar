//
//  User.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/2/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation

enum UserType: String {
    case client = "client"
    case service = "service"
}

class User {
    var id: String = ""
    var username: String?
    var email: String?
    var userType: UserType?
    
    init(userDetails: [String: Any]) {
        id = userDetails["id"] as? String ?? ""
        username = userDetails["username"] as? String
        email = userDetails["email"] as? String
        userType = UserType(rawValue: (userDetails["type"] as? String ?? "").lowercased())
    }
}
