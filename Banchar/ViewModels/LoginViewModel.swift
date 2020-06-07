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
    var userType: UserType?
    var primaryCarPlate: String?
    var primaryCarModel: String?
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
        WebService.shared.signUp(details: credentials, completionHandler: {[weak self] (response, success) in
            if let documentId = response, success {
                self?.getUserDetails(userId: documentId, completionHandler: {(response) in
                    if let userDetails = response as? [String: Any] {
                        self?.setupViewModel(details: userDetails)
                        completion(userDetails)
                    } else {
                        completion(response as? String ?? "Failed to get user details")
                    }
                })
            } else if let error = response {
                completion(error)
            }
        })
    }
    
    func forgotPassword() {
        
    }
    
    func getAllRequests(completion: @escaping (([RequestViewModel]?) -> Void)) {
        let userDoc = db.collection("users").document(userId ?? "")
        userDoc.collection("orders").getDocuments(completion: {[weak self] (querySnapshot, err) in
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
                        data["userId"] = self?.userId ?? ""
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
        userType = UserType(rawValue: details["type"] as? String ?? "")
        if let id = self.userId {
            WebService.shared.getCarDetails(userId: id, completionHandler: {(response) in
                if let result = response as? [String: Any] {
                    self.primaryCarPlate = result["licensePlate"] as? String
                    self.primaryCarModel = "\(result["manufacturer"] as? String ?? "") \(result["model"] as? String ?? "")"
                }
            })
        }
        agreeTnc = true
    }
    
    func validateUsername() -> Bool {
        return !(username?.isEmpty ?? true)
    }
    
    func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func validatePassword() -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        if passwordPred.evaluate(with: password) {
            return password == repeatPassword
        }
        return false
    }
    
    func validateCarModel() -> Bool {
        return !(primaryCarModel?.isEmpty ?? true)
    }
    
    func validateLicensePlate() -> Bool {
        return !(primaryCarPlate?.isEmpty ?? true)
    }
    
    func validateTnC() -> Bool {
        return agreeTnc ?? false
    }
}
