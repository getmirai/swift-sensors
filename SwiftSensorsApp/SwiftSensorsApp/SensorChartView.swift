import SwiftUI
import Charts
import SwiftSensors

@available(iOS 16.0, *)
struct SensorData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let sensorName: String
    let value: Double
}

@available(iOS 16.0, *)
struct SensorChartView: View {
    @State private var thermalData: [SensorData] = []
    @State private var selectedSensors: Set<String> = []
    @State private var availableSensors: [String] = []
    @State private var timeWindow: TimeInterval = 60 // 60 seconds of data
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if !thermalData.isEmpty {
                Chart(filteredData) { data in
                    LineMark(
                        x: .value("Time", data.timestamp),
                        y: .value("Temperature", data.value)
                    )
                    .foregroundStyle(by: .value("Sensor", data.sensorName))
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
                .frame(height: 300)
                .padding()
            } else {
                Text("Collecting data...")
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
            }
            
            Picker("Time Window", selection: $timeWindow) {
                Text("1 minute").tag(TimeInterval(60))
                Text("5 minutes").tag(TimeInterval(5 * 60))
                Text("15 minutes").tag(TimeInterval(15 * 60))
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List {
                Section(header: Text("Select Sensors")) {
                    ForEach(availableSensors, id: \.self) { sensor in
                        Button(action: {
                            if selectedSensors.contains(sensor) {
                                selectedSensors.remove(sensor)
                            } else {
                                selectedSensors.insert(sensor)
                            }
                        }) {
                            HStack {
                                Text(sensor)
                                Spacer()
                                if selectedSensors.contains(sensor) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Temperature Chart")
        .onAppear {
            // Get initial data
            updateSensorData()
        }
        .onReceive(timer) { _ in
            updateSensorData()
        }
    }
    
    private var filteredData: [SensorData] {
        // Filter by selected sensors and time window
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return thermalData.filter { data in
            selectedSensors.contains(data.sensorName) && data.timestamp > cutoffDate
        }
    }
    
    private func updateSensorData() {
        // Use Task for async calls
        Task {
            // Get shared view model
            let viewModel = SensorsViewModel.shared
            
            // Ensure view model has updated data
            viewModel.updateIfNeeded()
            
            // Use cached sensors from the view model
            let sensors = viewModel.thermalSensors
            let now = Date()
            
            // Update UI on the main thread
            await MainActor.run {
                // Create new data points
                let newData = sensors.map { SensorData(timestamp: now, sensorName: $0.name, value: $0.temperature) }
                thermalData.append(contentsOf: newData)
                
                // Keep data capped to 3 hours worth of points to manage memory
                let maxPoints = 3 * 60 * 60 // 3 hours with 1 reading per second
                if thermalData.count > maxPoints {
                    thermalData = Array(thermalData.suffix(maxPoints))
                }
                
                // Update available sensors list if needed
                let sensorNames = Set(sensors.map { $0.name })
                if sensorNames != Set(availableSensors) {
                    availableSensors = Array(sensorNames).sorted()
                    
                    // Auto-select sensors if none are selected yet
                    if selectedSensors.isEmpty && !availableSensors.isEmpty {
                        // Select up to 3 sensors by default
                        let sensorsToSelect = min(3, availableSensors.count)
                        selectedSensors = Set(availableSensors.prefix(sensorsToSelect))
                    }
                }
            }
        }
    }
}
