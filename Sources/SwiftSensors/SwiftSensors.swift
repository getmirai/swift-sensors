import Foundation

/// The main class for accessing all sensor data
public final class SwiftSensors: Sendable {
    /// Shared instance for easy access
    public static let shared = SwiftSensors()
    
    /// Thermal sensor manager
    private let thermalSensorManager: ThermalSensorManager
    
    /// System stats manager
    private let systemStatsManager: SystemStatsManager
    
    /// Formatter for sensor values
    private let formatter: SensorFormatter
    
    /// Private initializer for singleton pattern
    private init() {
        thermalSensorManager = ThermalSensorManager.shared
        systemStatsManager = SystemStatsManager.shared
        formatter = SensorFormatter.shared
    }
    
    // MARK: - Thermal Sensors
    
    /// Get all available thermal sensors
    /// - Returns: An array of thermal sensors
    @MainActor
    public func getThermalSensors() -> [ThermalSensor] {
        return thermalSensorManager.getAllThermalSensors()
    }
    
    // MARK: - Memory Stats
    
    /// Get current memory statistics
    /// - Returns: Memory statistics
    public func getMemoryStats() -> MemoryStats {
        return systemStatsManager.getMemoryStats()
    }
    
    /// Get formatted memory usage string
    /// - Returns: A string describing memory usage
    public func getFormattedMemoryUsage() -> String {
        let stats = getMemoryStats()
        let usedPercentage = Double(stats.totalUsedMemory) / Double(stats.totalMemory) * 100
        return "\(formatter.formatPercentage(usedPercentage)) (\(formatter.formatBytes(stats.totalUsedMemory)) of \(formatter.formatBytes(stats.totalMemory)))"
    }
    
    // MARK: - CPU Stats
    
    /// Get current CPU statistics
    /// - Returns: CPU statistics
    public func getCPUStats() -> CPUStats {
        return systemStatsManager.getCPUStats()
    }
    
    /// Get formatted CPU usage string
    /// - Returns: A string describing CPU usage
    public func getFormattedCPUUsage() -> String {
        let stats = getCPUStats()
        return formatter.formatPercentage(stats.totalUsage)
    }
    
    // MARK: - Disk Stats
    
    /// Get current disk statistics
    /// - Returns: Disk statistics
    public func getDiskStats() -> DiskStats {
        return systemStatsManager.getDiskStats()
    }
    
    /// Get formatted disk usage string
    /// - Returns: A string describing disk usage
    public func getFormattedDiskUsage() -> String {
        let stats = getDiskStats()
        let usedPercentage = Double(stats.usedSpace) / Double(stats.totalSpace) * 100
        return "\(formatter.formatPercentage(usedPercentage)) (\(formatter.formatBytes(stats.usedSpace)) of \(formatter.formatBytes(stats.totalSpace)))"
    }
    
    // MARK: - System Info
    
    /// Get current thermal state
    /// - Returns: Thermal state of the device
    public func getThermalState() -> ThermalState {
        return systemStatsManager.getThermalState()
    }
    
    /// Get system uptime
    /// - Returns: System uptime in seconds
    public func getSystemUptime() -> TimeInterval {
        return systemStatsManager.getSystemUptime()
    }
    
    /// Get formatted system uptime
    /// - Returns: A human-readable string of the system uptime
    public func getFormattedUptime() -> String {
        return systemStatsManager.getFormattedUptime()
    }
    
    /// Get operating system version
    /// - Returns: OS version string
    public func getOSVersion() -> String {
        return systemStatsManager.getOSVersion()
    }
    
    /// Get battery level
    /// - Returns: Battery level as a percentage (0-100)
    @MainActor
    public func getBatteryLevel() -> Float {
        return systemStatsManager.getBatteryLevel()
    }
    
    /// Get device type
    /// - Returns: Device type string
    @MainActor
    public func getDeviceType() -> String {
        return systemStatsManager.getDeviceType()
    }
}
