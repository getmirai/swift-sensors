import Foundation

/// Represents a temperature reading at a specific point in time
@available(iOS 16.0, *)
struct TemperatureReading: Identifiable {
    /// Unique identifier for this reading
    let id = UUID()
    
    /// When the reading was taken
    let timestamp: Date
    
    /// Temperature value in Celsius
    let temperature: Double
}