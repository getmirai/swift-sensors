import SwiftSensors
import SwiftUI

/// Detail view for a specific temperature sensor

struct SensorDetailView: View {
    /// The name of the sensor
    let sensorName: String

    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel

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
            TemperatureDisplay(temperature: self.store.currentTemperature)

            // Statistics display
            TemperatureStats(
                minTemperature: self.store.minTemperature,
                avgTemperature: self.store.avgTemperature,
                maxTemperature: self.store.maxTemperature
            )

            // Chart display
            TemperatureChart(store: self.store)

            Spacer()
        }
        .navigationTitle(self.sensorName)
        .onAppear {
            self.updateReadings()
        }
        .onReceive(self.timer) { _ in
            self.updateReadings()
        }
    }

    /// Updates the sensor readings
    private func updateReadings() {
        // Use Task for async calls
        Task {
            // Use the viewModel property

            // Ensure view model has updated data
            self.viewModel.updateIfNeeded()

            // Find our sensor by name - this will use the cached data
            guard let sensor = viewModel.thermalSensors.first(where: { $0.name == sensorName }) else {
                print("Sensor not found: \(self.sensorName)")
                return
            }

            // Update the store on the main thread
            await MainActor.run {
                // Add new reading
                let newReading = TemperatureReading(timestamp: Date(), temperature: sensor.temperature)
                self.store.readings.append(newReading)

                // Limit the number of readings to display (last 60 seconds)
                if self.store.readings.count > 60 {
                    self.store.readings.removeFirst(self.store.readings.count - 60)
                }

                // Update statistics
                self.store.currentTemperature = sensor.temperature
                self.store.minTemperature = self.store.readings.map(\.temperature).min() ?? 0
                self.store.maxTemperature = self.store.readings.map(\.temperature).max() ?? 0
                self.store.avgTemperature = self.store.readings.map(\.temperature).reduce(0, +) / Double(self.store.readings.count)
            }
        }
    }
}