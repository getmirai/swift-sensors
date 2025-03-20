@preconcurrency import CoreFoundation
@preconcurrency import Foundation
import PrivateAPI

/// A struct representing a thermal sensor reading from the device.
///
/// Thermal sensor readings measure temperature at various points in the device.
/// These measurements are useful for monitoring device health and detecting
/// potential overheating issues.
///
/// Example usage:
/// ```swift
/// let thermalReadings = await SwiftSensors.shared.getThermalSensorReadings()
/// for reading in thermalReadings {
///     print("\(reading.name): \(reading.temperature)°C")
/// }
/// ```

public struct ThermalSensorReading: BaseSensorReading {
    /// Unique identifier for the sensor
    public let id: String
    /// The name of the sensor
    public let name: String
    /// The current temperature reading
    public let temperature: Double

    init(name: String, temperature: Double) {
        self.id = UUID().uuidString
        self.name = name
        self.temperature = temperature
    }
}

/// A manager actor for thermal sensors

public actor ThermalSensorManager: SensorManager {
    public typealias SensorType = ThermalSensorReading

    /// Shared instance for easy access
    public static let shared = ThermalSensorManager()

    /// Constant for temperature query
    private let temperatureQuery = SensorUtils.query(
        page: kHIDPage_AppleVendor,
        usage: kHIDUsage_AppleVendor_TemperatureSensor
    )

    /// Event type for temperature
    private let eventType = Int64(kIOHIDEventTypeTemperature)

    /// Private initializer for singleton pattern
    private init() {}

    /// Get all available thermal sensors with current temperature readings
    public func getAllSensors() async -> [ThermalSensorReading] {
        let entries = SensorUtils.getEntries(matching: self.temperatureQuery)

        let nameDict = SensorUtils.createNameDictionary(of: entries) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypeTemperature)) != nil
        }

        let temps = SensorUtils.getSensorValues(from: nameDict) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypeTemperature))
        }

        // Create sensors and sort them by name for consistency
        let sensors = temps.map { name, temp in
            ThermalSensorReading(name: name, temperature: temp)
        }
        return sensors.sorted { $0.name < $1.name }
    }

    // Legacy method for backward compatibility
    public func getAllThermalSensors() async -> [ThermalSensorReading] {
        await self.getAllSensors()
    }
}
