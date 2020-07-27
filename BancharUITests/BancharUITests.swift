//
//  BancharUITests.swift
//  BancharUITests
//
//  Created by Midhet Sulemani on 3/26/20.
//  Copyright © 2020 Penta. All rights reserved.
//

import XCTest

@testable import Banchar

class BancharUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoginPage() {
        
        let emailTextField = app.textFields["emailTF"]
        let passwordTextField = app.secureTextFields["passwordTF"]
        
        emailTextField.tap()
        emailTextField.clearAndEnterText(text: "Midhet")
        
        passwordTextField.tap()
        passwordTextField.clearAndEnterText(text: "Sulemani")
        
        XCTAssertEqual(emailTextField.value as? String, "Midhet")
    }
    
    func testLocationNewRequest() {
        app.swipeLeft()
    }
}

extension XCUIElement {

    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }
}
