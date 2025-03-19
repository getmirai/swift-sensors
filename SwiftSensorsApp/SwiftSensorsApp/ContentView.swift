import SwiftUI
import SwiftSensors

@available(iOS 16.0, *)
struct ContentView: View {
    @State private var thermalSensors: [ThermalSensor] = []
    @State private var memoryStats: MemoryStats? = nil
    @State private var cpuStats: CPUStats? = nil
    @State private var diskStats: DiskStats? = nil
    @State private var thermalState: ThermalState = .unknown
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let formatter = SensorFormatter.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Thermal Sensors")) {
                    ForEach(thermalSensors) { sensor in
                        NavigationLink(destination: SensorDetailView(sensorName: sensor.name)) {
                            HStack {
                                Text(sensor.name)
                                Spacer()
                                Text(formatter.formatTemperature(sensor.temperature))
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
                    if let stats = memoryStats {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(formatter.formatBytes(stats.totalMemory))
                        }
                        
                        HStack {
                            Text("Free")
                            Spacer()
                            Text(formatter.formatBytes(stats.freeMemory))
                        }
                        
                        HStack {
                            Text("Active")
                            Spacer()
                            Text(formatter.formatBytes(stats.activeMemory))
                        }
                        
                        HStack {
                            Text("Wired")
                            Spacer()
                            Text(formatter.formatBytes(stats.wiredMemory))
                        }
                        
                        HStack {
                            Text("Used")
                            Spacer()
                            Text(formatter.formatBytes(stats.totalUsedMemory))
                        }
                    } else {
                        Text("Loading memory information...")
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Section(header: Text("CPU Information")) {
                    if let stats = cpuStats {
                        HStack {
                            Text("CPU Usage")
                            Spacer()
                            Text(formatter.formatPercentage(stats.totalUsage))
                        }
                        
                        HStack {
                            Text("User")
                            Spacer()
                            Text(formatter.formatPercentage(stats.userUsage))
                        }
                        
                        HStack {
                            Text("System")
                            Spacer()
                            Text(formatter.formatPercentage(stats.systemUsage))
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
                    if let stats = diskStats {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(formatter.formatBytes(stats.totalSpace))
                        }
                        
                        HStack {
                            Text("Used")
                            Spacer()
                            Text(formatter.formatBytes(stats.usedSpace))
                        }
                        
                        HStack {
                            Text("Free")
                            Spacer()
                            Text(formatter.formatBytes(stats.freeSpace))
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
                        Text(SwiftSensors.shared.getFormattedUptime())
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
        
        // Update thermal sensors
        thermalSensors = sensors.getThermalSensors()
        
        // Update memory, CPU, and disk stats
        memoryStats = sensors.getMemoryStats()
        cpuStats = sensors.getCPUStats()
        diskStats = sensors.getDiskStats()
        
        // Update thermal state
        thermalState = sensors.getThermalState()
    }
}