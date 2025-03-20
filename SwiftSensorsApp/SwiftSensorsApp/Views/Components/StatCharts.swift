import SwiftUI
import Charts
import SwiftSensors

/// Chart display for memory metrics using the unified model
struct MemoryChart: View {
    /// The view model with sensor data
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    var body: some View {
        BaseChartView(
            data: viewModel.filteredMemoryData(timeWindow: timeWindow),
            yAxisTitle: "Memory",
            formatYValue: { formatBytes(UInt64($0)) },
            timeWindow: $timeWindow
        )
        .onAppear {
            viewModel.updateIfNeeded()
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
    /// The view model with sensor data
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    var body: some View {
        BaseChartView(
            data: viewModel.filteredCPUData(timeWindow: timeWindow),
            yAxisTitle: "CPU Usage",
            formatYValue: { "\(Int($0))%" },
            timeWindow: $timeWindow
        )
        .chartYScale(domain: 0...100) // CPU usage is 0-100%
        .onAppear {
            viewModel.updateIfNeeded()
        }
    }
}

/// Chart display for disk metrics using the unified model
struct DiskChart: View {
    /// The view model with sensor data
    @State private var viewModel = SensorsViewModel.shared
    
    /// Time window to display
    @State private var timeWindow: TimeInterval = 60 // 60 seconds by default
    
    var body: some View {
        BaseChartView(
            data: viewModel.filteredDiskData(timeWindow: timeWindow),
            yAxisTitle: "Disk Space",
            formatYValue: { formatBytes(UInt64($0)) },
            timeWindow: $timeWindow
        )
        .onAppear {
            viewModel.updateIfNeeded()
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