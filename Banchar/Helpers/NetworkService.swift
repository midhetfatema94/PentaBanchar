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
        checkUser(fieldName: "email", fieldValue: userDetails["email"] as? String ?? "", completionHandler: {(userExists) in
            if !(userExists ?? true) {
                self.checkUser(fieldName: "username", fieldValue: userDetails["username"] as? String ?? "", completionHandler: {(exists) in
                    if !(exists ?? true) {
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
    
    func updateLocationToken(token: String, userId: String, completionHandler: ((Any?) -> Void)?) {
        let orderDocRef = db.collection("users").document(userId)
        orderDocRef.updateData(["locationToken": token], completion: {(err) in
            if let err = err {
                print("Error getting documents: \(err)")
                if let handler = completionHandler {
                    handler(err)
                }
            } else {
                if let handler = completionHandler {
                    handler(nil)
                }
            }
        })
    }
    
    func checkUser(fieldName: String, fieldValue: String, completionHandler: @escaping ((Bool?) -> Void)) {
        print("get user details", fieldName, fieldValue)
        let userDocRef = db.collection("users").whereField(fieldName, isEqualTo: fieldValue)
        userDocRef.getDocuments(completion: {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(nil)
            } else {
                if let snapshot = querySnapshot, snapshot.documents.count > 0 {
                    completionHandler(true)
                } else {
                    print("Document does not exist in cache")
                    completionHandler(false)
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
    
    func cancelServiceRequest(orderId: String, completionHandler: @escaping ((Any?) -> Void)) {
        let orderDocRef = db.collection("orders").document(orderId)
        orderDocRef.delete(completion: {(err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func acceptServiceRequest(orderId: String, serverId: String, completionHandler: @escaping ((Any?) -> Void)) {
        let orderDocRef = db.collection("orders").document(orderId)
        orderDocRef.updateData(["serviceUserId": serverId, "displayStatus": "accepted", "status": "active"], completion: {(err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func updateServerLocation(orderId: String, location: GeoPoint, completionHandler: ((Any?) -> Void)?) {
        let orderDocRef = db.collection("orders").document(orderId)
        orderDocRef.updateData(["serverLocation": location], completion: {(err) in
            if let err = err {
                print("Error getting documents: \(err)")
                if let handler = completionHandler {
                    handler(err)
                }
            } else {
                if let handler = completionHandler {
                    handler(nil)
                }
            }
        })
    }
    
    func getUpdatedServerLocation(orderId: String, completionHandler: @escaping ((Any?) -> Void)) {
        let orderDocRef = db.collection("orders").document(orderId)
        orderDocRef.getDocument(completion: {(querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(nil)
            } else {
                if let document = querySnapshot {
                    if let data = document.data() {
                        completionHandler(data["serverLocation"] as? GeoPoint)
                    }
                } else {
                    completionHandler(nil)
                }
            }
        })
    }
    
    func declineServiceRequest(orderId: String, declinedIds: [String], completionHandler: @escaping ((Any?) -> Void)) {
        let orderDocRef = db.collection("orders").document(orderId)
        orderDocRef.updateData(["declinedBy": declinedIds], completion: {(err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func winchRequestCompleted(orderId: String, completionHandler: @escaping ((Any?) -> Void)) {
        let orderDocRef = db.collection("orders").document(orderId)
        let updatedParams = ["displayStatus": "success", "status": "completed"]
        orderDocRef.updateData(updatedParams, completion: {(err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func updateRatingReview(orderId: String, rating: Float, review: String, completionHandler: @escaping ((Any?) -> Void)) {
        let orderDocRef = db.collection("orders").document(orderId)
        let updatedParams: [String : Any] = ["rating": rating, "review": review]
        orderDocRef.updateData(updatedParams, completion: {(err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(err)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func getOrderRequests(isWinch: Bool, userIdField: String, userId: String, completion: @escaping (([RequestViewModel]?) -> Void)) {
        var orderQuery: Query!
        if isWinch {
            orderQuery = db.collection("orders")
        } else {
            orderQuery = db.collection("orders").whereField(userIdField, isEqualTo: userId)
        }
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
                        let declineIds = data["declinedBy"] as? [String] ?? []
                        if isWinch {
                            if let winchId = data[userIdField] as? String {
                                if (winchId == userId || winchId.isEmpty) &&
                                    !declineIds.contains(userId) {
                                    allOrders.append(self.appendOrders(details: data))
                                }
                            }
                        } else {
                            allOrders.append(self.appendOrders(details: data))
                        }
                    }
                    completion(allOrders)
                } else {
                    completion(nil)
                }
            }
        })
    }
    
    func appendOrders(details: [String: Any]) -> RequestViewModel {
        let orderData = RequestOrder(details: details)
        let orderModel = RequestViewModel(data: orderData)
        return orderModel
    }
}
