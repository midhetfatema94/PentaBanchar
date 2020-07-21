//
//  BancharUserTests.swift
//  BancharUserTests
//
//  Created by Midhet Sulemani on 3/26/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import XCTest
import Firebase
@testable import Banchar

class BancharUserTests: XCTestCase {
    
    let sut = LoginViewModel()
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testClientUserModel() {
        let clientUserModelParams: [String: Any] = ["id": "hRv1xrq940vADTH7tfr4",
                                                    "email": "midhetfatema94@gmail.com",
                                                    "type": "client",
                                                    "username": "midhetfatema94"]
        
        let clientUserModel = Client(userDetails: clientUserModelParams)
        XCTAssertEqual(clientUserModel.id, "hRv1xrq940vADTH7tfr4")
        XCTAssertEqual(clientUserModel.email, "midhetfatema94@gmail.com")
        XCTAssertEqual(clientUserModel.userType, .client)
        XCTAssertEqual(clientUserModel.username, "midhetfatema94")
    }
    
    func testServerUserModel() {
        let serverUserModelParams: [String: Any] = ["id": "BnJRusqc5W1ErQDm99Mq",
                                                    "email": "sabihaaltaf@gmail.com",
                                                    "type": "service",
                                                    "username": "sabiha_altaf",
                                                    "overallRating": Float(4.5)]
        
        let serverUserModel = Service(userDetails: serverUserModelParams)
        XCTAssertEqual(serverUserModel.id, "BnJRusqc5W1ErQDm99Mq")
        XCTAssertEqual(serverUserModel.email, "sabihaaltaf@gmail.com")
        XCTAssertEqual(serverUserModel.userType, .service)
        XCTAssertEqual(serverUserModel.username, "sabiha_altaf")
        XCTAssertEqual(serverUserModel.rating, 4.5)
    }
    
    func testSetupLoginViewModel() {
        
        let clientUserModelParams: [String: Any] = ["userId": "hRv1xrq940vADTH7tfr4",
                                                    "email": "midhetfatema94@gmail.com",
                                                    "type": "client",
                                                    "username": "midhetfatema94"]
        
        sut.setupViewModel(details: clientUserModelParams)
        XCTAssertEqual(sut.userId, "hRv1xrq940vADTH7tfr4")
        XCTAssertEqual(sut.email, "midhetfatema94@gmail.com")
        XCTAssertEqual(sut.userType, .client)
        XCTAssertEqual(sut.username, "midhetfatema94")
    }

    func testGetPrimaryUserDetails() {
        
        sut.userId = "hRv1xrq940vADTH7tfr4"
        sut.email = "midhetfatema94@gmail.com"
        sut.password = ""
        sut.username = "midhetfatema94"
        sut.userType = .client
        let primaryDetailParams = sut.getPrimaryUserDetails()
        
        XCTAssertEqual(sut.userId, primaryDetailParams["userId"] as? String)
        XCTAssertEqual(sut.email, primaryDetailParams["email"] as? String)
        XCTAssertEqual(sut.userType?.rawValue, primaryDetailParams["type"] as? String)
        XCTAssertEqual(sut.username, primaryDetailParams["username"] as? String)
        XCTAssertEqual(sut.password, primaryDetailParams["password"] as? String)
    }
    
    func testGetPrimaryCarDetails() {
        
        sut.primaryCarPlate = "hRv1xrq940vADTH7tfr4"
        sut.primaryCarModel = "Chevrolet Camaro"
        let primaryDetailParams = sut.getPrimaryCarDetails()
        
        XCTAssertEqual(sut.primaryCarPlate, primaryDetailParams["licensePlate"] as? String)
        XCTAssertEqual("Chevrolet", primaryDetailParams["manufacturer"] as? String)
        XCTAssertEqual("Camaro", primaryDetailParams["model"] as? String)
    }
    
    func testUsernameValidation() {
        sut.username = "midhetfatema94"
        XCTAssertTrue(sut.validateUsername())
        
        sut.username = ""
        XCTAssertFalse(sut.validateUsername())
        
        sut.username = nil
        XCTAssertFalse(sut.validateUsername())
    }
    
    func testEmailValidation() {
        sut.email = "midhetfatema94@gmail.com"
        XCTAssertTrue(sut.validateEmail())
        
        sut.email = "midhetfatema94"
        XCTAssertFalse(sut.validateEmail())
        
        sut.email = ""
        XCTAssertFalse(sut.validateEmail())
        
        sut.email = nil
        XCTAssertFalse(sut.validateEmail())
    }
    
    func testPasswordValidation() {
        sut.password = "Midhet123!"
        sut.repeatPassword = "Midhet123!"
        XCTAssertTrue(sut.validatePassword())
        
        sut.password = "Midhet123"
        sut.repeatPassword = "Midhet123"
        XCTAssertFalse(sut.validatePassword())
        
        sut.password = "Midhet!!"
        sut.repeatPassword = "Midhet!!"
        XCTAssertFalse(sut.validatePassword())
        
        sut.password = "midhet123!"
        sut.repeatPassword = "midhet123!"
        XCTAssertFalse(sut.validatePassword())
        
        sut.password = "Mi123!"
        sut.repeatPassword = "Mi123!"
        XCTAssertFalse(sut.validatePassword())
        
        sut.password = "Midhet123!"
        sut.repeatPassword = "midhet123!"
        XCTAssertFalse(sut.validatePassword())
    }
    
    func testCarModelValidation() {
        sut.primaryCarModel = "Chevrolet Camaro"
        XCTAssertTrue(sut.validateCarModel())
        
        sut.primaryCarModel = ""
        XCTAssertFalse(sut.validateCarModel())
        
        sut.primaryCarModel = nil
        XCTAssertFalse(sut.validateCarModel())
    }
    
    func testCarPlateValidation() {
        sut.primaryCarPlate = "6TWC119"
        XCTAssertTrue(sut.validateLicensePlate())
        
        sut.primaryCarPlate = ""
        XCTAssertFalse(sut.validateLicensePlate())
        
        sut.primaryCarPlate = nil
        XCTAssertFalse(sut.validateLicensePlate())
    }
    
    func testTnCValidation() {
        sut.agreeTnc = false
        XCTAssertFalse(sut.validateTnC())
        
        sut.agreeTnc = nil
        XCTAssertFalse(sut.validateTnC())
        
        sut.agreeTnc = true
        XCTAssertTrue(sut.validateTnC())
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetUserDataServiceCall() {
        let db = Firestore.firestore()
        let promise = expectation(description: "Returned result data")
        
        db.collection("users").getDocuments(completion: {(querySnapshot, error) in
            if let err = error {
                XCTFail("Error: \(err.localizedDescription)")
                return
            } else {
                if querySnapshot != nil {
                    promise.fulfill()
                } else {
                  XCTFail("Result data is nil")
                }
            }
        })
        wait(for: [promise], timeout: 5)
    }
}
