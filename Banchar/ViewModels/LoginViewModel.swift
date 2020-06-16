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
    
    func signUp(completion: @escaping ((Any?) -> Void)) {
        WebService.shared.signUp(userDetails: getPrimaryUserDetails(), carDetails: getPrimaryCarDetails(), completionHandler: {[weak self] (response, success) in
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
    
    func userLoggedInSuccess(vc: UIViewController?) {
        if let newRequestVC = vc?.storyboard?.instantiateViewController(identifier: "RequestHistoryViewController") as? RequestHistoryViewController {
            newRequestVC.userVM = self
            getAllRequests(completion: {response in
                if let result = response {
                    newRequestVC.requests = result
                    newRequestVC.updateTable()
                }
            })
            vc?.navigationController?.pushViewController(newRequestVC, animated: true)
        }
    }
    
    func forgotPassword() {
        
    }
    
    func getAllRequests(completion: @escaping (([RequestViewModel]?) -> Void)) {
        let field = userType == .client ? "clientUserId" : "serviceUserId"
        WebService.shared.getOrderRequests(userIdField: field, userId: userId ?? "", completion: {response in
            if let result = response {
                completion(result)
            } else {
                completion(nil)
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
    
    func getPrimaryUserDetails() -> [String: Any] {
        var details: [String: Any] = [:]
        details["userId"] = userId
        details["email"] = email
        details["password"] = password
        details["username"] = username
        details["type"] = userType?.rawValue
        return details
    }
    
    func getPrimaryCarDetails() -> [String: Any] {
        var details: [String: Any] = [:]
        details["licensePlate"] = primaryCarPlate
        let modelDetails = primaryCarModel?.components(separatedBy: " ")
        details["manufacturer"] = modelDetails?.first ?? ""
        details["model"] = modelDetails?.last ?? ""
        return details
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
