import SwiftUI

/// Store for maintaining sensor reading history and statistics
@available(iOS 16.0, *)
@Observable class SensorReadingsStore {
    /// Historical readings for the sensor
    var readings: [TemperatureReading] = []
    
    /// Minimum temperature from readings
    var minTemperature: Double = 0
    
    /// Maximum temperature from readings
    var maxTemperature: Double = 0
    
    /// Average temperature from readings
    var avgTemperature: Double = 0
    
    /// Most recent temperature reading
    var currentTemperature: Double = 0
    
    /// Cache for readings by sensor name
    static var stores: [String: SensorReadingsStore] = [:]
    
    /// Get or create a store for a specific sensor
    /// - Parameter sensorName: The name of the sensor
    /// - Returns: A persistent store for that sensor's readings
    static func getStore(for sensorName: String) -> SensorReadingsStore {
        if let existingStore = stores[sensorName] {
            return existingStore
        }
        let newStore = SensorReadingsStore()
        stores[sensorName] = newStore
        return newStore
    }
}