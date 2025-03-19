import XCTest
@testable import SwiftSensorsApp
import SwiftSensors

final class SwiftSensorsAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFormatterFunctions() throws {
        let formatter = SensorFormatter.shared
        
        // Test byte formatting
        let bytes = UInt64(1024 * 1024 * 1024) // 1 GB
        let formattedBytes = formatter.formatBytes(bytes)
        XCTAssertTrue(formattedBytes.contains("GB") || formattedBytes.contains("GiB"))
        
        // Test percentage formatting
        let percentage = 45.5
        let formattedPercentage = formatter.formatPercentage(percentage)
        XCTAssertTrue(formattedPercentage.contains("45.5%"))
        
        // Test temperature formatting
        let temperature = 42.5
        let formattedTemperature = formatter.formatTemperature(temperature)
        XCTAssertTrue(formattedTemperature.contains("42.5") && formattedTemperature.contains("°C"))
    }
    
    func testSystemInfoFunctions() throws {
        // Just verify that we can retrieve some system info without crashing
        let sensors = SwiftSensors.shared
        
        // Test getting uptime
        let uptime = sensors.getSystemUptime()
        XCTAssertGreaterThan(uptime, 0)
        
        // Test getting OS version
        let osVersion = sensors.getOSVersion()
        XCTAssertFalse(osVersion.isEmpty)
        
        // Test thermal state
        let thermalState = sensors.getThermalState()
        XCTAssertNotNil(thermalState)
    }
}