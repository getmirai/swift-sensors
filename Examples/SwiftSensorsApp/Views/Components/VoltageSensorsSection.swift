import SwiftSensors
import SwiftUI

/// Display section for voltage sensors

struct VoltageSensorsSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel

    var body: some View {
        Section(header: Text("Voltage Sensors")) {
            ForEach(
                Array(zip(self.viewModel.voltageSensorReadings.indices, self.viewModel.voltageSensorReadings)),
                id: \.1.id
            ) { index, sensor in
                InfoRow(
                    label: sensor.name,
                    value: index < self.viewModel.formattedVoltages.count ? self.viewModel.formattedVoltages[index] : "\(sensor.voltage) V"
                )
            }

            if self.viewModel.voltageSensorReadings.isEmpty {
                Text("No voltage sensors found")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}