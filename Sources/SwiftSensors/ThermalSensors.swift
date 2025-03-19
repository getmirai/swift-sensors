@preconcurrency import Foundation
@preconcurrency import CoreFoundation
import PrivateAPI

/// A struct representing a thermal sensor
@available(macOS 10.15, *)
public struct ThermalSensor: BaseSensor {
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
@available(macOS 10.15, *)
public actor ThermalSensorManager: SensorManager {
    public typealias SensorType = ThermalSensor
    
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
    public func getAllSensors() async -> [ThermalSensor] {
        let entries = SensorUtils.getEntries(matching: temperatureQuery)
        
        let nameDict = SensorUtils.createNameDictionary(of: entries) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypeTemperature)) != nil
        }
        
        let temps = SensorUtils.getSensorValues(from: nameDict) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypeTemperature))
        }
        
        // Create sensors and sort them by name for consistency
        let sensors = temps.map { (name, temp) in
            ThermalSensor(name: name, temperature: temp)
        }
        return sensors.sorted { $0.name < $1.name }
    }
    
    // Legacy method for backward compatibility
    public func getAllThermalSensors() async -> [ThermalSensor] {
        return await getAllSensors()
    }
}
