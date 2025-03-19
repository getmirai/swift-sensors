import XCTest

final class SwiftSensorsAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Verify the app launches and the navigation title is displayed
        XCTAssertTrue(app.navigationBars["SwiftSensors"].exists)
        
        // Verify that the main sections exist
        XCTAssertTrue(app.staticTexts["Thermal Sensors"].exists)
        XCTAssertTrue(app.staticTexts["Memory Information"].exists)
        XCTAssertTrue(app.staticTexts["CPU Information"].exists)
        XCTAssertTrue(app.staticTexts["Disk Information"].exists)
        XCTAssertTrue(app.staticTexts["System"].exists)
    }
}