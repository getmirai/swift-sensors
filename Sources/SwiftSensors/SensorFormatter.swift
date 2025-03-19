import Foundation

/// A utility actor for formatting sensor values
public actor SensorFormatter {
    /// Shared instance for easy access
    public static let shared = SensorFormatter()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Format bytes to a human-readable string
    /// - Parameter bytes: The number of bytes to format
    /// - Returns: A formatted string with appropriate units (KB, MB, GB)
    public func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .memory
        formatter.includesUnit = true
        formatter.isAdaptive = true
        
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    /// Format temperature to a human-readable string
    /// - Parameter temperature: The temperature in degrees Celsius
    /// - Returns: A formatted string with degrees Celsius
    public func formatTemperature(_ temperature: Double) -> String {
        return String(format: "%.1f °C", temperature)
    }
    
    /// Format percentage to a human-readable string
    /// - Parameter percentage: The percentage value (0-100)
    /// - Returns: A formatted string with percentage sign
    public func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.1f%%", percentage)
    }
    
    /// Format time interval to a human-readable string
    /// - Parameter timeInterval: The time interval in seconds
    /// - Returns: A formatted string (e.g., "2d 5h 30m 15s")
    public func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        
        let startDate = Date(timeIntervalSinceNow: -timeInterval)
        return formatter.string(from: startDate, to: Date()) ?? "Unknown"
    }
}
