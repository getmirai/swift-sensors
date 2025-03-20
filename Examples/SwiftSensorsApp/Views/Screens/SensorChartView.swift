import Charts
import SwiftSensors
import SwiftUI

/// Chart view showing multiple sensors over time - This is a legacy view kept for backward compatibility
struct SensorChartView: View {
    @Environment(\.sensorsViewModel) private var viewModel

    var body: some View {
        VStack {
            // Use a compatibility wrapper for the MultiSensorChart
            if !self.viewModel.selectedThermalReadings.isEmpty {
                MultiSensorChart()
            } else {
                Text("Select readings on the Thermal Readings screen to view chart data")
                    .foregroundColor(.gray)
                    .padding()
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("Temperature Chart")
    }
}