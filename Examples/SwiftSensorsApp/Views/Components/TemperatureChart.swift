import Charts
import SwiftUI

/// Chart component for temperature readings

struct TemperatureChart: View {
    /// The store containing temperature readings
    let store: SensorReadingsStore

    var body: some View {
        Chart {
            ForEach(self.store.readings) { reading in
                LineMark(
                    x: .value("Time", reading.timestamp),
                    y: .value("Temperature", reading.temperature)
                )
                .foregroundStyle(Color.blue)
                .interpolationMethod(.catmullRom)
            }

            RuleMark(y: .value("Average", self.store.avgTemperature))
                .foregroundStyle(Color.gray.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .trailing) {
                    Text("Avg")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
        }
        .chartYScale(domain: max(0.1, self.store.minTemperature-1)...max(1, self.store.maxTemperature+1))
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
    }
}