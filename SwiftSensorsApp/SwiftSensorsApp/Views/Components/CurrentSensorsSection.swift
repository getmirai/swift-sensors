import SwiftUI
import SwiftSensors

/// Display section for current sensors
@available(iOS 16.0, *)
struct CurrentSensorsSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel
    
    var body: some View {
        Section(header: Text("Current Sensors")) {
            ForEach(Array(zip(viewModel.currentSensors.indices, viewModel.currentSensors)), id: \.1.id) { index, sensor in
                InfoRow(
                    label: sensor.name,
                    value: index < viewModel.formattedCurrents.count ? viewModel.formattedCurrents[index] : "\(sensor.current) A"
                )
            }
            
            if viewModel.currentSensors.isEmpty {
                Text("No current sensors found")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}