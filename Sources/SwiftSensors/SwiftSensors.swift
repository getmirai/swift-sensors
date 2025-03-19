import Foundation

/// The main actor for accessing all sensor data
public actor SwiftSensors {
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
    public func getThermalSensors() async -> [ThermalSensor] {
        return await thermalSensorManager.getAllThermalSensors()
    }
    
    // MARK: - Memory Stats
    
    /// Get current memory statistics
    /// - Returns: Memory statistics
    public func getMemoryStats() async -> MemoryStats {
        return await systemStatsManager.getMemoryStats()
    }
    
    /// Get formatted memory usage string
    /// - Returns: A string describing memory usage
    public func getFormattedMemoryUsage() async -> String {
        let stats = await getMemoryStats()
        let usedPercentage = Double(stats.totalUsedMemory) / Double(stats.totalMemory) * 100
        return "\(await formatter.formatPercentage(usedPercentage)) (\(await formatter.formatBytes(stats.totalUsedMemory)) of \(await formatter.formatBytes(stats.totalMemory)))"
    }
    
    // MARK: - CPU Stats
    
    /// Get current CPU statistics
    /// - Returns: CPU statistics
    public func getCPUStats() async -> CPUStats {
        return await systemStatsManager.getCPUStats()
    }
    
    /// Get formatted CPU usage string
    /// - Returns: A string describing CPU usage
    public func getFormattedCPUUsage() async -> String {
        let stats = await getCPUStats()
        return await formatter.formatPercentage(stats.totalUsage)
    }
    
    // MARK: - Disk Stats
    
    /// Get current disk statistics
    /// - Returns: Disk statistics
    public func getDiskStats() async -> DiskStats {
        return await systemStatsManager.getDiskStats()
    }
    
    /// Get formatted disk usage string
    /// - Returns: A string describing disk usage
    public func getFormattedDiskUsage() async -> String {
        let stats = await getDiskStats()
        let usedPercentage = Double(stats.usedSpace) / Double(stats.totalSpace) * 100
        return "\(await formatter.formatPercentage(usedPercentage)) (\(await formatter.formatBytes(stats.usedSpace)) of \(await formatter.formatBytes(stats.totalSpace)))"
    }
    
    // MARK: - System Info
    
    /// Get current thermal state
    /// - Returns: Thermal state of the device
    public func getThermalState() async -> ThermalState {
        return await systemStatsManager.getThermalState()
    }
    
    /// Get system uptime
    /// - Returns: System uptime in seconds
    public func getSystemUptime() async -> TimeInterval {
        return await systemStatsManager.getSystemUptime()
    }
    
    /// Get formatted system uptime
    /// - Returns: A human-readable string of the system uptime
    public func getFormattedUptime() async -> String {
        return await systemStatsManager.getFormattedUptime()
    }
    
    /// Get operating system version
    /// - Returns: OS version string
    public func getOSVersion() async -> String {
        return await systemStatsManager.getOSVersion()
    }
    
    /// Get battery level
    /// - Returns: Battery level as a percentage (0-100)
    public func getBatteryLevel() async -> Float {
        return await systemStatsManager.getBatteryLevel()
    }
    
    /// Get device type
    /// - Returns: Device type string
    public func getDeviceType() async -> String {
        return await systemStatsManager.getDeviceType()
    }
}
