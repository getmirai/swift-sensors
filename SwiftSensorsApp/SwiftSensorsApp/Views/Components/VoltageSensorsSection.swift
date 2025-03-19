import SwiftUI
import SwiftSensors

/// Display section for voltage sensors

struct VoltageSensorsSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel
    
    var body: some View {
        Section(header: Text("Voltage Sensors")) {
            ForEach(Array(zip(viewModel.voltageSensors.indices, viewModel.voltageSensors)), id: \.1.id) { index, sensor in
                InfoRow(
                    label: sensor.name,
                    value: index < viewModel.formattedVoltages.count ? viewModel.formattedVoltages[index] : "\(sensor.voltage) V"
                )
            }
            
            if viewModel.voltageSensors.isEmpty {
                Text("No voltage sensors found")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}