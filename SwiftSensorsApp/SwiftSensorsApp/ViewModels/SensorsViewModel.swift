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
        Task.detached { [formatter] in
            let sensors = SwiftSensors.shared
            
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
            
            let thermalDataResults = await withTaskGroup(of: (formattedTemp: String, sensorData: SensorData).self) { group in
                for sensor in fetchedThermalSensors {
                    group.addTask {
                        let formattedTemp = await formatter.formatTemperature(sensor.temperature)
                        let sensorData = SensorData(
                            timestamp: now,
                            sensorName: sensor.name,
                            value: sensor.temperature,
                            category: "Temperature"
                        )
                        return (formattedTemp, sensorData)
                    }
                }
                
                var tempFormattedTemperatures: [String] = []
                var newThermalData: [SensorData] = []
                
                for await result in group {
                    tempFormattedTemperatures.append(result.formattedTemp)
                    newThermalData.append(result.sensorData)
                }
                
                return (tempFormattedTemperatures, newThermalData)
            }
            
            let voltageDataResults = await withTaskGroup(of: (formattedVoltage: String, sensorData: SensorData).self) { group in
                for sensor in fetchedVoltageSensors {
                    group.addTask {
                        let formattedVoltage = await formatter.formatVoltage(sensor.voltage)
                        let sensorData = SensorData(
                            timestamp: now,
                            sensorName: sensor.name,
                            value: sensor.voltage,
                            category: "Voltage"
                        )
                        return (formattedVoltage, sensorData)
                    }
                }
                
                var tempFormattedVoltages: [String] = []
                var newVoltageData: [SensorData] = []
                
                for await result in group {
                    tempFormattedVoltages.append(result.formattedVoltage)
                    newVoltageData.append(result.sensorData)
                }
                
                return (tempFormattedVoltages, newVoltageData)
            }
            
            let currentDataResults = await withTaskGroup(of: (formattedCurrent: String, sensorData: SensorData).self) { group in
                for sensor in fetchedCurrentSensors {
                    group.addTask {
                        let formattedCurrent = await formatter.formatCurrent(sensor.current)
                        let sensorData = SensorData(
                            timestamp: now,
                            sensorName: sensor.name,
                            value: sensor.current,
                            category: "Current"
                        )
                        return (formattedCurrent, sensorData)
                    }
                }
                
                var tempFormattedCurrents: [String] = []
                var newCurrentData: [SensorData] = []
                
                for await result in group {
                    tempFormattedCurrents.append(result.formattedCurrent)
                    newCurrentData.append(result.sensorData)
                }
                
                return (tempFormattedCurrents, newCurrentData)
            }
            
            let memoryDataResults = await withTaskGroup(of: (formattedValue: String, sensorData: SensorData).self) { group in
                for type in MemoryMetricType.allCases {
                    group.addTask {
                        let value: Double
                        let formattedValue: String
                        
                        switch type {
                        case .total:
                            value = Double(fetchedMemoryStats.totalMemory)
                            formattedValue = await formatter.formatBytes(fetchedMemoryStats.totalMemory)
                        case .free:
                            value = Double(fetchedMemoryStats.freeMemory)
                            formattedValue = await formatter.formatBytes(fetchedMemoryStats.freeMemory)
                        case .active:
                            value = Double(fetchedMemoryStats.activeMemory)
                            formattedValue = await formatter.formatBytes(fetchedMemoryStats.activeMemory)
                        case .wired:
                            value = Double(fetchedMemoryStats.wiredMemory)
                            formattedValue = await formatter.formatBytes(fetchedMemoryStats.wiredMemory)
                        case .used:
                            value = Double(fetchedMemoryStats.totalUsedMemory)
                            formattedValue = await formatter.formatBytes(fetchedMemoryStats.totalUsedMemory)
                        }
                        
                        let sensorData = SensorData(
                            timestamp: now,
                            sensorName: type.name,
                            value: value,
                            category: "Memory"
                        )
                        
                        return (formattedValue, sensorData)
                    }
                }
                
                var tempFormattedMemoryValues: [String] = []
                var newMemoryData: [SensorData] = []
                
                for await result in group {
                    tempFormattedMemoryValues.append(result.formattedValue)
                    newMemoryData.append(result.sensorData)
                }
                
                return (tempFormattedMemoryValues, newMemoryData)
            }
            
            let cpuDataResults = await withTaskGroup(of: (formattedValue: String, sensorData: SensorData).self) { group in
                for type in CPUMetricType.allCases {
                    group.addTask {
                        let value: Double
                        let formattedValue: String
                        
                        switch type {
                        case .total:
                            value = fetchedCPUStats.totalUsage
                            formattedValue = await formatter.formatPercentage(fetchedCPUStats.totalUsage)
                        case .user:
                            value = fetchedCPUStats.userUsage
                            formattedValue = await formatter.formatPercentage(fetchedCPUStats.userUsage)
                        case .system:
                            value = fetchedCPUStats.systemUsage
                            formattedValue = await formatter.formatPercentage(fetchedCPUStats.systemUsage)
                        }
                        
                        let sensorData = SensorData(
                            timestamp: now,
                            sensorName: type.name,
                            value: value,
                            category: "CPU"
                        )
                        
                        return (formattedValue, sensorData)
                    }
                }
                
                var tempFormattedCPUValues: [String] = []
                var newCPUData: [SensorData] = []
                
                for await result in group {
                    tempFormattedCPUValues.append(result.formattedValue)
                    newCPUData.append(result.sensorData)
                }
                
                return (tempFormattedCPUValues, newCPUData)
            }
            
            let diskDataResults = await withTaskGroup(of: (formattedValue: String, sensorData: SensorData).self) { group in
                for type in DiskMetricType.allCases {
                    group.addTask {
                        let value: Double
                        let formattedValue: String
                        
                        switch type {
                        case .total:
                            value = Double(fetchedDiskStats.totalSpace)
                            formattedValue = await formatter.formatBytes(fetchedDiskStats.totalSpace)
                        case .used:
                            value = Double(fetchedDiskStats.usedSpace)
                            formattedValue = await formatter.formatBytes(fetchedDiskStats.usedSpace)
                        case .free:
                            value = Double(fetchedDiskStats.freeSpace)
                            formattedValue = await formatter.formatBytes(fetchedDiskStats.freeSpace)
                        }
                        
                        let sensorData = SensorData(
                            timestamp: now,
                            sensorName: type.name,
                            value: value,
                            category: "Disk"
                        )
                        
                        return (formattedValue, sensorData)
                    }
                }
                
                var tempFormattedDiskValues: [String] = []
                var newDiskData: [SensorData] = []
                
                for await result in group {
                    tempFormattedDiskValues.append(result.formattedValue)
                    newDiskData.append(result.sensorData)
                }
                
                return (tempFormattedDiskValues, newDiskData)
            }
            
            let (tempFormattedTemperatures, newThermalData) = thermalDataResults
            let (tempFormattedVoltages, newVoltageData) = voltageDataResults
            let (tempFormattedCurrents, newCurrentData) = currentDataResults
            let (tempFormattedMemoryValues, newMemoryData) = memoryDataResults
            let (tempFormattedCPUValues, newCPUData) = cpuDataResults
            let (tempFormattedDiskValues, newDiskData) = diskDataResults
            
            await MainActor.run {
                // Get a reference to self to avoid capturing mutable properties
                let viewModel = SensorsViewModel.shared
                
                // Update all sensor data
                viewModel.thermalSensors = fetchedThermalSensors
                viewModel.voltageSensors = fetchedVoltageSensors
                viewModel.currentSensors = fetchedCurrentSensors
                viewModel.memoryStats = fetchedMemoryStats
                viewModel.cpuStats = fetchedCPUStats
                viewModel.diskStats = fetchedDiskStats
                viewModel.thermalState = fetchedThermalState
                viewModel.uptimeText = fetchedUptimeText
                
                // Update formatted values - all of these are now local immutable values
                viewModel.formattedTemperatures = tempFormattedTemperatures
                viewModel.formattedVoltages = tempFormattedVoltages
                viewModel.formattedCurrents = tempFormattedCurrents
                viewModel.formattedMemoryValues = tempFormattedMemoryValues
                viewModel.formattedCPUValues = tempFormattedCPUValues
                viewModel.formattedDiskValues = tempFormattedDiskValues
                
                // Update historical data collections
                viewModel.thermalSensorData.append(contentsOf: newThermalData)
                viewModel.voltageSensorData.append(contentsOf: newVoltageData)
                viewModel.currentSensorData.append(contentsOf: newCurrentData)
                viewModel.memoryMetricData.append(contentsOf: newMemoryData)
                viewModel.cpuMetricData.append(contentsOf: newCPUData)
                viewModel.diskMetricData.append(contentsOf: newDiskData)
                
                // Cap data collections to manage memory (3 hours of data at 1 reading per second)
                let maxDataPoints = 3 * 60 * 60
                
                // Cap each data collection
                if viewModel.thermalSensorData.count > maxDataPoints {
                    viewModel.thermalSensorData = Array(viewModel.thermalSensorData.suffix(maxDataPoints))
                }
                
                if viewModel.voltageSensorData.count > maxDataPoints {
                    viewModel.voltageSensorData = Array(viewModel.voltageSensorData.suffix(maxDataPoints))
                }
                
                if viewModel.currentSensorData.count > maxDataPoints {
                    viewModel.currentSensorData = Array(viewModel.currentSensorData.suffix(maxDataPoints))
                }
                
                if viewModel.memoryMetricData.count > maxDataPoints {
                    viewModel.memoryMetricData = Array(viewModel.memoryMetricData.suffix(maxDataPoints))
                }
                
                if viewModel.cpuMetricData.count > maxDataPoints {
                    viewModel.cpuMetricData = Array(viewModel.cpuMetricData.suffix(maxDataPoints))
                }
                
                if viewModel.diskMetricData.count > maxDataPoints {
                    viewModel.diskMetricData = Array(viewModel.diskMetricData.suffix(maxDataPoints))
                }
                
                // Update timestamp
                viewModel.lastUpdateTime = now
            }
        }
    }
}
