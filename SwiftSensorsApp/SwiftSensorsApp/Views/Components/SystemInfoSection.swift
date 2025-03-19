import SwiftUI
import SwiftSensors

/// Display section for system information
@available(iOS 16.0, *)
struct SystemInfoSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel
    
    var body: some View {
        Section(header: Text("System")) {
            HStack {
                Text("Thermal State")
                Spacer()
                Text(viewModel.thermalState.rawValue)
                    .foregroundColor(thermalStateColor(viewModel.thermalState))
            }
            
            InfoRow(label: "Uptime", value: viewModel.uptimeText)
        }
    }
    
    /// Get color based on thermal state
    private func thermalStateColor(_ state: ThermalState) -> Color {
        switch state {
        case .nominal:
            return .green
        case .fair:
            return .yellow
        case .serious:
            return .orange
        case .critical:
            return .red
        case .unknown:
            return .gray
        }
    }
}