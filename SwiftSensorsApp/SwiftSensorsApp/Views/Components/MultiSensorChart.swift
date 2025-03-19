import SwiftUI
import Charts

/// Chart display for multiple sensors

struct MultiSensorChart: View {
    /// Data for the chart
    let data: [SensorData]
    
    var body: some View {
        if !data.isEmpty {
            Chart(data) { reading in
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
            .frame(height: 300)
            .padding()
        } else {
            Text("Collecting data...")
                .frame(height: 300)
                .frame(maxWidth: .infinity)
        }
    }
}