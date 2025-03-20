import SwiftSensors
import SwiftUI

/// Display section for thermal sensors

struct ThermalSensorsSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel

    /// Action to perform when a sensor is selected
    var onSensorSelected: (String) -> Void

    var body: some View {
        Section(header: Text("Thermal Sensors")) {
            ForEach(Array(zip(self.viewModel.thermalSensors.indices, self.viewModel.thermalSensors)), id: \.1.id) { index, sensor in
                Button {
                    self.onSensorSelected(sensor.name)
                } label: {
                    HStack {
                        Text(sensor.name)
                        Spacer()
                        Text(index < self.viewModel.formattedTemperatures.count ? self.viewModel.formattedTemperatures[index] : "\(sensor.temperature) °C")
                    }
                }
                .foregroundColor(.primary)
            }

            if self.viewModel.thermalSensors.isEmpty {
                Text("No thermal sensors found")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}