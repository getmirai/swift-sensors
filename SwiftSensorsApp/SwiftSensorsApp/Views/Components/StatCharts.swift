import SwiftUI
import Charts
import SwiftSensors

/// Chart display for memory metrics
struct MemoryChart: View {
    /// The selected memory metrics to display
    let selectedItems: Set<Int>
    
    /// View model for data access
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    /// Local data storage
    @State private var memoryData: [SensorData] = []
    
    /// Timer for data collection
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Colors for different metrics
    private let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
    
    var body: some View {
        VStack {
            if !filteredData.isEmpty {
                Chart(filteredData) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("Memory", reading.value)
                    )
                    .foregroundStyle(by: .value("Metric", reading.sensorName))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text(formatBytes(UInt64(val)))
                            }
                        }
                    }
                }
            } else {
                Text("Collecting data...")
            }
            
            Picker("Time Window", selection: $timeWindow) {
                Text("1 minute").tag(TimeInterval(60))
                Text("5 minutes").tag(TimeInterval(5 * 60))
                Text("15 minutes").tag(TimeInterval(15 * 60))
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 8)
        }
        .onAppear {
            addCurrentReadings()
        }
        .onReceive(timer) { _ in
            addCurrentReadings()
        }
    }
    
    /// Adds the current readings
    private func addCurrentReadings() {
        guard let memStats = viewModel.memoryStats else { return }
        let now = Date()
        
        // Add data for each selected metric
        for item in selectedItems {
            guard let metricType = MemoryMetricType(rawValue: item) else { continue }
            
            // Get the appropriate value based on the selected metric
            let value: Double
            switch metricType {
            case .total:
                value = Double(memStats.totalMemory)
            case .free:
                value = Double(memStats.freeMemory)
            case .active:
                value = Double(memStats.activeMemory)
            case .wired:
                value = Double(memStats.wiredMemory)
            case .used:
                value = Double(memStats.totalUsedMemory)
            }
            
            let dataPoint = SensorData(
                timestamp: now,
                sensorName: metricType.name,
                value: value
            )
            memoryData.append(dataPoint)
        }
        
        // Cap the data to manage memory
        let maxPoints = 3 * 60 * 60 * selectedItems.count // 3 hours of data at 1 reading per second per metric
        if memoryData.count > maxPoints {
            memoryData = Array(memoryData.suffix(maxPoints))
        }
    }
    
    /// Data filtered by time window
    private var filteredData: [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return memoryData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedItems.contains { 
                MemoryMetricType(rawValue: $0)?.name == reading.sensorName 
            }
        }
    }
    
    /// Format bytes to human-readable string
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

/// Chart display for CPU metrics
struct CPUChart: View {
    /// The selected CPU metrics to display
    let selectedItems: Set<Int>
    
    /// View model for data access
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    /// Local data storage
    @State private var cpuData: [SensorData] = []
    
    /// Timer for data collection
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Colors for different metrics
    private let colors: [Color] = [.green, .blue, .orange]
    
    var body: some View {
        VStack {
            if !filteredData.isEmpty {
                Chart(filteredData) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("CPU Usage", reading.value)
                    )
                    .foregroundStyle(by: .value("Metric", reading.sensorName))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text("\(Int(val))%")
                            }
                        }
                    }
                }
                .chartYScale(domain: 0...100) // CPU usage is 0-100%
            } else {
                Text("Collecting data...")
            }
            
            Picker("Time Window", selection: $timeWindow) {
                Text("1 minute").tag(TimeInterval(60))
                Text("5 minutes").tag(TimeInterval(5 * 60))
                Text("15 minutes").tag(TimeInterval(15 * 60))
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 8)
        }
        .onAppear {
            addCurrentReadings()
        }
        .onReceive(timer) { _ in
            addCurrentReadings()
        }
    }
    
    /// Adds the current readings
    private func addCurrentReadings() {
        guard let cpuStats = viewModel.cpuStats else { return }
        let now = Date()
        
        // Add data for each selected metric
        for item in selectedItems {
            guard let metricType = CPUMetricType(rawValue: item) else { continue }
            
            // Get the appropriate value based on the selected metric
            let value: Double
            switch metricType {
            case .total:
                value = cpuStats.totalUsage
            case .user:
                value = cpuStats.userUsage
            case .system:
                value = cpuStats.systemUsage
            }
            
            let dataPoint = SensorData(
                timestamp: now,
                sensorName: metricType.name,
                value: value
            )
            cpuData.append(dataPoint)
        }
        
        // Cap the data to manage memory
        let maxPoints = 3 * 60 * 60 * selectedItems.count // 3 hours of data at 1 reading per second per metric
        if cpuData.count > maxPoints {
            cpuData = Array(cpuData.suffix(maxPoints))
        }
    }
    
    /// Data filtered by time window
    private var filteredData: [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return cpuData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedItems.contains { 
                CPUMetricType(rawValue: $0)?.name == reading.sensorName 
            }
        }
    }
}

/// Chart display for disk metrics
struct DiskChart: View {
    /// The selected disk metrics to display
    let selectedItems: Set<Int>
    
    /// View model for data access
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    /// Local data storage
    @State private var diskData: [SensorData] = []
    
    /// Timer for data collection
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Colors for different metrics
    private let colors: [Color] = [.orange, .red, .yellow]
    
    var body: some View {
        VStack {
            if !filteredData.isEmpty {
                Chart(filteredData) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("Disk Space", reading.value)
                    )
                    .foregroundStyle(by: .value("Metric", reading.sensorName))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text(formatBytes(UInt64(val)))
                            }
                        }
                    }
                }
            } else {
                Text("Collecting data...")
            }
            
            Picker("Time Window", selection: $timeWindow) {
                Text("1 minute").tag(TimeInterval(60))
                Text("5 minutes").tag(TimeInterval(5 * 60))
                Text("15 minutes").tag(TimeInterval(15 * 60))
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 8)
        }
        .onAppear {
            addCurrentReadings()
        }
        .onReceive(timer) { _ in
            addCurrentReadings()
        }
    }
    
    /// Adds the current readings
    private func addCurrentReadings() {
        guard let diskStats = viewModel.diskStats else { return }
        let now = Date()
        
        // Add data for each selected metric
        for item in selectedItems {
            guard let metricType = DiskMetricType(rawValue: item) else { continue }
            
            // Get the appropriate value based on the selected metric
            let value: Double
            switch metricType {
            case .total:
                value = Double(diskStats.totalSpace)
            case .used:
                value = Double(diskStats.usedSpace)
            case .free:
                value = Double(diskStats.freeSpace)
            }
            
            let dataPoint = SensorData(
                timestamp: now,
                sensorName: metricType.name,
                value: value
            )
            diskData.append(dataPoint)
        }
        
        // Cap the data to manage memory
        let maxPoints = 3 * 60 * 60 * selectedItems.count // 3 hours of data at 1 reading per second per metric
        if diskData.count > maxPoints {
            diskData = Array(diskData.suffix(maxPoints))
        }
    }
    
    /// Data filtered by time window
    private var filteredData: [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return diskData.filter { reading in
            reading.timestamp > cutoffDate &&
            selectedItems.contains { 
                DiskMetricType(rawValue: $0)?.name == reading.sensorName 
            }
        }
    }
    
    /// Format bytes to human-readable string
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}