import SwiftUI
import SwiftSensors

/// Display section for memory information
@available(iOS 16.0, *)
struct MemoryInfoSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel
    
    var body: some View {
        Section(header: Text("Memory Information")) {
            if viewModel.memoryStats != nil, viewModel.formattedMemoryValues.count >= 5 {
                InfoRow(label: "Total", value: viewModel.formattedMemoryValues[0])
                InfoRow(label: "Free", value: viewModel.formattedMemoryValues[1])
                InfoRow(label: "Active", value: viewModel.formattedMemoryValues[2])
                InfoRow(label: "Wired", value: viewModel.formattedMemoryValues[3])
                InfoRow(label: "Used", value: viewModel.formattedMemoryValues[4])
            } else {
                Text("Loading memory information...")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}