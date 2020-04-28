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
    
    func signUp(details: [String: Any], completionHandler: @escaping ((Any?) -> Void)) {
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: details) {(error) in
            if let err = error {
                print("Error adding document: \(err)")
                completionHandler(err)
            } else {
                print("Document added with ID: \(ref?.documentID ?? "")")
                completionHandler(ref?.documentID ?? "")
            }
        }
    }
    
    func forgotPassword() {
        
    }
}
