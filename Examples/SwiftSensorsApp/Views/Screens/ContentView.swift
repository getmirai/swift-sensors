import SwiftSensors
import SwiftUI

/// Main content view for the app
struct ContentView: View {
    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel

    /// Timer for regular updates
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// Navigation path for controlling navigation stack
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: self.$navigationPath) {
            List {
                ForEach(SensorSection.allCases, id: \.self) { section in
                    Button {
                        self.navigationPath.append(NavigationDestination.sectionDetail(section: section))
                    } label: {
                        HStack {
                            Text(section.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("SwiftSensors")
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .sensorDetail(let sensorName):
                    SensorDetailView(sensorName: sensorName)
                case .sectionDetail(let section):
                    SectionDetailView(section: section)
                }
            }
            .onAppear {
                self.viewModel.updateIfNeeded()
            }
            .onReceive(self.timer) { _ in
                self.viewModel.updateIfNeeded()
            }
        }
    }
}

/// A view that displays the details of a particular sensor section
struct SectionDetailView: View {
    let section: SensorSection
    @Environment(\.sensorsViewModel) private var viewModel

    /// Timer for regular updates
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            self.chartForSection
                .frame(height: 220)
                .padding()
            List {
                self.sectionContent
            }
        }
        .navigationTitle(self.section.rawValue)
        .onAppear {
            self.viewModel.updateIfNeeded()
        }
        .onReceive(self.timer) { _ in
            self.viewModel.updateIfNeeded()
        }
    }

    @ViewBuilder
    private var chartForSection: some View {
        switch self.section {
        case .thermal:
            if self.viewModel.selectedThermalSensors.isEmpty {
                Text("Select sensors to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        self.viewModel.updateIfNeeded()
                    }
            } else {
                MultiSensorChart()
            }

        case .voltage:
            if self.viewModel.selectedVoltageSensors.isEmpty {
                Text("Select sensors to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        self.viewModel.updateIfNeeded()
                    }
            } else {
                VoltageChart()
            }

        case .current:
            if self.viewModel.selectedCurrentSensors.isEmpty {
                Text("Select sensors to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        self.viewModel.updateIfNeeded()
                    }
            } else {
                CurrentChart()
            }

        case .memory:
            if self.viewModel.selectedMemoryItems.isEmpty {
                Text("Select memory metrics to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        self.viewModel.updateIfNeeded()
                    }
            } else {
                MemoryChart()
            }

        case .cpu:
            if self.viewModel.selectedCPUItems.isEmpty {
                Text("Select CPU metrics to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        self.viewModel.updateIfNeeded()
                    }
            } else {
                CPUChart()
            }

        case .disk:
            if self.viewModel.selectedDiskItems.isEmpty {
                Text("Select disk metrics to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        self.viewModel.updateIfNeeded()
                    }
            } else {
                DiskChart()
            }

        case .system:
            // System section doesn't have a chart
            Text("System Information")
                .font(.headline)
        }
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch self.section {
        case .thermal:
            ForEach(self.viewModel.thermalSensors, id: \.id) { sensor in
                let isSelected = self.viewModel.selectedThermalSensors.contains(sensor.name)
                Button {
                    if isSelected {
                        self.viewModel.selectedThermalSensors.remove(sensor.name)
                    } else {
                        self.viewModel.selectedThermalSensors.insert(sensor.name)
                    }
                } label: {
                    HStack {
                        Text(sensor.name)
                        Spacer()
                        Text(self.viewModel.thermalSensors.firstIndex(where: { $0.id == sensor.id }).flatMap { idx in
                            idx < self.viewModel.formattedTemperatures.count ? self.viewModel.formattedTemperatures[idx] : nil
                        } ?? "\(sensor.temperature) °C")

                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }

        case .voltage:
            ForEach(self.viewModel.voltageSensors, id: \.id) { sensor in
                let isSelected = self.viewModel.selectedVoltageSensors.contains(sensor.name)
                Button {
                    if isSelected {
                        self.viewModel.selectedVoltageSensors.remove(sensor.name)
                    } else {
                        self.viewModel.selectedVoltageSensors.insert(sensor.name)
                    }
                } label: {
                    HStack {
                        Text(sensor.name)
                        Spacer()
                        Text(self.viewModel.voltageSensors.firstIndex(where: { $0.id == sensor.id }).flatMap { idx in
                            idx < self.viewModel.formattedVoltages.count ? self.viewModel.formattedVoltages[idx] : nil
                        } ?? "\(sensor.voltage) V")

                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }

        case .current:
            ForEach(self.viewModel.currentSensors, id: \.id) { sensor in
                let isSelected = self.viewModel.selectedCurrentSensors.contains(sensor.name)
                Button {
                    if isSelected {
                        self.viewModel.selectedCurrentSensors.remove(sensor.name)
                    } else {
                        self.viewModel.selectedCurrentSensors.insert(sensor.name)
                    }
                } label: {
                    HStack {
                        Text(sensor.name)
                        Spacer()
                        Text(self.viewModel.currentSensors.firstIndex(where: { $0.id == sensor.id }).flatMap { idx in
                            idx < self.viewModel.formattedCurrents.count ? self.viewModel.formattedCurrents[idx] : nil
                        } ?? "\(sensor.current) A")

                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }

        case .memory:
            if self.viewModel.memoryStats != nil {
                let labels = ["Total Physical", "Free", "Active", "Inactive", "Wired", "Compressed", "Sum", "Available to App", "Unavailable Remainder"]

                ForEach(0..<labels.count, id: \.self) { index in
                    let isSelected = self.viewModel.selectedMemoryItems.contains(index)
                    Button {
                        if isSelected {
                            self.viewModel.selectedMemoryItems.remove(index)
                        } else {
                            self.viewModel.selectedMemoryItems.insert(index)
                        }
                    } label: {
                        HStack {
                            Text(labels[index])
                            Spacer()
                            if index < self.viewModel.formattedMemoryValues.count {
                                Text(self.viewModel.formattedMemoryValues[index])
                            }

                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            } else {
                Text("No memory stats available")
                    .foregroundColor(.gray)
                    .italic()
            }

        case .cpu:
            if self.viewModel.cpuStats != nil {
                let labels = ["Total Usage", "User Usage", "System Usage"]

                ForEach(0..<labels.count, id: \.self) { index in
                    let isSelected = self.viewModel.selectedCPUItems.contains(index)
                    Button {
                        if isSelected {
                            self.viewModel.selectedCPUItems.remove(index)
                        } else {
                            self.viewModel.selectedCPUItems.insert(index)
                        }
                    } label: {
                        HStack {
                            Text(labels[index])
                            Spacer()
                            if index < self.viewModel.formattedCPUValues.count {
                                Text(self.viewModel.formattedCPUValues[index])
                            }

                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            } else {
                Text("No CPU stats available")
                    .foregroundColor(.gray)
                    .italic()
            }

        case .disk:
            if self.viewModel.diskStats != nil {
                let labels = ["Total Space", "Used Space", "Free Space"]

                ForEach(0..<labels.count, id: \.self) { index in
                    let isSelected = self.viewModel.selectedDiskItems.contains(index)
                    Button {
                        if isSelected {
                            self.viewModel.selectedDiskItems.remove(index)
                        } else {
                            self.viewModel.selectedDiskItems.insert(index)
                        }
                    } label: {
                        HStack {
                            Text(labels[index])
                            Spacer()
                            if index < self.viewModel.formattedDiskValues.count {
                                Text(self.viewModel.formattedDiskValues[index])
                            }

                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            } else {
                Text("No disk stats available")
                    .foregroundColor(.gray)
                    .italic()
            }

        case .system:
            // System items are not selectable, just display information
            let items = [
                ("Thermal State", viewModel.thermalState.rawValue),
                ("Uptime", self.viewModel.uptimeText),
                ("Device Type", ProcessInfo.processInfo.isiOSAppOnMac ? "Mac" : "iOS Device"),
                ("OS Version", ProcessInfo.processInfo.operatingSystemVersionString)
            ]

            ForEach(0..<items.count, id: \.self) { index in
                HStack {
                    Text(items[index].0)
                    Spacer()
                    Text(items[index].1)
                }
                .padding(.vertical, 4)
            }
        }
    }
}
