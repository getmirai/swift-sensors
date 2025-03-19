@preconcurrency import Foundation
@preconcurrency import CoreFoundation
import PrivateAPI

/// An enum representing a power sensor type
public enum PowerSensorType: Sendable {
    case voltage
    case current
}

/// A struct representing a voltage sensor
public struct VoltageSensor: BaseSensor {
    /// Unique identifier for the sensor
    public let id: String
    /// The name of the sensor
    public let name: String
    /// The current voltage reading (in Volts)
    public let voltage: Double
    
    init(name: String, voltage: Double) {
        self.id = UUID().uuidString
        self.name = name
        self.voltage = voltage
    }
}

/// A struct representing a current sensor
public struct CurrentSensor: BaseSensor {
    /// Unique identifier for the sensor
    public let id: String
    /// The name of the sensor
    public let name: String
    /// The current amperage reading (in Amperes)
    public let current: Double
    
    init(name: String, current: Double) {
        self.id = UUID().uuidString
        self.name = name
        self.current = current
    }
}

/// A struct for representing any power sensor
public struct PowerSensor: BaseSensor {
    /// Unique identifier for the sensor
    public let id: String
    /// The name of the sensor
    public let name: String
    /// The sensor type (voltage or current)
    public let type: PowerSensorType
    /// The sensor value
    public let value: Double
    
    /// Convenience property to get voltage (if this is a voltage sensor)
    public var voltage: Double? {
        type == .voltage ? value : nil
    }
    
    /// Convenience property to get current (if this is a current sensor)
    public var current: Double? {
        type == .current ? value : nil
    }
    
    init(name: String, type: PowerSensorType, value: Double) {
        self.id = UUID().uuidString
        self.name = name
        self.type = type
        self.value = value
    }
}

/// A manager actor for power sensors (voltage and current)
public actor PowerSensorManager: SensorManager {
    public typealias SensorType = PowerSensor
    
    /// Shared instance for easy access
    public static let shared = PowerSensorManager()
    
    /// Event type for power values
    private let eventType = Int64(kIOHIDEventTypePower)
    
    /// Queries for voltage and current sensors
    private let voltageQuery = SensorUtils.query(
        page: kHIDPage_AppleVendorPowerSensor, 
        usage: kHIDUsage_AppleVendorPowerSensor_Voltage
    )
    
    private let currentQuery = SensorUtils.query(
        page: kHIDPage_AppleVendorPowerSensor, 
        usage: kHIDUsage_AppleVendorPowerSensor_Current
    )
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Get all available power sensors (both voltage and current)
    public func getAllSensors() async -> [PowerSensor] {
        let voltageSensors = await getSpecificSensors(
            query: voltageQuery, 
            type: .voltage
        )
        
        let currentSensors = await getSpecificSensors(
            query: currentQuery, 
            type: .current
        )
        
        // Combine both types and sort by name
        return (voltageSensors + currentSensors).sorted { $0.name < $1.name }
    }
    
    /// Helper method to get sensors of a specific type
    private func getSpecificSensors(query: CFDictionary, type: PowerSensorType) async -> [PowerSensor] {
        let entries = SensorUtils.getEntries(matching: query)
        
        let nameDict = SensorUtils.createNameDictionary(of: entries) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypePower)) != nil
        }
        
        let values = SensorUtils.getSensorValues(from: nameDict) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypePower))
        }
        
        return values.map { (name, value) in
            PowerSensor(name: name, type: type, value: value)
        }
    }
    
    // Legacy methods for backward compatibility
    
    /// Get all available voltage sensors with current voltage readings
    public func getAllVoltageSensors() async -> [VoltageSensor] {
        let entries = SensorUtils.getEntries(matching: voltageQuery)
        
        let nameDict = SensorUtils.createNameDictionary(of: entries) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypePower)) != nil
        }
        
        let voltages = SensorUtils.getSensorValues(from: nameDict) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypePower))
        }
        
        let sensors = voltages.map { (name, voltage) in
            VoltageSensor(name: name, voltage: voltage)
        }
        return sensors.sorted { $0.name < $1.name }
    }
    
    /// Get all available current sensors with current amperage readings
    public func getAllCurrentSensors() async -> [CurrentSensor] {
        let entries = SensorUtils.getEntries(matching: currentQuery)
        
        let nameDict = SensorUtils.createNameDictionary(of: entries) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypePower)) != nil
        }
        
        let currents = SensorUtils.getSensorValues(from: nameDict) { client in
            client.getValue(forEventType: self.eventType, fieldBase: Int32(kIOHIDEventTypePower))
        }
        
        let sensors = currents.map { (name, current) in
            CurrentSensor(name: name, current: current)
        }
        return sensors.sorted { $0.name < $1.name }
    }
}
