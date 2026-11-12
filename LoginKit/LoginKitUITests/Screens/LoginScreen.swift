//
//  LoginScreen.swift
//  LoginKit
//
//  Created by Andres de la Cruz on 10/7/26.
//

import XCTest

struct LoginScreen {
    let app: XCUIApplication
    
    var emailField: XCUIElement { app.textFields["email_field"] }
    var passwordField: XCUIElement { app.secureTextFields["password_field"] }
    var loginButton: XCUIElement { app.buttons["login_button"] }
    var errorLabel: XCUIElement { app.staticTexts["error_label"] }
    var rememberMe: XCUIElement { app.switches["remember_me_toggle"] }

    @discardableResult
    func login(email: String, password: String, rememberMe: Bool = false) -> Self {
        if rememberMe {
            setRememberMe(true)
        }
        replaceText(in: emailField, with: email)
        replaceText(in: passwordField, with: password)
        XCTAssertTrue(loginButton.wait(until: "isEnabled == true"))
        loginButton.tap()
        return self
    }
    
    private func replaceText(in field: XCUIElement, with text: String) {
        XCTAssertTrue(field.waitUntilHittable())
        field.tap()
        if let value = field.value as? String, value != field.placeholderValue, !value.isEmpty {
            // Secure fields expose bullets; their count still lets us delete the old password.
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
        }
        field.typeText(text)
    }

    @discardableResult
    func setRememberMe(_ on: Bool) -> Self {
        XCTAssertTrue(rememberMe.waitUntilHittable(), "Remember Me toggle never became hittable")
        let isOn = (rememberMe.value as? String) == "1"
        if isOn != on {
            rememberMe.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        }
        let expectedValue = on ? "1" : "0"
        XCTAssertTrue(rememberMe.wait(until: "value == '\(expectedValue)'"), "Remember Me did not reach the requested state")
        return self
    }
    
}
