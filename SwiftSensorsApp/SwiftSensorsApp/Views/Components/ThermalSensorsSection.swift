import SwiftUI
import SwiftSensors

/// Display section for thermal sensors
@available(iOS 16.0, *)
struct ThermalSensorsSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel
    
    /// Action to perform when a sensor is selected
    var onSensorSelected: (String) -> Void
    
    var body: some View {
        Section(header: Text("Thermal Sensors")) {
            ForEach(Array(zip(viewModel.thermalSensors.indices, viewModel.thermalSensors)), id: \.1.id) { index, sensor in
                Button {
                    onSensorSelected(sensor.name)
                } label: {
                    HStack {
                        Text(sensor.name)
                        Spacer()
                        Text(index < viewModel.formattedTemperatures.count ? viewModel.formattedTemperatures[index] : "\(sensor.temperature) °C")
                    }
                }
                .foregroundColor(.primary)
            }
            
            if viewModel.thermalSensors.isEmpty {
                Text("No thermal sensors found")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}