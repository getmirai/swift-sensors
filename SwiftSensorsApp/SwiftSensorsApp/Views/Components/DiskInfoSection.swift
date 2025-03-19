import SwiftUI
import SwiftSensors

/// Display section for disk information
@available(iOS 16.0, *)
struct DiskInfoSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel
    
    var body: some View {
        Section(header: Text("Disk Information")) {
            if viewModel.diskStats != nil, viewModel.formattedDiskValues.count >= 3 {
                InfoRow(label: "Total", value: viewModel.formattedDiskValues[0])
                InfoRow(label: "Used", value: viewModel.formattedDiskValues[1])
                InfoRow(label: "Free", value: viewModel.formattedDiskValues[2])
            } else {
                Text("Loading disk information...")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}