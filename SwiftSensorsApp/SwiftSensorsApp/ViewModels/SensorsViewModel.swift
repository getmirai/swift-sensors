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
    
    // Selected sensors for charts
    var selectedThermalSensors: Set<String> = []
    var selectedVoltageSensors: Set<String> = []
    var selectedCurrentSensors: Set<String> = []
    var selectedMemoryItems: Set<Int> = []
    var selectedCPUItems: Set<Int> = []
    var selectedDiskItems: Set<Int> = []
    var selectedSystemItem: Int? = nil
    
    // Historical sensor data for charts
    var thermalSensorData: [SensorData] = []
    var voltageSensorData: [SensorData] = []
    var currentSensorData: [SensorData] = []
    var memoryMetricData: [SensorData] = []
    var cpuMetricData: [SensorData] = []
    var diskMetricData: [SensorData] = []
    
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
    
    /// Get filtered thermal sensor data for specified time window
    func filteredThermalData(timeWindow: TimeInterval) -> [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return thermalSensorData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedThermalSensors.contains(reading.sensorName)
        }
    }
    
    /// Get filtered voltage sensor data for specified time window
    func filteredVoltageData(timeWindow: TimeInterval) -> [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return voltageSensorData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedVoltageSensors.contains(reading.sensorName)
        }
    }
    
    /// Get filtered current sensor data for specified time window
    func filteredCurrentData(timeWindow: TimeInterval) -> [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return currentSensorData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedCurrentSensors.contains(reading.sensorName)
        }
    }
    
    /// Get filtered memory metric data for specified time window
    func filteredMemoryData(timeWindow: TimeInterval) -> [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return memoryMetricData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedMemoryItems.contains { 
                MemoryMetricType(rawValue: $0)?.name == reading.sensorName 
            }
        }
    }
    
    /// Get filtered CPU metric data for specified time window
    func filteredCPUData(timeWindow: TimeInterval) -> [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return cpuMetricData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedCPUItems.contains { 
                CPUMetricType(rawValue: $0)?.name == reading.sensorName 
            }
        }
    }
    
    /// Get filtered disk metric data for specified time window
    func filteredDiskData(timeWindow: TimeInterval) -> [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return diskMetricData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedDiskItems.contains { 
                DiskMetricType(rawValue: $0)?.name == reading.sensorName 
            }
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
            let now = Date()
            
            // Format all values first
            var tempFormattedTemperatures: [String] = []
            var tempFormattedVoltages: [String] = []
            var tempFormattedCurrents: [String] = []
            
            // Create temporary data points
            var newThermalData: [SensorData] = []
            var newVoltageData: [SensorData] = []
            var newCurrentData: [SensorData] = []
            var newMemoryData: [SensorData] = []
            var newCPUData: [SensorData] = []
            var newDiskData: [SensorData] = []
            
            // Temperature formatting and data collection
            for sensor in fetchedThermalSensors {
                tempFormattedTemperatures.append(await formatter.formatTemperature(sensor.temperature))
                newThermalData.append(SensorData(
                    timestamp: now,
                    sensorName: sensor.name,
                    value: sensor.temperature,
                    category: "Temperature"
                ))
            }
            
            // Voltage formatting and data collection
            for sensor in fetchedVoltageSensors {
                tempFormattedVoltages.append(await formatter.formatVoltage(sensor.voltage))
                newVoltageData.append(SensorData(
                    timestamp: now,
                    sensorName: sensor.name,
                    value: sensor.voltage,
                    category: "Voltage"
                ))
            }
            
            // Current formatting and data collection
            for sensor in fetchedCurrentSensors {
                tempFormattedCurrents.append(await formatter.formatCurrent(sensor.current))
                newCurrentData.append(SensorData(
                    timestamp: now,
                    sensorName: sensor.name,
                    value: sensor.current,
                    category: "Current"
                ))
            }
            
            // Memory formatting and data collection
            var tempFormattedMemoryValues: [String] = []
            
            // Add data points for each memory metric
            for type in MemoryMetricType.allCases {
                let value: Double
                switch type {
                case .total: value = Double(fetchedMemoryStats.totalMemory)
                case .free: value = Double(fetchedMemoryStats.freeMemory)
                case .active: value = Double(fetchedMemoryStats.activeMemory)
                case .wired: value = Double(fetchedMemoryStats.wiredMemory)
                case .used: value = Double(fetchedMemoryStats.totalUsedMemory)
                }
                
                newMemoryData.append(SensorData(
                    timestamp: now,
                    sensorName: type.name,
                    value: value,
                    category: "Memory"
                ))
            }
            
            tempFormattedMemoryValues = [
                await formatter.formatBytes(fetchedMemoryStats.totalMemory),
                await formatter.formatBytes(fetchedMemoryStats.freeMemory),
                await formatter.formatBytes(fetchedMemoryStats.activeMemory),
                await formatter.formatBytes(fetchedMemoryStats.wiredMemory),
                await formatter.formatBytes(fetchedMemoryStats.totalUsedMemory)
            ]
            
            // CPU formatting and data collection
            var tempFormattedCPUValues: [String] = []
            
            // Add data points for each CPU metric
            for type in CPUMetricType.allCases {
                let value: Double
                switch type {
                case .total: value = fetchedCPUStats.totalUsage
                case .user: value = fetchedCPUStats.userUsage
                case .system: value = fetchedCPUStats.systemUsage
                }
                
                newCPUData.append(SensorData(
                    timestamp: now,
                    sensorName: type.name,
                    value: value,
                    category: "CPU"
                ))
            }
            
            tempFormattedCPUValues = [
                await formatter.formatPercentage(fetchedCPUStats.totalUsage),
                await formatter.formatPercentage(fetchedCPUStats.userUsage),
                await formatter.formatPercentage(fetchedCPUStats.systemUsage)
            ]
            
            // Disk formatting and data collection
            var tempFormattedDiskValues: [String] = []
            
            // Add data points for each disk metric
            for type in DiskMetricType.allCases {
                let value: Double
                switch type {
                case .total: value = Double(fetchedDiskStats.totalSpace)
                case .used: value = Double(fetchedDiskStats.usedSpace)
                case .free: value = Double(fetchedDiskStats.freeSpace)
                }
                
                newDiskData.append(SensorData(
                    timestamp: now,
                    sensorName: type.name,
                    value: value,
                    category: "Disk"
                ))
            }
            
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
                
                // Update historical data collections
                thermalSensorData.append(contentsOf: newThermalData)
                voltageSensorData.append(contentsOf: newVoltageData)
                currentSensorData.append(contentsOf: newCurrentData)
                memoryMetricData.append(contentsOf: newMemoryData)
                cpuMetricData.append(contentsOf: newCPUData)
                diskMetricData.append(contentsOf: newDiskData)
                
                // Cap data collections to manage memory (3 hours of data at 1 reading per second)
                let maxDataPoints = 3 * 60 * 60
                let maxPointsPerSensor = maxDataPoints / max(1, fetchedThermalSensors.count)
                let maxPointsPerMetric = maxDataPoints / 5 // For memory metrics (5 metrics)
                
                if thermalSensorData.count > maxDataPoints {
                    thermalSensorData = Array(thermalSensorData.suffix(maxDataPoints))
                }
                
                if voltageSensorData.count > maxDataPoints {
                    voltageSensorData = Array(voltageSensorData.suffix(maxDataPoints))
                }
                
                if currentSensorData.count > maxDataPoints {
                    currentSensorData = Array(currentSensorData.suffix(maxDataPoints))
                }
                
                if memoryMetricData.count > maxDataPoints {
                    memoryMetricData = Array(memoryMetricData.suffix(maxDataPoints))
                }
                
                if cpuMetricData.count > maxDataPoints {
                    cpuMetricData = Array(cpuMetricData.suffix(maxDataPoints))
                }
                
                if diskMetricData.count > maxDataPoints {
                    diskMetricData = Array(diskMetricData.suffix(maxDataPoints))
                }
                
                // Update timestamp
                lastUpdateTime = now
            }
        }
    }
}