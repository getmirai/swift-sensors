import SwiftSensors
import SwiftUI

/// Display section for system information

struct SystemInfoSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel

    var body: some View {
        Section(header: Text("System")) {
            HStack {
                Text("Thermal State")
                Spacer()
                Text(self.viewModel.thermalState.rawValue)
                    .foregroundColor(self.thermalStateColor(self.viewModel.thermalState))
            }

            InfoRow(label: "Uptime", value: self.viewModel.uptimeText)
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