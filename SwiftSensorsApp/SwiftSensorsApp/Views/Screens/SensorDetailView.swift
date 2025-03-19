import SwiftUI
import SwiftSensors

/// Detail view for a specific temperature sensor
@available(iOS 16.0, *)
struct SensorDetailView: View {
    /// The name of the sensor
    let sensorName: String
    
    /// Data store for this sensor
    private var store: SensorReadingsStore
    
    /// Timer for updating readings
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(sensorName: String) {
        self.sensorName = sensorName
        // Get or create a persistent store for this sensor
        self.store = SensorReadingsStore.getStore(for: sensorName)
    }
    
    var body: some View {
        VStack {
            // Current temperature display
            TemperatureDisplay(temperature: store.currentTemperature)
            
            // Statistics display
            TemperatureStats(
                minTemperature: store.minTemperature,
                avgTemperature: store.avgTemperature,
                maxTemperature: store.maxTemperature
            )
            
            // Chart display
            TemperatureChart(store: store)
            
            Spacer()
        }
        .navigationTitle(sensorName)
        .onAppear {
            updateReadings()
        }
        .onReceive(timer) { _ in
            updateReadings()
        }
    }
    
    /// Updates the sensor readings
    private func updateReadings() {
        // Use Task for async calls
        Task {
            // Get sensor from shared view model
            let viewModel = SensorsViewModel.shared
            
            // Ensure view model has updated data
            viewModel.updateIfNeeded()
            
            // Find our sensor by name - this will use the cached data
            guard let sensor = viewModel.thermalSensors.first(where: { $0.name == sensorName }) else { 
                print("Sensor not found: \(sensorName)")
                return 
            }
            
            // Update the store on the main thread
            await MainActor.run {
                // Add new reading
                let newReading = TemperatureReading(timestamp: Date(), temperature: sensor.temperature)
                store.readings.append(newReading)
                
                // Limit the number of readings to display (last 60 seconds)
                if store.readings.count > 60 {
                    store.readings.removeFirst(store.readings.count - 60)
                }
                
                // Update statistics
                store.currentTemperature = sensor.temperature
                store.minTemperature = store.readings.map { $0.temperature }.min() ?? 0
                store.maxTemperature = store.readings.map { $0.temperature }.max() ?? 0
                store.avgTemperature = store.readings.map { $0.temperature }.reduce(0, +) / Double(store.readings.count)
            }
        }
    }
}