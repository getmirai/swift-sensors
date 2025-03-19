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
struct SensorDetailView: View {
    let sensorName: String
    
    @State private var readings: [TemperatureReading] = []
    @State private var minTemperature: Double = 0
    @State private var maxTemperature: Double = 0
    @State private var avgTemperature: Double = 0
    @State private var currentTemperature: Double = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // Current reading display
            HStack(alignment: .bottom) {
                Text(String(format: "%.1f", currentTemperature))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("°C")
                    .font(.title)
                    .padding(.bottom, 8)
            }
            .padding()
            
            // Statistics display
            HStack(spacing: 20) {
                StatBox(title: "Min", value: String(format: "%.1f°C", minTemperature))
                StatBox(title: "Avg", value: String(format: "%.1f°C", avgTemperature))
                StatBox(title: "Max", value: String(format: "%.1f°C", maxTemperature))
            }
            .padding()
            
            // Chart display
            Chart {
                ForEach(readings) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value("Temperature", reading.temperature)
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.catmullRom)
                }
                
                RuleMark(y: .value("Average", avgTemperature))
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .trailing) {
                        Text("Avg")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
            }
            .chartYScale(domain: (minTemperature-1)...(maxTemperature+1))
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
            // Get current temperature for this sensor
            let allSensors = await SwiftSensors.shared.getThermalSensors()
            guard let sensor = allSensors.first(where: { $0.name == sensorName }) else { return }
            
            // Add new reading
            let newReading = TemperatureReading(timestamp: Date(), temperature: sensor.temperature)
            readings.append(newReading)
            
            // Limit the number of readings to display (last 60 seconds)
            if readings.count > 60 {
                readings.removeFirst(readings.count - 60)
            }
            
            // Update statistics
            currentTemperature = sensor.temperature
            minTemperature = readings.map { $0.temperature }.min() ?? 0
            maxTemperature = readings.map { $0.temperature }.max() ?? 0
            avgTemperature = readings.map { $0.temperature }.reduce(0, +) / Double(readings.count)
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