import SwiftUI
import Charts
import SwiftSensors

/// Chart view showing multiple sensors over time - This is a legacy view kept for backward compatibility
struct SensorChartView: View {
    @Environment(\.sensorsViewModel) private var viewModel
    
    var body: some View {
        VStack {
            // Use a compatibility wrapper for the MultiSensorChart
            if !viewModel.selectedThermalSensors.isEmpty {
                MultiSensorChart()
            } else {
                Text("Select sensors on the Thermal Sensors screen to view chart data")
                    .foregroundColor(.gray)
                    .padding()
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("Temperature Chart")
    }
}