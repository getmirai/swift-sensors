import SwiftUI
import Charts
import SwiftSensors

/// Chart display for multiple thermal sensors
struct MultiSensorChart: View {
    /// The sensors to display in the chart
    let sensors: [ThermalSensor]
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    /// Local sensor data storage
    @State private var sensorData: [SensorData] = []
    
    /// Timer for data collection
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if !filteredData.isEmpty {
                Chart(filteredData) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("Temperature", reading.value)
                    )
                    .foregroundStyle(by: .value("Sensor", reading.sensorName))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let temp = value.as(Double.self) {
                                Text("\(Int(temp))°C")
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
        let now = Date()
        
        // Add data points for each sensor
        for sensor in sensors {
            let dataPoint = SensorData(
                timestamp: now,
                sensorName: sensor.name,
                value: sensor.temperature
            )
            sensorData.append(dataPoint)
        }
        
        // Cap the data to manage memory
        let maxPoints = 3 * 60 * 60 // 3 hours of data at 1 reading per second
        if sensorData.count > maxPoints {
            sensorData = Array(sensorData.suffix(maxPoints))
        }
    }
    
    /// Data filtered by time window
    private var filteredData: [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return sensorData.filter { reading in
            reading.timestamp > cutoffDate && 
            sensors.contains(where: { $0.name == reading.sensorName })
        }
    }
}

/// Chart display for voltage sensors
struct VoltageChart: View {
    /// The sensors to display in the chart
    let sensors: [VoltageSensor]
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    /// Local sensor data storage
    @State private var sensorData: [SensorData] = []
    
    /// Timer for data collection
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if !filteredData.isEmpty {
                Chart(filteredData) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("Voltage", reading.value)
                    )
                    .foregroundStyle(by: .value("Sensor", reading.sensorName))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let voltage = value.as(Double.self) {
                                Text("\(voltage, specifier: "%.2f") V")
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
        let now = Date()
        
        // Add data points for each sensor
        for sensor in sensors {
            let dataPoint = SensorData(
                timestamp: now,
                sensorName: sensor.name,
                value: sensor.voltage
            )
            sensorData.append(dataPoint)
        }
        
        // Cap the data to manage memory
        let maxPoints = 3 * 60 * 60 // 3 hours of data at 1 reading per second
        if sensorData.count > maxPoints {
            sensorData = Array(sensorData.suffix(maxPoints))
        }
    }
    
    /// Data filtered by time window
    private var filteredData: [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return sensorData.filter { reading in
            reading.timestamp > cutoffDate && 
            sensors.contains(where: { $0.name == reading.sensorName })
        }
    }
}

/// Chart display for current sensors
struct CurrentChart: View {
    /// The sensors to display in the chart
    let sensors: [CurrentSensor]
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    /// Local sensor data storage
    @State private var sensorData: [SensorData] = []
    
    /// Timer for data collection
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if !filteredData.isEmpty {
                Chart(filteredData) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("Current", reading.value)
                    )
                    .foregroundStyle(by: .value("Sensor", reading.sensorName))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let current = value.as(Double.self) {
                                if abs(current) < 0.001 {
                                    Text("\(current * 1_000_000, specifier: "%.1f") μA")
                                } else if abs(current) < 1.0 {
                                    Text("\(current * 1_000, specifier: "%.1f") mA")
                                } else {
                                    Text("\(current, specifier: "%.2f") A")
                                }
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
        let now = Date()
        
        // Add data points for each sensor
        for sensor in sensors {
            let dataPoint = SensorData(
                timestamp: now,
                sensorName: sensor.name,
                value: sensor.current
            )
            sensorData.append(dataPoint)
        }
        
        // Cap the data to manage memory
        let maxPoints = 3 * 60 * 60 // 3 hours of data at 1 reading per second
        if sensorData.count > maxPoints {
            sensorData = Array(sensorData.suffix(maxPoints))
        }
    }
    
    /// Data filtered by time window
    private var filteredData: [SensorData] {
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return sensorData.filter { reading in
            reading.timestamp > cutoffDate && 
            sensors.contains(where: { $0.name == reading.sensorName })
        }
    }
}