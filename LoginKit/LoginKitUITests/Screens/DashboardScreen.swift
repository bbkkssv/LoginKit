//
//  DashboardScreen.swift
//  LoginKit
//
//  Created by Andres de la Cruz on 10/7/26.
//
 
import XCTest

struct DashboardScreen {
    let app: XCUIApplication
    
    var welcomeLabel: XCUIElement { app.staticTexts["welcome_label"] }
    var logoutButton: XCUIElement { app.buttons["logout_button"] }
    
    @discardableResult
    func logout() -> Self {
        XCTAssertTrue(logoutButton.wait(until: "isEnabled == true"), "Logout button never became enabled")
        // Password AutoFill may cover the dashboard after a successful login.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let passwordPrompts = [app, springboard]
        let ready = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                self.logoutButton.isHittable || passwordPrompts.contains {
                    $0.buttons["Not Now"].exists && $0.staticTexts["Save Password?"].exists
                }
            },
            object: nil
        )
        guard XCTWaiter().wait(for: [ready], timeout: 5) == .completed else {
            XCTFail("Logout is blocked. App UI: " + app.debugDescription + "\nSystem UI: " + springboard.debugDescription)
            return self
        }
        for application in passwordPrompts {
            if application.staticTexts["Save Password?"].exists && application.buttons["Not Now"].exists {
                application.buttons["Not Now"].tap()
            }
        }
        XCTAssertTrue(logoutButton.waitUntilHittable(), "Logout button never became hittable")
        logoutButton.tap()
        return self
    }
}
