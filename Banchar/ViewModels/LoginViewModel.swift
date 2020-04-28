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
    
    var userCredentials: [String: Any] = [:]
    
    func login(credentials: [String: String], completion: @escaping ((Any?) -> Void)) {
        WebService.shared.loginUser(details: credentials) {[weak self] (response) in
            if let userDetails = response as? [String: Any] {
                self?.userCredentials = userDetails
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
                        self?.userCredentials = userDetails
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
        let userDoc = db.collection("users").document(userCredentials["userId"] as? String ?? "")
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
//        let docRef = db.collection("orders").document(userCredentials["userId"] as? String ?? "")
//        docRef.getDocument(completion: {(document, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                completion(nil)
//            } else {
//                if let document = document, document.exists {
//                    let dataDescription = document.data().map { RequestViewModel(data: RequestOrder(details: $0)) }
//                    print("Document data: \(dataDescription)")
//                }
//            }
//        })
    }
    
    func getUserDetails(userId: String, completionHandler: @escaping ((Any?) -> Void)) {
        db.collection("users").getDocuments(completion: {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err.localizedDescription)
            } else {
                if let snapshot = querySnapshot {
                    for document in snapshot.documents {
                        print("\(document.documentID) => \(document.data())")
                        var userData = document.data()
                        if document.documentID == userId {
                            userData["userId"] = document.documentID
                            completionHandler(userData)
                        } else {
                            completionHandler(nil)
                        }
                    }
                }
            }
        })
    }
}
