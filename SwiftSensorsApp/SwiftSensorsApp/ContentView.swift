import SwiftUI
import SwiftSensors
import Charts

@available(iOS 16.0, *)
struct ContentView: View {
    @State private var thermalSensors: [ThermalSensor] = []
    @State private var voltageSensors: [VoltageSensor] = []
    @State private var currentSensors: [CurrentSensor] = []
    @State private var memoryStats: MemoryStats? = nil
    @State private var cpuStats: CPUStats? = nil
    @State private var diskStats: DiskStats? = nil
    @State private var thermalState: ThermalState = .unknown
    @State private var uptimeText: String = "Loading..."
    
    // Formatted display values
    @State private var formattedTemperatures: [String] = []
    @State private var formattedVoltages: [String] = []
    @State private var formattedCurrents: [String] = []
    @State private var formattedMemoryValues: [String] = []
    @State private var formattedCPUValues: [String] = []
    @State private var formattedDiskValues: [String] = []
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let formatter = SensorFormatter.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Thermal Sensors")) {
                    ForEach(Array(zip(thermalSensors.indices, thermalSensors)), id: \.1.id) { index, sensor in
                        NavigationLink(destination: SensorDetailView(sensorName: sensor.name)) {
                            HStack {
                                Text(sensor.name)
                                Spacer()
                                Text(index < formattedTemperatures.count ? formattedTemperatures[index] : "\(sensor.temperature) °C")
                            }
                        }
                    }
                    
                    if thermalSensors.isEmpty {
                        Text("No thermal sensors found")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("Memory Information")) {
                    if memoryStats != nil, formattedMemoryValues.count >= 5 {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(formattedMemoryValues[0])
                        }
                        
                        HStack {
                            Text("Free")
                            Spacer()
                            Text(formattedMemoryValues[1])
                        }
                        
                        HStack {
                            Text("Active")
                            Spacer()
                            Text(formattedMemoryValues[2])
                        }
                        
                        HStack {
                            Text("Wired")
                            Spacer()
                            Text(formattedMemoryValues[3])
                        }
                        
                        HStack {
                            Text("Used")
                            Spacer()
                            Text(formattedMemoryValues[4])
                        }
                    } else {
                        Text("Loading memory information...")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("CPU Information")) {
                    if let stats = cpuStats, formattedCPUValues.count >= 3 {
                        HStack {
                            Text("CPU Usage")
                            Spacer()
                            Text(formattedCPUValues[0])
                        }
                        
                        HStack {
                            Text("User")
                            Spacer()
                            Text(formattedCPUValues[1])
                        }
                        
                        HStack {
                            Text("System")
                            Spacer()
                            Text(formattedCPUValues[2])
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
                    if diskStats != nil, formattedDiskValues.count >= 3 {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(formattedDiskValues[0])
                        }
                        
                        HStack {
                            Text("Used")
                            Spacer()
                            Text(formattedDiskValues[1])
                        }
                        
                        HStack {
                            Text("Free")
                            Spacer()
                            Text(formattedDiskValues[2])
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
                        Text(thermalState.rawValue)
                            .foregroundColor(thermalStateColor(thermalState))
                    }
                    
                    HStack {
                        Text("Uptime")
                        Spacer()
                        Text(uptimeText)
                    }
                }
                
                Section(header: Text("Voltage Sensors")) {
                    ForEach(Array(zip(voltageSensors.indices, voltageSensors)), id: \.1.id) { index, sensor in
                        HStack {
                            Text(sensor.name)
                            Spacer()
                            Text(index < formattedVoltages.count ? formattedVoltages[index] : "\(sensor.voltage) V")
                        }
                    }
                    
                    if voltageSensors.isEmpty {
                        Text("No voltage sensors found")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("Current Sensors")) {
                    ForEach(Array(zip(currentSensors.indices, currentSensors)), id: \.1.id) { index, sensor in
                        HStack {
                            Text(sensor.name)
                            Spacer()
                            Text(index < formattedCurrents.count ? formattedCurrents[index] : "\(sensor.current) A")
                        }
                    }
                    
                    if currentSensors.isEmpty {
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
                updateSensorData()
            }
            .onReceive(timer) { _ in
                updateSensorData()
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
    
    private func updateSensorData() {
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
            }
        }
    }
}