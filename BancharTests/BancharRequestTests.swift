//
//  BancharRequestTests.swift
//  BancharTests
//
//  Created by Midhet Sulemani on 7/22/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import XCTest
import Firebase

@testable import Banchar

class BancharRequestTests: XCTestCase {
    
    let sut = RequestViewModel()
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testInitRequest() {
        let data: [String: Any] = ["clientUserId": "hRv1xrq940vADTH7tfr4",
                                   "serviceUserId": "BnJRusqc5W1ErQDm99Mq",
                                   "orderId": "1mqniwOiN3sjN2WIcMzl",
                                   "location": GeoPoint(latitude: 51.50998, longitude: -0.1337),
                                   "serverLocation": GeoPoint(latitude: 19.0176147, longitude: 72.8561644),
                                   "address": "Salmiya, Kuwait",
                                   "description": "Lots of decription for problem",
                                   "problem": "Battery died",
                                   "cost": Float(10.5),
                                   "status": "completed",
                                   "displayStatus": "success",
                                   "type": "pickup",
                                   "declinedBy": ["V97gRTtTrU1rvSErkEQO"],
                                   "rating": Float(3.5),
                                   "review": "Nice review!"]
        
        let orderModel = RequestOrder(details: data)
        XCTAssertEqual(orderModel.clientUserId, "hRv1xrq940vADTH7tfr4")
        XCTAssertEqual(orderModel.serviceUserId, "BnJRusqc5W1ErQDm99Mq")
        XCTAssertEqual(orderModel.id, "1mqniwOiN3sjN2WIcMzl")
        XCTAssertEqual(orderModel.lat, 51.50998)
        XCTAssertEqual(orderModel.long, -0.1337)
        XCTAssertEqual(orderModel.serviceLat, 19.0176147)
        XCTAssertEqual(orderModel.serviceLong, 72.8561644)
        XCTAssertEqual(orderModel.address, "Salmiya, Kuwait")
        XCTAssertEqual(orderModel.problem, "Battery died")
        XCTAssertEqual(orderModel.description, "Lots of decription for problem")
        XCTAssertEqual(orderModel.cost, 10.5)
        XCTAssertEqual(orderModel.status, .completed)
        XCTAssertEqual(orderModel.displayStatus, .success)
        XCTAssertEqual(orderModel.type, .pickup)
        XCTAssertEqual(orderModel.declinedIds, ["V97gRTtTrU1rvSErkEQO"])
        XCTAssertEqual(orderModel.rating, 3.5)
        XCTAssertEqual(orderModel.review, "Nice review!")
        
        let requestVM = RequestViewModel(data: orderModel)
        requestVM.userType = .client
        XCTAssertEqual(requestVM.clientUserId, "hRv1xrq940vADTH7tfr4")
        XCTAssertEqual(requestVM.serviceUserId, "BnJRusqc5W1ErQDm99Mq")
        XCTAssertEqual(requestVM.orderId, "1mqniwOiN3sjN2WIcMzl")
        XCTAssertEqual(requestVM.clientLocation?.lat, 51.50998)
        XCTAssertEqual(requestVM.clientLocation?.long, -0.1337)
        XCTAssertEqual(requestVM.serverLocation?.lat, 19.0176147)
        XCTAssertEqual(requestVM.serverLocation?.long, 72.8561644)
        XCTAssertEqual(requestVM.address, "Salmiya, Kuwait")
        XCTAssertEqual(requestVM.addressStr, "Address: Salmiya, Kuwait")
        XCTAssertEqual(requestVM.problem, "Battery died")
        XCTAssertEqual(requestVM.description, "Lots of decription for problem")
        XCTAssertEqual(requestVM.cost, 10.5)
        XCTAssertEqual(requestVM.price, "Cost: 10.5 KD")
        XCTAssertEqual(requestVM.reqStatus, .completed)
        XCTAssertEqual(requestVM.dispStatus, .success)
        XCTAssertEqual(requestVM.requestType, "pickup")
        XCTAssertEqual(requestVM.declinedIds, ["V97gRTtTrU1rvSErkEQO"])
        XCTAssertEqual(requestVM.rating, 3.5)
        XCTAssertEqual(requestVM.review, "Nice review!")
        XCTAssertEqual(requestVM.statusString, "Status: Success")
        XCTAssertEqual(requestVM.userType, .client)
    }
    
    func testValidateAllFields() {
        sut.address = "Salmiya, Kuwait"
        sut.problem = "Car broke down"
        XCTAssertTrue(sut.validateAllFields())
        
        sut.address = "Salmiya, Kuwait"
        sut.problem = ""
        XCTAssertFalse(sut.validateAllFields())
        
        sut.address = "Salmiya, Kuwait"
        sut.problem = nil
        XCTAssertFalse(sut.validateAllFields())
        
        sut.address = ""
        sut.problem = "Car broke down"
        XCTAssertFalse(sut.validateAllFields())
        
        sut.address = nil
        sut.problem = "Car broke down"
        XCTAssertFalse(sut.validateAllFields())
    }
    
    func testValidateAddress() {
        sut.address = "Salmiya, Kuwait"
        XCTAssertTrue(sut.validateAddress())
        
        sut.address = ""
        XCTAssertFalse(sut.validateAddress())
        
        sut.address = nil
        XCTAssertFalse(sut.validateAddress())
    }
    
    func testValidateProblem() {
        sut.problem = "Car broke down"
        XCTAssertTrue(sut.validateProblem())
        
        sut.problem = ""
        XCTAssertFalse(sut.validateProblem())
        
        sut.problem = nil
        XCTAssertFalse(sut.validateProblem())
    }
    
    func testValidateCarDetails() {
        sut.carDetails = RequestCarDetails()
        sut.carDetails?.modelName = "Chevrolet Camaro"
        XCTAssertEqual(sut.getCarModel(), "Chevrolet Camaro")
        
        sut.carDetails?.plate = "MH01CP8968"
        XCTAssertEqual(sut.getCarPlate(), "MH01CP8968")
        
        sut.carDetails?.imageUrlStr = "https://github.com/midhetfatema94"
        XCTAssertEqual(sut.getCarImageUrl(), "https://github.com/midhetfatema94")
        
        let carParams: [String: Any] = ["manufacturer": "Chevrolet",
                                        "model": "Camaro",
                                        "licensePlate": "MH01CP8968",
                                        "imageUrl": "https://github.com/midhetfatema94"]
        sut.carDetails = RequestCarDetails(data: carParams)
        XCTAssertEqual(sut.carDetails?.modelName, "Chevrolet Camaro")
        XCTAssertEqual(sut.carDetails?.plate, "MH01CP8968")
        XCTAssertEqual(sut.carDetails?.imageUrlStr, "https://github.com/midhetfatema94")
    }
}
