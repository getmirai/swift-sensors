import SwiftUI
import SwiftSensors

/// Main content view for the app
@available(iOS 16.0, *)
struct ContentView: View {
    /// The shared view model
    private var viewModel = SensorsViewModel.shared
    
    /// Timer for regular updates
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Navigation path for controlling navigation stack
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                // Thermal sensors
                ThermalSensorsSection(viewModel: viewModel) { sensorName in
                    navigationPath.append(NavigationDestination.sensorDetail(sensorName: sensorName))
                }
                
                // Memory information
                MemoryInfoSection(viewModel: viewModel)
                
                // CPU information
                CPUInfoSection(viewModel: viewModel)
                
                // Disk information
                DiskInfoSection(viewModel: viewModel)
                
                // System information
                SystemInfoSection(viewModel: viewModel)
                
                // Voltage sensors
                VoltageSensorsSection(viewModel: viewModel)
                
                // Current sensors
                CurrentSensorsSection(viewModel: viewModel)
                
                // Chart navigation
                ChartNavigationSection(
                    onTemperatureChartsSelected: {
                        navigationPath.append(NavigationDestination.sensorChart)
                    },
                    onPowerChartsSelected: {
                        navigationPath.append(NavigationDestination.powerChart)
                    }
                )
            }
            .navigationTitle("SwiftSensors")
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .sensorDetail(let sensorName):
                    SensorDetailView(sensorName: sensorName)
                case .sensorChart:
                    SensorChartView()
                case .powerChart:
                    Text("Power Charts Coming Soon")
                }
            }
            .onAppear {
                viewModel.updateIfNeeded()
            }
            .onReceive(timer) { _ in
                viewModel.updateIfNeeded()
            }
        }
    }
}