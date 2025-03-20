import SwiftSensors
import SwiftUI

/// Display section for memory information

struct MemoryInfoSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel

    var body: some View {
        Section(header: Text("Memory Information")) {
            if self.viewModel.memoryStats != nil, self.viewModel.formattedMemoryValues.count >= 9 {
                // Display in exact specified order
                InfoRow(label: "Free", value: self.viewModel.formattedMemoryValues[1])
                InfoRow(label: "Active", value: self.viewModel.formattedMemoryValues[2])
                InfoRow(label: "Inactive", value: self.viewModel.formattedMemoryValues[3])
                InfoRow(label: "Wired", value: self.viewModel.formattedMemoryValues[4])
                InfoRow(label: "Compressed", value: self.viewModel.formattedMemoryValues[5])
                InfoRow(label: "Sum", value: self.viewModel.formattedMemoryValues[6])
                InfoRow(label: "Total Physical", value: self.viewModel.formattedMemoryValues[0])
                InfoRow(label: "Available to App", value: self.viewModel.formattedMemoryValues[7])
                InfoRow(label: "Unavailable Remainder", value: self.viewModel.formattedMemoryValues[8])
            } else {
                Text("Loading memory information...")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}
