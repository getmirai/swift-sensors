import SwiftSensors
import SwiftUI

/// Display section for disk information

struct DiskInfoSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel

    var body: some View {
        Section(header: Text("Disk Information")) {
            if self.viewModel.diskStats != nil, self.viewModel.formattedDiskValues.count >= 3 {
                InfoRow(label: "Total", value: self.viewModel.formattedDiskValues[0])
                InfoRow(label: "Used", value: self.viewModel.formattedDiskValues[1])
                InfoRow(label: "Free", value: self.viewModel.formattedDiskValues[2])
            } else {
                Text("Loading disk information...")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}