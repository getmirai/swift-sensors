import SwiftUI
import SwiftSensors
import Charts

@available(iOS 16.0, *)
@Observable class SensorsViewModel {
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
    
    static let shared = SensorsViewModel()
    
    private init() {
        // Initial data load
        updateSensorData()
    }
    
    func updateIfNeeded() {
        let now = Date()
        if now.timeIntervalSince(lastUpdateTime) > updateInterval {
            updateSensorData()
        }
    }
    
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

@available(iOS 16.0, *)
struct ContentView: View {
    // With @Observable, we no longer need @StateObject
    private var viewModel = SensorsViewModel.shared
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Thermal Sensors")) {
                    ForEach(Array(zip(viewModel.thermalSensors.indices, viewModel.thermalSensors)), id: \.1.id) { index, sensor in
                        NavigationLink {
                            // Use a stable identifier for the detail view
                            SensorDetailView(sensorName: sensor.name)
                                // Add an id to ensure SwiftUI treats this as a stable view
                                .id(sensor.name)
                        } label: {
                            HStack {
                                Text(sensor.name)
                                Spacer()
                                Text(index < viewModel.formattedTemperatures.count ? viewModel.formattedTemperatures[index] : "\(sensor.temperature) °C")
                            }
                        }
                    }
                    
                    if viewModel.thermalSensors.isEmpty {
                        Text("No thermal sensors found")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("Memory Information")) {
                    if viewModel.memoryStats != nil, viewModel.formattedMemoryValues.count >= 5 {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(viewModel.formattedMemoryValues[0])
                        }
                        
                        HStack {
                            Text("Free")
                            Spacer()
                            Text(viewModel.formattedMemoryValues[1])
                        }
                        
                        HStack {
                            Text("Active")
                            Spacer()
                            Text(viewModel.formattedMemoryValues[2])
                        }
                        
                        HStack {
                            Text("Wired")
                            Spacer()
                            Text(viewModel.formattedMemoryValues[3])
                        }
                        
                        HStack {
                            Text("Used")
                            Spacer()
                            Text(viewModel.formattedMemoryValues[4])
                        }
                    } else {
                        Text("Loading memory information...")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("CPU Information")) {
                    if let stats = viewModel.cpuStats, viewModel.formattedCPUValues.count >= 3 {
                        HStack {
                            Text("CPU Usage")
                            Spacer()
                            Text(viewModel.formattedCPUValues[0])
                        }
                        
                        HStack {
                            Text("User")
                            Spacer()
                            Text(viewModel.formattedCPUValues[1])
                        }
                        
                        HStack {
                            Text("System")
                            Spacer()
                            Text(viewModel.formattedCPUValues[2])
                        }
                        
                        HStack {
                            Text("Active Processors")
                            Spacer()
                            Text("\(stats.activeProcessors) / \(stats.totalProcessors)")
                        }
                    } else {
                        Text("Loading CPU information...")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("Disk Information")) {
                    if viewModel.diskStats != nil, viewModel.formattedDiskValues.count >= 3 {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(viewModel.formattedDiskValues[0])
                        }
                        
                        HStack {
                            Text("Used")
                            Spacer()
                            Text(viewModel.formattedDiskValues[1])
                        }
                        
                        HStack {
                            Text("Free")
                            Spacer()
                            Text(viewModel.formattedDiskValues[2])
                        }
                    } else {
                        Text("Loading disk information...")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("System")) {
                    HStack {
                        Text("Thermal State")
                        Spacer()
                        Text(viewModel.thermalState.rawValue)
                            .foregroundColor(thermalStateColor(viewModel.thermalState))
                    }
                    
                    HStack {
                        Text("Uptime")
                        Spacer()
                        Text(viewModel.uptimeText)
                    }
                }
                
                Section(header: Text("Voltage Sensors")) {
                    ForEach(Array(zip(viewModel.voltageSensors.indices, viewModel.voltageSensors)), id: \.1.id) { index, sensor in
                        HStack {
                            Text(sensor.name)
                            Spacer()
                            Text(index < viewModel.formattedVoltages.count ? viewModel.formattedVoltages[index] : "\(sensor.voltage) V")
                        }
                    }
                    
                    if viewModel.voltageSensors.isEmpty {
                        Text("No voltage sensors found")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("Current Sensors")) {
                    ForEach(Array(zip(viewModel.currentSensors.indices, viewModel.currentSensors)), id: \.1.id) { index, sensor in
                        HStack {
                            Text(sensor.name)
                            Spacer()
                            Text(index < viewModel.formattedCurrents.count ? viewModel.formattedCurrents[index] : "\(sensor.current) A")
                        }
                    }
                    
                    if viewModel.currentSensors.isEmpty {
                        Text("No current sensors found")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section {
                    NavigationLink(destination: SensorChartView()) {
                        Text("View Temperature Charts")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    NavigationLink(destination: Text("Power Charts Coming Soon")) {
                        Text("View Power Charts")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("SwiftSensors")
            .onAppear {
                viewModel.updateIfNeeded()
            }
            .onReceive(timer) { _ in
                viewModel.updateIfNeeded()
            }
        }
    }
    
    private func thermalStateColor(_ state: ThermalState) -> Color {
        switch state {
        case .nominal:
            return .green
        case .fair:
            return .yellow
        case .serious:
            return .orange
        case .critical:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    // Deprecated method - use viewModel.updateIfNeeded() instead
    private func updateSensorData() {
        viewModel.updateIfNeeded()
    }
}