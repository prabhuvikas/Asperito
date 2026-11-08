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
        app.buttons["Hide overlay"].tap()
        XCTAssertTrue(app.buttons["Show overlay"].exists)
        app.buttons["Show overlay"].tap()
        XCTAssertTrue(app.buttons["Hide overlay"].exists)
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
    func testSettingsPrivacyAndGuidePersistence() {
        let app = launch()
        let initiallyVisible = app.buttons["Hide overlay"].exists
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 10))
        let toggle = app.switches["Show guide"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.tap()
        // Check the camera's behavior rather than UIKit accessibility's
        // switch "value", which is unreliable in some Simulator runtimes.
        app.buttons["Privacy policy"].tap()
        XCTAssertTrue(app.staticTexts["Asperito Privacy"].waitForExistence(timeout: 8))
        app.buttons["Done"].tap()
        app.buttons["Done"].tap()
        let expectedButton = initiallyVisible ? "Show overlay" : "Hide overlay"
        XCTAssertTrue(app.buttons[expectedButton].waitForExistence(timeout: 8),
                      "Changing the Settings toggle must update the camera overlay")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons[expectedButton].waitForExistence(timeout: 10),
                      "Guide visibility must persist across app launches")
    }
    func testOfflineTutorialRenders() {
        let app = launch("tutorial")
        XCTAssertTrue(app.staticTexts["Golden Spiral"].waitForExistence(timeout: 10))
    }
}
