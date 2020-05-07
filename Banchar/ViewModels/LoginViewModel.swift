//
//  LoginViewModel.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/2/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation
import Firebase

class LoginViewModel {
    
    let db = Firestore.firestore()
    
    var userId: String?
    var email: String?
    var username: String?
    var password: String?
    var repeatPassword: String?
    var sessionToken: String?
    var userType: String?
    var carPlate: String?
    var carModel: String?
    var agreeTnc: Bool?
    
    func login(credentials: [String: String], completion: @escaping ((Any?) -> Void)) {
        WebService.shared.loginUser(details: credentials) {[weak self] (response) in
            if let userDetails = response as? [String: Any] {
                self?.setupViewModel(details: userDetails) 
                completion(userDetails)
            } else {
                completion(response as? String ?? "Failed to login user")
            }
        }
    }
    
    func signUp(credentials: [String: String], completion: @escaping ((Any?) -> Void)) {
        WebService.shared.signUp(details: credentials, completionHandler: {[weak self] (response) in
            if let documentId = response as? String {
                self?.getUserDetails(userId: documentId, completionHandler: {(response) in
                    if let userDetails = response as? [String: Any] {
                        self?.setupViewModel(details: userDetails)
                        completion(userDetails)
                    } else {
                        completion(response as? String ?? "Failed to get user details")
                    }
                })
            } else if let error = response as? Error {
                completion(error.localizedDescription)
            }
        })
    }
    
    func forgotPassword() {
        
    }
    
    func getAllRequests(completion: @escaping (([RequestViewModel]?) -> Void)) {
        let userDoc = db.collection("users").document(userId ?? "")
        userDoc.collection("orders").getDocuments(completion: {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil)
            } else {
                if let snapshot = querySnapshot {
                    var allOrders: [RequestViewModel] = []
                    for document in snapshot.documents {
                        print("\(document.documentID) => \(document.data())")
                        var data = document.data()
                        data["orderId"] = document.documentID
                        let orderData = RequestOrder(details: data)
                        let orderModel = RequestViewModel(data: orderData)
                        allOrders.append(orderModel)
                    }
                    completion(allOrders)
                } else {
                    completion(nil)
                }
            }
        })
    }
    
    func getUserDetails(userId: String, completionHandler: @escaping ((Any?) -> Void)) {
        let userDocRef = db.collection("users").document(userId)
        userDocRef.getDocument(completion: {(document, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err.localizedDescription)
            } else {
                if let doc = document, doc.exists {
                    let dataDescription = doc.data()
                    print("Cached document data: \(dataDescription ?? [:])")
                    completionHandler(dataDescription ?? [:])
                } else {
                  print("Document does not exist in cache")
                }
            }
        })
    }
    
    func setupViewModel(details: [String: Any]) {
        userId = details["userId"] as? String
        email = details["email"] as? String
        password = details["password"] as? String
        repeatPassword = details["repeat"] as? String
//        var userType = ""
//        var carPlate = ""
//        var carModel = ""
//        var agreeTnc = false
    }
    
    func validateUsername() -> Bool {
        return false
    }
    
    func validateEmail() -> Bool {
        return false
    }
    
    func validatePassword() -> Bool {
        return false
    }
    
    func validateCarModel() -> Bool {
        return false
    }
    
    func validateLicensePlate() -> Bool {
        return false
    }
    
    func validateTnC() -> Bool {
        return false
    }
}
