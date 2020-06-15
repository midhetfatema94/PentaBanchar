//
//  NetworkService.swift
//  Banchar
//
//  Created by Midhet Sulemani on 4/2/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import Foundation
import Firebase

class WebService {
    static let shared = WebService()
    
    let db = Firestore.firestore()
    
    func loginUser(details: [String: Any], completionHandler: @escaping ((Any?) -> Void)) {
        db.collection("users").getDocuments(completion: {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err.localizedDescription)
            } else {
                if let snapshot = querySnapshot {
                    let loginUserSnapshot = snapshot.documents.filter {
                        let userData = $0.data()
                        return userData["email"] as? String == details["email"] as? String
                    }.first
                    if var loginUserDetails = loginUserSnapshot?.data() {
                        loginUserDetails["userId"] = loginUserSnapshot?.documentID ?? ""
                        completionHandler(loginUserDetails)
                    } else {
                        completionHandler("Could not find user")
                    }
                }
            }
        })
    }
    
    func signUp(userDetails: [String: Any], carDetails: [String: Any], completionHandler: @escaping ((String?, Bool) -> Void)) {
        getUserDetails(fieldName: "email", fieldValue: userDetails["email"] as? String ?? "", shouldSendCompletionOnFailure: true, completionHandler: {(result) in
            if (result as? RequestViewModel) == nil {
                self.getUserDetails(fieldName: "username", fieldValue: userDetails["username"] as? String ?? "", shouldSendCompletionOnFailure: true, completionHandler: {(result) in
                    if (result as? RequestViewModel) == nil {
                        var ref: DocumentReference? = nil
                        ref = self.db.collection("users").addDocument(data: userDetails) {(error) in
                            if let err = error {
                                print("Error adding document: \(err)")
                                completionHandler(err.localizedDescription, false)
                            } else {
                                print("Document added with ID: \(ref?.documentID ?? "")")
                                completionHandler(ref?.documentID ?? "", true)
                                self.setPrimaryCarDetails(userId: ref?.documentID ?? "", details: carDetails)
                            }
                        }
                    } else {
                        completionHandler("Username is not unique", false)
                    }
                })
            } else {
                completionHandler("Email id is not unique", false)
            }
        })
    }
    
    func setPrimaryCarDetails(userId: String, details: [String: Any]) {
        let userDocRef = db.collection("users").document(userId)
        var carDocRef: DocumentReference? = nil
        carDocRef = userDocRef.collection("cars").addDocument(data: details, completion: {(err) in
            if let error = err {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(carDocRef?.documentID ?? "")")
            }
        })
    }
    
    func getUserDetails(fieldName: String, fieldValue: String, shouldSendCompletionOnFailure: Bool, completionHandler: @escaping ((Any?) -> Void)) {
        let userDocRef = db.collection("users").whereField(fieldName, isEqualTo: fieldValue)
        userDocRef.getDocuments(completion: {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err.localizedDescription)
            } else {
                if let snapshot = querySnapshot, let document = snapshot.documents.first {
                    print("\(document.documentID) => \(document.data())")
                    var data = document.data()
                    data["orderId"] = document.documentID
                    let orderData = RequestOrder(details: data)
                    let orderModel = RequestViewModel(data: orderData)
                    completionHandler(orderModel)
                } else {
                    print("Document does not exist in cache")
                    if shouldSendCompletionOnFailure { completionHandler(nil) }
                }
            }
        })
    }
    
    func getCarDetails(userId: String, completionHandler: @escaping ((Any?) -> Void)) {
        let userDocRef = db.collection("users").document(userId)
        let carDocRef = userDocRef.collection("cars")
        carDocRef.getDocuments(completion: {(querySnapshot, err) in
            if let snapshot = querySnapshot, let primaryCarDetails = snapshot.documents.first {
                print("Car details: \(primaryCarDetails.data())")
                completionHandler(primaryCarDetails.data())
            } else if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err.localizedDescription)
            }
        })
    }
    
    func forgotPassword() {
        
    }
    
    func newWinchRequest(orderData: [String: Any], completionHandler: @escaping ((Any?) -> Void)) {
        let orderDocRef = db.collection("orders")
        orderDocRef.addDocument(data: orderData, completion: {(err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func getOrderRequests(userIdField: String, userId: String, completion: @escaping (([RequestViewModel]?) -> Void)) {
        let orderQuery = db.collection("orders").whereField(userIdField, isEqualTo: userId)
        orderQuery.getDocuments(completion: {(querySnapshot, err) in
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
}
