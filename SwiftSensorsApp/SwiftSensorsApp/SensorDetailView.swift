import SwiftUI
import SwiftSensors
import Charts

@available(iOS 16.0, *)
struct TemperatureReading: Identifiable {
    let id = UUID()
    let timestamp: Date
    let temperature: Double
}

@available(iOS 16.0, *)
@Observable class SensorReadingsStore {
    var readings: [TemperatureReading] = []
    var minTemperature: Double = 0
    var maxTemperature: Double = 0
    var avgTemperature: Double = 0
    var currentTemperature: Double = 0
    
    // Cache for readings by sensor name
    static var stores: [String: SensorReadingsStore] = [:]
    
    // Get or create a store for a sensor
    static func getStore(for sensorName: String) -> SensorReadingsStore {
        if let existingStore = stores[sensorName] {
            return existingStore
        }
        let newStore = SensorReadingsStore()
        stores[sensorName] = newStore
        return newStore
    }
}

@available(iOS 16.0, *)
struct SensorDetailView: View {
    let sensorName: String
    
    // With @Observable, we can use a simple property
    private var store: SensorReadingsStore
    
    // Timer for updating readings
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(sensorName: String) {
        self.sensorName = sensorName
        // Get or create a persistent store for this sensor
        self.store = SensorReadingsStore.getStore(for: sensorName)
    }
    
    var body: some View {
        VStack {
            // Current reading display
            HStack(alignment: .bottom) {
                Text(String(format: "%.1f", store.currentTemperature))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("°C")
                    .font(.title)
                    .padding(.bottom, 8)
            }
            .padding()
            
            // Statistics display
            HStack(spacing: 20) {
                StatBox(title: "Min", value: String(format: "%.1f°C", store.minTemperature))
                StatBox(title: "Avg", value: String(format: "%.1f°C", store.avgTemperature))
                StatBox(title: "Max", value: String(format: "%.1f°C", store.maxTemperature))
            }
            .padding()
            
            // Chart display
            Chart {
                ForEach(store.readings) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("Temperature", reading.temperature)
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.catmullRom)
                }
                
                RuleMark(y: .value("Average", store.avgTemperature))
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .trailing) {
                        Text("Avg")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
            }
            .chartYScale(domain: max(0.1, store.minTemperature-1)...max(1, store.maxTemperature+1))
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let temp = value.as(Double.self) {
                            Text("\(Int(temp))°")
                        }
                    }
                }
            }
            .frame(height: 300)
            .padding()
            
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

@available(iOS 16.0, *)
struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(minWidth: 80)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}