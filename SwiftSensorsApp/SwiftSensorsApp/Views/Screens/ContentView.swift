import SwiftUI
import SwiftSensors

/// Main content view for the app
struct ContentView: View {
    /// Access the view model from the environment
    @Environment(\.sensorsViewModel) private var viewModel
    
    /// Timer for regular updates
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Navigation path for controlling navigation stack
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(SensorSection.allCases, id: \.self) { section in
                    Button {
                        navigationPath.append(NavigationDestination.sectionDetail(section: section))
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
                viewModel.updateIfNeeded()
            }
            .onReceive(timer) { _ in
                viewModel.updateIfNeeded()
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
            // Dynamic chart at the top based on selection state
            chartForSection
                .frame(height: 220)
                .padding()
            
            // List of sensors/details below the chart
            List {
                sectionContent
            }
        }
        .navigationTitle(section.rawValue)
        .onAppear {
            viewModel.updateIfNeeded()
        }
        .onReceive(timer) { _ in
            viewModel.updateIfNeeded()
        }
    }
    
    // Dynamic chart based on section type and selections
    @ViewBuilder
    private var chartForSection: some View {
        switch section {
        case .thermal:
            if viewModel.selectedThermalSensors.isEmpty {
                Text("Select sensors to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        viewModel.updateIfNeeded()
                    }
            } else {
                MultiSensorChart()
            }
            
        case .voltage:
            if viewModel.selectedVoltageSensors.isEmpty {
                Text("Select sensors to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        viewModel.updateIfNeeded()
                    }
            } else {
                VoltageChart()
            }
            
        case .current:
            if viewModel.selectedCurrentSensors.isEmpty {
                Text("Select sensors to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        viewModel.updateIfNeeded()
                    }
            } else {
                CurrentChart()
            }
            
        case .memory:
            if viewModel.selectedMemoryItems.isEmpty {
                Text("Select memory metrics to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        viewModel.updateIfNeeded()
                    }
            } else {
                MemoryChart()
            }
            
        case .cpu:
            if viewModel.selectedCPUItems.isEmpty {
                Text("Select CPU metrics to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        viewModel.updateIfNeeded()
                    }
            } else {
                CPUChart()
            }
            
        case .disk:
            if viewModel.selectedDiskItems.isEmpty {
                Text("Select disk metrics to view in chart")
                    .foregroundColor(.gray)
                    .italic()
                    .onAppear {
                        // Ensure data is collected even when nothing is selected
                        viewModel.updateIfNeeded()
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
    
    // Dynamic list content based on section type
    @ViewBuilder
    private var sectionContent: some View {
        switch section {
        case .thermal:
            ForEach(viewModel.thermalSensors, id: \.id) { sensor in
                let isSelected = viewModel.selectedThermalSensors.contains(sensor.name)
                Button {
                    if isSelected {
                        viewModel.selectedThermalSensors.remove(sensor.name)
                    } else {
                        viewModel.selectedThermalSensors.insert(sensor.name)
                    }
                } label: {
                    HStack {
                        Text(sensor.name)
                        Spacer()
                        Text(viewModel.thermalSensors.firstIndex(where: { $0.id == sensor.id }).flatMap { idx in
                            idx < viewModel.formattedTemperatures.count ? viewModel.formattedTemperatures[idx] : nil
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
            ForEach(viewModel.voltageSensors, id: \.id) { sensor in
                let isSelected = viewModel.selectedVoltageSensors.contains(sensor.name)
                Button {
                    if isSelected {
                        viewModel.selectedVoltageSensors.remove(sensor.name)
                    } else {
                        viewModel.selectedVoltageSensors.insert(sensor.name)
                    }
                } label: {
                    HStack {
                        Text(sensor.name)
                        Spacer()
                        Text(viewModel.voltageSensors.firstIndex(where: { $0.id == sensor.id }).flatMap { idx in
                            idx < viewModel.formattedVoltages.count ? viewModel.formattedVoltages[idx] : nil
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
            ForEach(viewModel.currentSensors, id: \.id) { sensor in
                let isSelected = viewModel.selectedCurrentSensors.contains(sensor.name)
                Button {
                    if isSelected {
                        viewModel.selectedCurrentSensors.remove(sensor.name)
                    } else {
                        viewModel.selectedCurrentSensors.insert(sensor.name)
                    }
                } label: {
                    HStack {
                        Text(sensor.name)
                        Spacer()
                        Text(viewModel.currentSensors.firstIndex(where: { $0.id == sensor.id }).flatMap { idx in
                            idx < viewModel.formattedCurrents.count ? viewModel.formattedCurrents[idx] : nil
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
            if viewModel.memoryStats != nil {
                let labels = ["Total Memory", "Free Memory", "Active Memory", "Wired Memory", "Used Memory"]
                
                ForEach(0..<labels.count, id: \.self) { index in
                    let isSelected = viewModel.selectedMemoryItems.contains(index)
                    Button {
                        if isSelected {
                            viewModel.selectedMemoryItems.remove(index)
                        } else {
                            viewModel.selectedMemoryItems.insert(index)
                        }
                    } label: {
                        HStack {
                            Text(labels[index])
                            Spacer()
                            if index < viewModel.formattedMemoryValues.count {
                                Text(viewModel.formattedMemoryValues[index])
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
            if viewModel.cpuStats != nil {
                let labels = ["Total Usage", "User Usage", "System Usage"]
                
                ForEach(0..<labels.count, id: \.self) { index in
                    let isSelected = viewModel.selectedCPUItems.contains(index)
                    Button {
                        if isSelected {
                            viewModel.selectedCPUItems.remove(index)
                        } else {
                            viewModel.selectedCPUItems.insert(index)
                        }
                    } label: {
                        HStack {
                            Text(labels[index])
                            Spacer()
                            if index < viewModel.formattedCPUValues.count {
                                Text(viewModel.formattedCPUValues[index])
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
            if viewModel.diskStats != nil {
                let labels = ["Total Space", "Used Space", "Free Space"]
                
                ForEach(0..<labels.count, id: \.self) { index in
                    let isSelected = viewModel.selectedDiskItems.contains(index)
                    Button {
                        if isSelected {
                            viewModel.selectedDiskItems.remove(index)
                        } else {
                            viewModel.selectedDiskItems.insert(index)
                        }
                    } label: {
                        HStack {
                            Text(labels[index])
                            Spacer()
                            if index < viewModel.formattedDiskValues.count {
                                Text(viewModel.formattedDiskValues[index])
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
                ("Uptime", viewModel.uptimeText),
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