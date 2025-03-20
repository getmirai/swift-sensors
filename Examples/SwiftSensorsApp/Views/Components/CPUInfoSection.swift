import SwiftSensors
import SwiftUI

/// Display section for CPU information

struct CPUInfoSection: View {
    /// The sensor view model
    var viewModel: SensorsViewModel

    var body: some View {
        Section(header: Text("CPU Information")) {
            if let stats = viewModel.cpuStats, viewModel.formattedCPUValues.count >= 3 {
                InfoRow(label: "CPU Usage", value: self.viewModel.formattedCPUValues[0])
                InfoRow(label: "User", value: self.viewModel.formattedCPUValues[1])
                InfoRow(label: "System", value: self.viewModel.formattedCPUValues[2])
                InfoRow(label: "Active Processors", value: "\(stats.activeProcessors) / \(stats.totalProcessors)")
            } else {
                Text("Loading CPU information...")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}