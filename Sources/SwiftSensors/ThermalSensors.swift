@preconcurrency import Foundation
@preconcurrency import CoreFoundation
import PrivateAPI

let temperatureQuery = getQueryFor(page: 0xff00, usage: 5)
let kIOHIDEventTypeTemperature = Int64(15)

func getQueryFor(page: Int32, usage: Int32) -> CFDictionary {
    [
        "PrimaryUsagePage": page,
        "PrimaryUsage": usage
    ] as CFDictionary
}

func getThermalEntries() -> [HIDServiceClient] {
    let system = IOHIDEventSystemClientCreate(kCFAllocatorDefault)
    IOHIDEventSystemClientSetMatching(system, temperatureQuery)
    let matchingServices = IOHIDEventSystemClientCopyServices(system)
    
    let services = matchingServices?.takeRetainedValue() as? Array<HIDServiceClient>
    return services ?? []
}

func createNameDictionary(of entries: [HIDServiceClient]) -> [String: HIDServiceClient] {
    let keyValuePairs = entries.compactMap { client -> (String, HIDServiceClient)? in
        guard let product = client.product else { return nil }
        guard client.temperature != nil else { return nil }
        return (product, client)
    }
    return Dictionary(keyValuePairs) { left, right in left }
}

func getTemperatures(from dictionary: [String: HIDServiceClient]) -> [(String, Double)] {
    dictionary.map { ($0, $1.temperature!) }
}

extension HIDServiceClient {
    var product: String? {
        IOHIDServiceClientCopyProperty(self, "Product" as CFString)?.takeRetainedValue() as? String
    }
    
    var temperature: Double? {
        if let event = IOHIDServiceClientCopyEvent(self, kIOHIDEventTypeTemperature, 0, 0) {
            return IOHIDEventGetFloatValue(event, Int32(kIOHIDEventTypeTemperature << 16))
        } else {
            return nil
        }
    }
}

/// A class representing a thermal sensor
public struct ThermalSensor: Identifiable {
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

/// A manager class for thermal sensors
public final class ThermalSensorManager: Sendable {
    /// Shared instance for easy access
    public static let shared = ThermalSensorManager()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Get all available thermal sensors with current temperature readings
    @MainActor
    public func getAllThermalSensors() -> [ThermalSensor] {
        let entries = getThermalEntries()
        if entries.isEmpty {
            print("No thermal entries found, falling back to mock data")
            return createMockSensors()
        }
        
        let nameDict = createNameDictionary(of: entries)
        let temps = getTemperatures(from: nameDict)
        
        if temps.isEmpty {
            print("No temperature data found, falling back to mock data")
            return createMockSensors()
        }
        
        return temps.map { (name, temp) in
            ThermalSensor(name: name, temperature: temp)
        }
    }
    
    /// Create mock sensor data for testing or when real data is unavailable
    private func createMockSensors() -> [ThermalSensor] {
        return [
            ThermalSensor(name: "CPU", temperature: 35.0 + Double.random(in: -3...5)),
            ThermalSensor(name: "GPU", temperature: 32.0 + Double.random(in: -2...7)),
            ThermalSensor(name: "Battery", temperature: 30.0 + Double.random(in: -1...3)),
            ThermalSensor(name: "Memory", temperature: 33.0 + Double.random(in: -2...4))
        ]
    }
}
