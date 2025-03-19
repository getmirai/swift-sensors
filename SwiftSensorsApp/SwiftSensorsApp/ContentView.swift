import SwiftUI
import SwiftSensors

@available(iOS 16.0, *)
struct ContentView: View {
    @State private var thermalSensors: [ThermalSensor] = []
    @State private var memoryStats: MemoryStats? = nil
    @State private var cpuStats: CPUStats? = nil
    @State private var diskStats: DiskStats? = nil
    @State private var thermalState: ThermalState = .unknown
    @State private var uptimeText: String = "Loading..."
    
    // Formatted display values
    @State private var formattedTemperatures: [String] = []
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
                
                Section {
                    NavigationLink(destination: SensorChartView()) {
                        Text("View Temperature Charts")
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
            // Update thermal sensors
            thermalSensors = await sensors.getThermalSensors()
            
            // Format temperature values
            formattedTemperatures = await withTaskGroup(of: String.self) { group in
                for sensor in thermalSensors {
                    group.addTask {
                        await formatter.formatTemperature(sensor.temperature)
                    }
                }
                
                var results: [String] = []
                for await result in group {
                    results.append(result)
                }
                return results
            }
            
            // Update memory, CPU, and disk stats
            memoryStats = await sensors.getMemoryStats()
            if let stats = memoryStats {
                // Format memory values
                formattedMemoryValues = await [
                    formatter.formatBytes(stats.totalMemory),
                    formatter.formatBytes(stats.freeMemory),
                    formatter.formatBytes(stats.activeMemory),
                    formatter.formatBytes(stats.wiredMemory),
                    formatter.formatBytes(stats.totalUsedMemory)
                ]
            }
            
            cpuStats = await sensors.getCPUStats()
            if let stats = cpuStats {
                // Format CPU values
                formattedCPUValues = await [
                    formatter.formatPercentage(stats.totalUsage),
                    formatter.formatPercentage(stats.userUsage),
                    formatter.formatPercentage(stats.systemUsage)
                ]
            }
            
            diskStats = await sensors.getDiskStats()
            if let stats = diskStats {
                // Format disk values
                formattedDiskValues = await [
                    formatter.formatBytes(stats.totalSpace),
                    formatter.formatBytes(stats.usedSpace),
                    formatter.formatBytes(stats.freeSpace)
                ]
            }
            
            // Update thermal state
            thermalState = await sensors.getThermalState()
            
            // Update uptime
            uptimeText = await sensors.getFormattedUptime()
        }
    }
}