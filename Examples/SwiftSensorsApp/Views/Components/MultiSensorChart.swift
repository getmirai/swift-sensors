import Charts
import SwiftSensors
import SwiftUI

/// A generic base chart for displaying sensor data
struct BaseChartView: View {
    /// Data to display on the chart
    let data: [SensorData]

    /// Title for the Y-axis
    let yAxisTitle: String

    /// Function to format Y-axis values
    let formatYValue: (Double) -> String

    /// Time window to display
    @Binding var timeWindow: TimeInterval

    var body: some View {
        VStack {
            if !self.data.isEmpty {
                Chart(self.data) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value(self.yAxisTitle, reading.value)
                    )
                    .foregroundStyle(by: .value("Sensor", reading.sensorName))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text(self.formatYValue(val))
                            }
                        }
                    }
                }
            } else {
                Text("Collecting data...")
            }

            TimeWindowPicker(timeWindow: self.$timeWindow)
        }
    }
}

/// Chart display for thermal sensors using the unified model
struct MultiSensorChart: View {
    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel

    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default

    var body: some View {
        BaseChartView(
            data: self.viewModel.filteredThermalData(timeWindow: self.timeWindow),
            yAxisTitle: "Temperature",
            formatYValue: { "\(Int($0))°C" },
            timeWindow: self.$timeWindow
        )
        .onAppear {
            self.viewModel.updateIfNeeded()
        }
    }
}

/// Chart display for voltage sensors using the unified model
struct VoltageChart: View {
    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel

    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default

    var body: some View {
        BaseChartView(
            data: self.viewModel.filteredVoltageData(timeWindow: self.timeWindow),
            yAxisTitle: "Voltage",
            formatYValue: { String(format: "%.2f V", $0) },
            timeWindow: self.$timeWindow
        )
        .onAppear {
            self.viewModel.updateIfNeeded()
        }
    }
}

/// Chart display for current sensors using the unified model
struct CurrentChart: View {
    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel

    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default

    var body: some View {
        BaseChartView(
            data: self.viewModel.filteredCurrentData(timeWindow: self.timeWindow),
            yAxisTitle: "Current",
            formatYValue: { current in
                if abs(current) < 0.001 {
                    return String(format: "%.1f μA", current * 1_000_000)
                } else if abs(current) < 1.0 {
                    return String(format: "%.1f mA", current * 1_000)
                } else {
                    return String(format: "%.2f A", current)
                }
            },
            timeWindow: self.$timeWindow
        )
        .onAppear {
            self.viewModel.updateIfNeeded()
        }
    }
}
