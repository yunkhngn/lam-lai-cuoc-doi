//
//  La_m_la_i_cuo__c__o__iUITestsLaunchTests.swift
//  Làm lại cuộc đờiUITests
//
//  Created by Khoa Nguyễn on 19/01/2026.
//

import XCTest

final class La_m_la_i_cuo__c__o__iUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
