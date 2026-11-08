import XCTest

/// Runs actual app screens on the Simulator, using its deterministic camera
/// fixture. Physical camera hardware and haptic feedback require device QA.
final class FrameGuideUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func launch(_ screen: String = "camera") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--asperito-screen=\(screen)"]
        app.launch()
        return app
    }
    func testCameraControlsAndOverlayVisibility() {
        let app = launch()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["Take photo"].exists)
        XCTAssertTrue(app.buttons["Switch camera"].exists)
        XCTAssertTrue(app.buttons["Exposure adjustment"].exists)
        XCTAssertTrue(app.buttons["Guides"].exists)
        XCTAssertTrue(app.buttons["Zoom controls"].exists)
        app.buttons["Hide overlay"].tap()
        XCTAssertTrue(app.buttons["Show overlay"].exists)
        app.buttons["Show overlay"].tap()
        XCTAssertTrue(app.buttons["Hide overlay"].exists)
    }
    func testCinematicMinimalZoomAndGuideControls() {
        let app = launch()
        XCTAssertTrue(app.buttons["Guides"].waitForExistence(timeout:15))
        XCTAssertTrue(app.buttons["Zoom controls"].exists)
        app.buttons["Zoom controls"].tap()
        XCTAssertTrue(app.sliders["Zoom"].waitForExistence(timeout:5))
        app.buttons["Zoom controls"].tap()
        XCTAssertFalse(app.sliders["Zoom"].exists)
        app.buttons["Guides"].tap()
        XCTAssertTrue(app.navigationBars["Composition guides"].waitForExistence(timeout:10))
    }

    func testAllEighteenPickerGuidesExist() {
        let app = launch("picker")
        for name in ["Rule of Thirds","Golden Ratio","Golden Spiral",
                     "Center Cross","Diagonal Guides","Square Grid","Horizon Level",
                     "Portrait Eye Line","Social Safe Area","Perspective Lines",
                     "Cinematic Frame","Custom Grid","Leading Lines","Symmetry & Reflection",
                     "Golden Triangle","Frame Within Frame","Negative Space","S-Curve"] {
            let guide = app.buttons["Choose \(name)"]
            var attempts = 0
            while !guide.exists && attempts < 12 {
                app.swipeUp()
                attempts += 1
            }
            XCTAssertTrue(guide.exists, "Missing \(name)")
        }
    }
    func testChooseGoldenSpiralAndOpenLesson() {
        let app = launch()
        app.buttons["Guides"].tap()
        XCTAssertTrue(app.navigationBars["Composition guides"].waitForExistence(timeout: 10))
        let guide = app.buttons["Choose Golden Spiral"]
        XCTAssertTrue(guide.waitForExistence(timeout: 10))
        guide.tap()
        XCTAssertTrue(app.buttons["Rotate spiral 90°"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        let learn = app.buttons.matching(NSPredicate(format:"label CONTAINS %@", "Learn")).firstMatch
        XCTAssertTrue(learn.waitForExistence(timeout: 8))
        learn.tap()
        XCTAssertTrue(app.staticTexts["Golden Spiral"].waitForExistence(timeout: 8))
    }
    func testSettingsPrivacyPolicyIsReachable() {
        let app = launch("settings")
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 10))
        let privacy = app.buttons["Privacy policy"]
        for _ in 0..<4 where !privacy.exists { app.swipeUp() }
        XCTAssertTrue(privacy.waitForExistence(timeout: 8))
        privacy.tap()
        XCTAssertTrue(app.staticTexts["Asperito Privacy"].waitForExistence(timeout: 8))
    }

    func testSettingsGuideVisibilityPersistsInCamera() {
        let app = launch()
        let initiallyVisible = app.buttons["Hide overlay"].exists
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 10))
        let toggle = app.switches["Show guide"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        app.buttons["Done"].tap()
        let expectedButton = initiallyVisible ? "Show overlay" : "Hide overlay"
        XCTAssertTrue(app.buttons[expectedButton].waitForExistence(timeout: 8),
                      "Changing Show guide in settings must update the actual camera UI")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons[expectedButton].waitForExistence(timeout: 10),
                      "Guide visibility must survive app termination and relaunch")
    }
    func testInCameraGestureAnimationAndReplay() {
        let app = launch("gesture")
        XCTAssertTrue(app.staticTexts["TWIST TWO FINGERS"].waitForExistence(timeout:15))
        XCTAssertTrue(app.staticTexts["Rotate the guide. Not the photo."].exists)
        XCTAssertTrue(app.buttons["Replay gesture animation"].exists)
        app.buttons["Replay gesture animation"].tap()
        XCTAssertTrue(app.staticTexts["TWIST TWO FINGERS"].exists)
        app.buttons["Try rotation gesture"].tap()
        XCTAssertFalse(app.staticTexts["TWIST TWO FINGERS"].exists)
        // The in-camera help entry point remains available after dismissal.
        XCTAssertTrue(app.buttons["Show rotation tutorial"].exists)
        app.buttons["Show rotation tutorial"].tap()
        XCTAssertTrue(app.staticTexts["TWIST TWO FINGERS"].waitForExistence(timeout:5))
        app.buttons["Close rotation tutorial"].tap()
        XCTAssertFalse(app.staticTexts["TWIST TWO FINGERS"].exists)
    }

    func testOfflineTutorialRenders() {
        let app = launch("tutorial")
        XCTAssertTrue(app.staticTexts["Golden Spiral"].waitForExistence(timeout: 10))
    }
}
