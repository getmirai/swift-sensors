import SwiftUI
import SwiftSensors


@Observable class SensorsViewModel {
    // Sensor data
    var thermalSensors: [ThermalSensor] = []
    var voltageSensors: [VoltageSensor] = []
    var currentSensors: [CurrentSensor] = []
    var memoryStats: MemoryStats? = nil
    var cpuStats: CPUStats? = nil
    var diskStats: DiskStats? = nil
    var thermalState: ThermalState = .unknown
    var uptimeText: String = "Loading..."
    
    // Formatted display values
    var formattedTemperatures: [String] = []
    var formattedVoltages: [String] = []
    var formattedCurrents: [String] = []
    var formattedMemoryValues: [String] = []
    var formattedCPUValues: [String] = []
    var formattedDiskValues: [String] = []
    
    // Cache to ensure sensor readings persist across UI updates
    private var lastUpdateTime = Date.distantPast
    private let updateInterval: TimeInterval = 1.0
    
    let formatter = SensorFormatter.shared
    
    // Singleton instance
    static let shared = SensorsViewModel()
    
    private init() {
        // Initial data load
        updateSensorData()
    }
    
    /// Updates sensor data if the cache has expired
    func updateIfNeeded() {
        let now = Date()
        if now.timeIntervalSince(lastUpdateTime) > updateInterval {
            updateSensorData()
        }
    }
    
    /// Fetches fresh sensor data from all sources
    func updateSensorData() {
        let sensors = SwiftSensors.shared
        
        // Use Task for async calls
        Task {
            // Create temporary variables to hold fetched data
            let fetchedThermalSensors = await sensors.getThermalSensors()
            let fetchedVoltageSensors = await sensors.getVoltageSensors()
            let fetchedCurrentSensors = await sensors.getCurrentSensors()
            let fetchedMemoryStats = await sensors.getMemoryStats()
            let fetchedCPUStats = await sensors.getCPUStats()
            let fetchedDiskStats = await sensors.getDiskStats()
            let fetchedThermalState = await sensors.getThermalState()
            let fetchedUptimeText = await sensors.getFormattedUptime()
            
            // Format all values first
            var tempFormattedTemperatures: [String] = []
            var tempFormattedVoltages: [String] = []
            var tempFormattedCurrents: [String] = []
            
            // Temperature formatting
            for sensor in fetchedThermalSensors {
                tempFormattedTemperatures.append(await formatter.formatTemperature(sensor.temperature))
            }
            
            // Voltage formatting
            for sensor in fetchedVoltageSensors {
                tempFormattedVoltages.append(await formatter.formatVoltage(sensor.voltage))
            }
            
            // Current formatting
            for sensor in fetchedCurrentSensors {
                tempFormattedCurrents.append(await formatter.formatCurrent(sensor.current))
            }
            
            // Memory formatting
            var tempFormattedMemoryValues: [String] = []
            tempFormattedMemoryValues = [
                await formatter.formatBytes(fetchedMemoryStats.totalMemory),
                await formatter.formatBytes(fetchedMemoryStats.freeMemory),
                await formatter.formatBytes(fetchedMemoryStats.activeMemory),
                await formatter.formatBytes(fetchedMemoryStats.wiredMemory),
                await formatter.formatBytes(fetchedMemoryStats.totalUsedMemory)
            ]
            
            // CPU formatting
            var tempFormattedCPUValues: [String] = []
            tempFormattedCPUValues = [
                await formatter.formatPercentage(fetchedCPUStats.totalUsage),
                await formatter.formatPercentage(fetchedCPUStats.userUsage),
                await formatter.formatPercentage(fetchedCPUStats.systemUsage)
            ]
            
            // Disk formatting
            var tempFormattedDiskValues: [String] = []
            tempFormattedDiskValues = [
                await formatter.formatBytes(fetchedDiskStats.totalSpace),
                await formatter.formatBytes(fetchedDiskStats.usedSpace),
                await formatter.formatBytes(fetchedDiskStats.freeSpace)
            ]
            
            // Update UI on the main thread with all data at once
            await MainActor.run {
                // Update all sensor data
                thermalSensors = fetchedThermalSensors
                voltageSensors = fetchedVoltageSensors
                currentSensors = fetchedCurrentSensors
                memoryStats = fetchedMemoryStats
                cpuStats = fetchedCPUStats
                diskStats = fetchedDiskStats
                thermalState = fetchedThermalState
                uptimeText = fetchedUptimeText
                
                // Update formatted values
                formattedTemperatures = tempFormattedTemperatures
                formattedVoltages = tempFormattedVoltages
                formattedCurrents = tempFormattedCurrents
                formattedMemoryValues = tempFormattedMemoryValues
                formattedCPUValues = tempFormattedCPUValues
                formattedDiskValues = tempFormattedDiskValues
                
                // Update timestamp
                lastUpdateTime = Date()
            }
        }
    }
}