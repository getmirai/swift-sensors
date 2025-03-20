import SwiftSensors
import SwiftUI

/// Display section for memory information

struct MemoryInfoSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel

    var body: some View {
        Section(header: Text("Memory Information")) {
            if self.viewModel.memoryStats != nil, self.viewModel.formattedMemoryValues.count >= 5 {
                InfoRow(label: "Total", value: self.viewModel.formattedMemoryValues[0])
                InfoRow(label: "Free", value: self.viewModel.formattedMemoryValues[1])
                InfoRow(label: "Active", value: self.viewModel.formattedMemoryValues[2])
                InfoRow(label: "Wired", value: self.viewModel.formattedMemoryValues[3])
                InfoRow(label: "Used", value: self.viewModel.formattedMemoryValues[4])
            } else {
                Text("Loading memory information...")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}