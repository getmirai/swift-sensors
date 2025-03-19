import Foundation

/// Represents a single sensor reading for display in charts
@available(iOS 16.0, *)
struct SensorData: Identifiable {
    /// Unique identifier
    let id = UUID()
    
    /// When the reading was taken
    let timestamp: Date
    
    /// Name of the sensor
    let sensorName: String
    
    /// Value of the reading
    let value: Double
}