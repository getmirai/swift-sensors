import Foundation

/// The main actor for accessing all sensor data

public actor SwiftSensors {
    /// Shared instance for easy access
    public static let shared = SwiftSensors()

    /// Thermal sensor manager
    private let thermalSensorManager: ThermalSensorManager

    /// Power sensor manager
    private let powerSensorManager: PowerSensorManager

    /// System stats manager
    private let systemStatsManager: SystemStatsManager

    /// Formatter for sensor values
    private let formatter: SensorFormatter

    /// Private initializer for singleton pattern
    private init() {
        self.thermalSensorManager = ThermalSensorManager.shared
        self.powerSensorManager = PowerSensorManager.shared
        self.systemStatsManager = SystemStatsManager.shared
        self.formatter = SensorFormatter.shared
    }

    // MARK: - Sensors (Generic)

    // We'll remove this generic method as it's causing data race issues
    // This functionality can be accessed directly through the specific manager instances

    // MARK: - Thermal Sensors

    /// Get all available thermal sensors
    /// - Returns: An array of thermal sensors
    public func getThermalSensors() async -> [ThermalSensor] {
        await self.thermalSensorManager.getAllSensors()
    }

    // MARK: - Power Sensors

    /// Get all power sensors (both voltage and current)
    /// - Returns: An array of power sensors
    public func getPowerSensors() async -> [PowerSensor] {
        await self.powerSensorManager.getAllSensors()
    }

    /// Get all available voltage sensors
    /// - Returns: An array of voltage sensors
    public func getVoltageSensors() async -> [VoltageSensor] {
        await self.powerSensorManager.getAllVoltageSensors()
    }

    /// Get all available current sensors
    /// - Returns: An array of current sensors
    public func getCurrentSensors() async -> [CurrentSensor] {
        await self.powerSensorManager.getAllCurrentSensors()
    }

    /// Get power sensors of a specific type
    /// - Parameter type: The type of power sensors to retrieve
    /// - Returns: An array of power sensors of the requested type
    public func getPowerSensors(type: PowerSensorType) async -> [PowerSensor] {
        let allSensors = await getPowerSensors()
        return allSensors.filter { $0.type == type }
    }

    // MARK: - Memory Stats

    /// Get current memory statistics
    /// - Returns: Memory statistics
    public func getMemoryStats() async -> MemoryStats {
        await self.systemStatsManager.getMemoryStats()
    }

    /// Get formatted memory usage string
    /// - Returns: A string describing memory usage
    public func getFormattedMemoryUsage() async -> String {
        let stats = await getMemoryStats()
        let usedPercentage = Double(stats.totalUsedMemory) / Double(stats.totalMemory) * 100
        return "\(await self.formatter.formatPercentage(usedPercentage)) (\(await self.formatter.formatBytes(stats.totalUsedMemory)) of \(await self.formatter.formatBytes(stats.totalMemory)))"
    }

    // MARK: - CPU Stats

    /// Get current CPU statistics
    /// - Returns: CPU statistics
    public func getCPUStats() async -> CPUStats {
        await self.systemStatsManager.getCPUStats()
    }

    /// Get formatted CPU usage string
    /// - Returns: A string describing CPU usage
    public func getFormattedCPUUsage() async -> String {
        let stats = await getCPUStats()
        return await self.formatter.formatPercentage(stats.totalUsage)
    }

    // MARK: - Disk Stats

    /// Get current disk statistics
    /// - Returns: Disk statistics
    public func getDiskStats() async -> DiskStats {
        await self.systemStatsManager.getDiskStats()
    }

    /// Get formatted disk usage string
    /// - Returns: A string describing disk usage
    public func getFormattedDiskUsage() async -> String {
        let stats = await getDiskStats()
        let usedPercentage = Double(stats.usedSpace) / Double(stats.totalSpace) * 100
        return "\(await self.formatter.formatPercentage(usedPercentage)) (\(await self.formatter.formatBytes(stats.usedSpace)) of \(await self.formatter.formatBytes(stats.totalSpace)))"
    }

    // MARK: - System Info

    /// Get current thermal state
    /// - Returns: Thermal state of the device
    public func getThermalState() async -> ThermalState {
        await self.systemStatsManager.getThermalState()
    }

    /// Get system uptime
    /// - Returns: System uptime in seconds
    public func getSystemUptime() async -> TimeInterval {
        await self.systemStatsManager.getSystemUptime()
    }

    /// Get formatted system uptime
    /// - Returns: A human-readable string of the system uptime
    public func getFormattedUptime() async -> String {
        await self.systemStatsManager.getFormattedUptime()
    }

    /// Get operating system version
    /// - Returns: OS version string
    public func getOSVersion() async -> String {
        await self.systemStatsManager.getOSVersion()
    }

    /// Get battery level
    /// - Returns: Battery level as a percentage (0-100)
    public func getBatteryLevel() async -> Float {
        await self.systemStatsManager.getBatteryLevel()
    }

    /// Get device type
    /// - Returns: Device type string
    public func getDeviceType() async -> String {
        await self.systemStatsManager.getDeviceType()
    }
}
