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
                    for document in snapshot.documents {
                        print("\(document.documentID) => \(document.data())")
                        var userData = document.data()
                        if userData["email"] as? String == details["email"] as? String {
                            userData["userId"] = document.documentID
                            completionHandler(userData)
                        } else {
                            completionHandler("Could not find user")
                        }
                    }
                }
            }
        })
    }
    
    func signUp(details: [String: Any], completionHandler: @escaping ((String?, Bool) -> Void)) {
        getUserDetails(fieldName: "email", fieldValue: details["email"] as? String ?? "", completionHandler: {(result) in
            if (result as? RequestViewModel) == nil {
                self.getUserDetails(fieldName: "username", fieldValue: details["username"] as? String ?? "", completionHandler: {(result) in
                    if (result as? RequestViewModel) == nil {
                        var ref: DocumentReference? = nil
                        ref = self.db.collection("users").addDocument(data: details) {(error) in
                            if let err = error {
                                print("Error adding document: \(err)")
                                completionHandler(err.localizedDescription, false)
                            } else {
                                print("Document added with ID: \(ref?.documentID ?? "")")
                                completionHandler(ref?.documentID ?? "", true)
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
    
    func getUserDetails(fieldName: String, fieldValue: String, completionHandler: @escaping ((Any?) -> Void)) {
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
                }
            }
        })
    }
    
    func forgotPassword() {
        
    }
}
