@preconcurrency import CoreFoundation
@preconcurrency import Foundation
import PrivateAPI

/// Base protocol for all sensor reading types
public protocol BaseSensorReading: Identifiable, Sendable {
    var id: String { get }
    var name: String { get }
}

/// Base protocol for all sensor managers
public protocol SensorManager {
    associatedtype SensorType: BaseSensorReading
    static var shared: Self { get }

    /// Get all available sensors from this manager
    func getAllSensors() async -> [SensorType]
}

/// Common functions for sensor querying and data processing
public enum SensorUtils {
    /// Create a query dictionary for HID matching
    public static func query(page: Int32, usage: Int32) -> CFDictionary {
        [
            "PrimaryUsagePage": page,
            "PrimaryUsage": usage
        ] as CFDictionary
    }

    /// Calculate event field base for a given type
    public static func eventFieldBase(_ type: Int32) -> Int32 {
        type << 16
    }

    /// Get HID service clients matching a specific query
    public static func getEntries(matching query: CFDictionary) -> [IOHIDServiceClient] {
        guard let system = IOHIDEventSystemClientCreate(kCFAllocatorDefault)
        else { return [] }

        IOHIDEventSystemClientSetMatching(system, query)

        guard let matchingServicesUnmanaged = IOHIDEventSystemClientCopyServices(system)
        else { return [] }

        let matchingServices = matchingServicesUnmanaged.takeRetainedValue()
        let count = CFArrayGetCount(matchingServices)
        var services = [IOHIDServiceClient]()

        for i in 0 ..< count {
            if let service = CFArrayGetValueAtIndex(matchingServices, i) {
                let client = unsafeBitCast(service, to: IOHIDServiceClient.self)
                services.append(client)
            }
        }

        return services
    }

    /// Create name to service mapping with validation
    public static func createNameDictionary(
        of entries: [IOHIDServiceClient],
        valueValidator: (IOHIDServiceClient) -> Bool
    ) -> [String: IOHIDServiceClient] {
        let keyValuePairs = entries.compactMap { client -> (String, IOHIDServiceClient)? in
            guard let product = client.product,
                  valueValidator(client)
            else { return nil }
            return (product, client)
        }
        return Dictionary(keyValuePairs) { left, right in left }
    }

    /// Extract sensor values from the name dictionary
    public static func getSensorValues<T>(
        from dictionary: [String: IOHIDServiceClient],
        valueExtractor: (IOHIDServiceClient) -> T?
    ) -> [(String, T)] {
        dictionary.compactMap { name, client in
            guard let value = valueExtractor(client) else { return nil }
            return (name, value)
        }
    }
}

/// Extensions for IOHIDServiceClient to get common properties
extension IOHIDServiceClient {
    var product: String? {
        guard let propUnmanaged = IOHIDServiceClientCopyProperty(self, "Product" as CFString)
        else { return nil }
        let cfString = unsafeBitCast(propUnmanaged, to: CFString.self)
        return cfString as String
    }

    func getValue(forEventType eventType: Int64, fieldBase: Int32) -> Double? {
        guard let event = IOHIDServiceClientCopyEvent(self, eventType, 0, 0)
        else { return nil }
        return IOHIDEventGetFloatValue(event, SensorUtils.eventFieldBase(fieldBase))
    }
}
