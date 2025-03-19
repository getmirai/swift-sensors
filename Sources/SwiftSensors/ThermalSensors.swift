@preconcurrency import Foundation
@preconcurrency import CoreFoundation
import PrivateAPI

private let temperatureQuery = query(page: 0xff00, usage: 5)
private let kIOHIDEventTypeTemperature = Int64(15)

private func query(
    page: Int32,
    usage: Int32
) -> CFDictionary {
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

/// A struct representing a thermal sensor
public struct ThermalSensor: Identifiable, Sendable {
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
public actor ThermalSensorManager {
    /// Shared instance for easy access
    public static let shared = ThermalSensorManager()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Get all available thermal sensors with current temperature readings
    public func getAllThermalSensors() -> [ThermalSensor] {
        let entries = getThermalEntries()
        let nameDict = createNameDictionary(of: entries)
        let temps = getTemperatures(from: nameDict)
        return temps.map { (name, temp) in
            ThermalSensor(name: name, temperature: temp)
        }
    }
}
