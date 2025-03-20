import Charts
import SwiftSensors
import SwiftUI

/// Chart display for memory metrics using the unified model
struct MemoryChart: View {
    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel

    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default

    var body: some View {
        BaseChartView(
            data: self.viewModel.filteredMemoryData(timeWindow: self.timeWindow),
            yAxisTitle: "Memory",
            formatYValue: { self.formatBytes(UInt64($0)) },
            timeWindow: self.$timeWindow
        )
        .onAppear {
            self.viewModel.updateIfNeeded()
        }
    }

    /// Format bytes to human-readable string
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

/// Chart display for CPU metrics using the unified model
struct CPUChart: View {
    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel

    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default

    var body: some View {
        BaseChartView(
            data: self.viewModel.filteredCPUData(timeWindow: self.timeWindow),
            yAxisTitle: "CPU Usage",
            formatYValue: { "\(Int($0))%" },
            timeWindow: self.$timeWindow
        )
        .chartYScale(domain: 0...100) // CPU usage is 0-100%
        .onAppear {
            self.viewModel.updateIfNeeded()
        }
    }
}

/// Chart display for disk metrics using the unified model
struct DiskChart: View {
    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel

    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default

    var body: some View {
        BaseChartView(
            data: self.viewModel.filteredDiskData(timeWindow: self.timeWindow),
            yAxisTitle: "Disk Space",
            formatYValue: { self.formatBytes(UInt64($0)) },
            timeWindow: self.$timeWindow
        )
        .onAppear {
            self.viewModel.updateIfNeeded()
        }
    }

    /// Format bytes to human-readable string
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}