@preconcurrency import Foundation
@preconcurrency import CoreFoundation
import PrivateAPI

private let voltageQuery = query(page: kHIDPage_AppleVendorPowerSensor, usage: kHIDUsage_AppleVendorPowerSensor_Voltage)
private let currentQuery = query(page: kHIDPage_AppleVendorPowerSensor, usage: kHIDUsage_AppleVendorPowerSensor_Current)
private let kIOHIDEventTypePower = Int64(25)

private func eventFieldBase(_ type: Int32) -> Int32 {
    return type << 16
}

private func query(
    page: Int32,
    usage: Int32
) -> CFDictionary {
    [
        "PrimaryUsagePage": page,
        "PrimaryUsage": usage
    ] as CFDictionary
}

func getVoltageEntries() -> [HIDServiceClient] {
    let system = IOHIDEventSystemClientCreate(kCFAllocatorDefault)
    IOHIDEventSystemClientSetMatching(system, voltageQuery)
    let matchingServices = IOHIDEventSystemClientCopyServices(system)
    
    let services = matchingServices?.takeRetainedValue() as? Array<HIDServiceClient>
    return services ?? []
}

func getCurrentEntries() -> [HIDServiceClient] {
    let system = IOHIDEventSystemClientCreate(kCFAllocatorDefault)
    IOHIDEventSystemClientSetMatching(system, currentQuery)
    let matchingServices = IOHIDEventSystemClientCopyServices(system)
    
    let services = matchingServices?.takeRetainedValue() as? Array<HIDServiceClient>
    return services ?? []
}

func createPowerNameDictionary(of entries: [HIDServiceClient]) -> [String: HIDServiceClient] {
    let keyValuePairs = entries.compactMap { client -> (String, HIDServiceClient)? in
        guard let product = client.product else { return nil }
        guard client.powerValue != nil else { return nil }
        return (product, client)
    }
    return Dictionary(keyValuePairs) { left, right in left }
}

func getPowerValues(from dictionary: [String: HIDServiceClient]) -> [(String, Double)] {
    dictionary.map { ($0, $1.powerValue!) }
}

extension HIDServiceClient {
    var powerValue: Double? {
        if let event = IOHIDServiceClientCopyEvent(self, Int64(kIOHIDEventTypePower), 0, 0) {
            return IOHIDEventGetFloatValue(event, eventFieldBase(Int32(kIOHIDEventTypePower)))
        } else {
            return nil
        }
    }
}

/// A struct representing a voltage sensor
public struct VoltageSensor: Identifiable, Sendable {
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
public struct CurrentSensor: Identifiable, Sendable {
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

/// A manager actor for power sensors (voltage and current)
public actor PowerSensorManager {
    /// Shared instance for easy access
    public static let shared = PowerSensorManager()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Get all available voltage sensors with current voltage readings
    public func getAllVoltageSensors() -> [VoltageSensor] {
        let entries = getVoltageEntries()
        let nameDict = createPowerNameDictionary(of: entries)
        let voltages = getPowerValues(from: nameDict)
        
        let sensors = voltages.map { (name, voltage) in
            VoltageSensor(name: name, voltage: voltage)
        }
        return sensors.sorted { $0.name < $1.name }
    }
    
    /// Get all available current sensors with current amperage readings
    public func getAllCurrentSensors() -> [CurrentSensor] {
        let entries = getCurrentEntries()
        let nameDict = createPowerNameDictionary(of: entries)
        let currents = getPowerValues(from: nameDict)
        
        let sensors = currents.map { (name, current) in
            CurrentSensor(name: name, current: current)
        }
        return sensors.sorted { $0.name < $1.name }
    }
}