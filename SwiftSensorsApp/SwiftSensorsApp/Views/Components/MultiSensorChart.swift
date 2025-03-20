import SwiftUI
import Charts
import SwiftSensors

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
            if !data.isEmpty {
                Chart(data) { reading in
                    LineMark(
                        x: .value("Time", reading.timestamp),
                        y: .value(yAxisTitle, reading.value)
                    )
                    .foregroundStyle(by: .value("Sensor", reading.sensorName))
                    .interpolationMethod(.catmullRom) // Smooth curves
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text(formatYValue(val))
                            }
                        }
                    }
                }
            } else {
                Text("Collecting data...")
            }
            
            TimeWindowPicker(timeWindow: $timeWindow)
        }
    }
}

/// Chart display for thermal sensors using the unified model
struct MultiSensorChart: View {
    /// The view model with sensor data
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    var body: some View {
        BaseChartView(
            data: viewModel.filteredThermalData(timeWindow: timeWindow),
            yAxisTitle: "Temperature",
            formatYValue: { "\(Int($0))°C" },
            timeWindow: $timeWindow
        )
        .onAppear {
            viewModel.updateIfNeeded()
        }
    }
}

/// Chart display for voltage sensors using the unified model
struct VoltageChart: View {
    /// The view model with sensor data
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    var body: some View {
        BaseChartView(
            data: viewModel.filteredVoltageData(timeWindow: timeWindow),
            yAxisTitle: "Voltage",
            formatYValue: { String(format: "%.2f V", $0) },
            timeWindow: $timeWindow
        )
        .onAppear {
            viewModel.updateIfNeeded()
        }
    }
}

/// Chart display for current sensors using the unified model
struct CurrentChart: View {
    /// The view model with sensor data
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    var body: some View {
        BaseChartView(
            data: viewModel.filteredCurrentData(timeWindow: timeWindow),
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
            timeWindow: $timeWindow
        )
        .onAppear {
            viewModel.updateIfNeeded()
        }
    }
}