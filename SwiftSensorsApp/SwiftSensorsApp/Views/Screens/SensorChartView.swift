import SwiftUI
import Charts
import SwiftSensors

/// Chart view showing multiple sensors over time

struct SensorChartView: View {
    /// Data collected from sensors
    @State private var thermalData: [SensorData] = []
    
    /// Currently selected sensors for display
    @State private var selectedSensors: Set<String> = []
    
    /// All available sensors
    @State private var availableSensors: [String] = []
    
    /// Time window for display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds of data
    
    /// Timer for updating data
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // Chart display
            MultiSensorChart(data: filteredData)
            
            // Time window selector
            TimeWindowPicker(timeWindow: $timeWindow)
            
            // Sensor selector
            SensorSelector(
                availableSensors: availableSensors,
                selectedSensors: $selectedSensors
            )
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
    
    /// Filtered data based on selected sensors and time window
    private var filteredData: [SensorData] {
        // Filter by selected sensors and time window
        let cutoffDate = Date().addingTimeInterval(-timeWindow)
        return thermalData.filter { data in
            selectedSensors.contains(data.sensorName) && data.timestamp > cutoffDate
        }
    }
    
    /// Updates sensor data from the view model
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