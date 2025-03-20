import Charts
import SwiftSensors
import SwiftUI


struct PowerSensorData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let sensorName: String
    let value: Double
    let type: PowerType

    enum PowerType: String {
        case voltage = "Voltage"
        case current = "Current"
    }
}


struct PowerSensorsView: View {
    @State private var powerData: [PowerSensorData] = []
    @State private var selectedSensors: Set<String> = []
    @State private var availableSensors: [String] = []
    @State private var timeWindow: TimeInterval = 60 // 60 seconds of data
    @State private var currentTab: PowerSensorData.PowerType = .voltage

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Picker("Sensor Type", selection: self.$currentTab) {
                Text("Voltage").tag(PowerSensorData.PowerType.voltage)
                Text("Current").tag(PowerSensorData.PowerType.current)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if !self.filteredData.isEmpty {
                Chart(self.filteredData) { data in
                    LineMark(
                        x: .value("Time", data.timestamp),
                        y: .value(data.type.rawValue, data.value)
                    )
                    .foregroundStyle(by: .value("Sensor", data.sensorName))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                if self.currentTab == .voltage {
                                    Text(String(format: "%.1f V", val))
                                } else {
                                    if abs(val) < 0.001 {
                                        Text(String(format: "%.1f μA", val * 1_000_000))
                                    } else if abs(val) < 1.0 {
                                        Text(String(format: "%.1f mA", val * 1_000))
                                    } else {
                                        Text(String(format: "%.1f A", val))
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 300)
                .padding()
            } else {
                Text("Collecting data...")
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
            }

            Picker("Time Window", selection: self.$timeWindow) {
                Text("1 minute").tag(TimeInterval(60))
                Text("5 minutes").tag(TimeInterval(5 * 60))
                Text("15 minutes").tag(TimeInterval(15 * 60))
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List {
                Section(header: Text("Select Sensors")) {
                    ForEach(self.availableSensors, id: \.self) { sensor in
                        Button(action: {
                            if self.selectedSensors.contains(sensor) {
                                self.selectedSensors.remove(sensor)
                            } else {
                                self.selectedSensors.insert(sensor)
                            }
                        }) {
                            HStack {
                                Text(sensor)
                                Spacer()
                                if self.selectedSensors.contains(sensor) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(self.currentTab == .voltage ? "Voltage Chart" : "Current Chart")
        .onAppear {
            // Get initial data
            self.updateSensorData()
        }
        .onReceive(self.timer) { _ in
            self.updateSensorData()
        }
    }

    private var filteredData: [PowerSensorData] {
        // Filter by selected sensors, time window, and current tab
        let cutoffDate = Date().addingTimeInterval(-self.timeWindow)
        return self.powerData.filter { data in
            self.selectedSensors.contains(data.sensorName) &&
                data.timestamp > cutoffDate &&
                data.type == self.currentTab
        }
    }

    private func updateSensorData() {
        // Use Task for async calls
        Task {
            let swiftSensors = SwiftSensors.shared
            let now = Date()

            // Create new data points
            if self.currentTab == .voltage || self.availableSensors.isEmpty {
                let voltageSensors = await swiftSensors.getVoltageSensorReadings()

                // Add voltage data
                let voltageData = voltageSensors.map { sensor in
                    PowerSensorData(
                        timestamp: now,
                        sensorName: sensor.name,
                        value: sensor.voltage,
                        type: .voltage
                    )
                }
                self.powerData.append(contentsOf: voltageData)

                // Update available sensors if needed
                let voltageSensorNames = Set(voltageSensors.map(\.name))
                if self.availableSensors.isEmpty || self.currentTab == .voltage {
                    if voltageSensorNames != Set(self.availableSensors.filter { sensor in
                        powerData.contains { $0.sensorName == sensor && $0.type == .voltage }
                    }) {
                        self.updateAvailableSensors(Array(voltageSensorNames))
                    }
                }
            }

            if self.currentTab == .current || self.availableSensors.isEmpty {
                let currentSensors = await swiftSensors.getCurrentSensorReadings()

                // Add current data
                let currentData = currentSensors.map { sensor in
                    PowerSensorData(
                        timestamp: now,
                        sensorName: sensor.name,
                        value: sensor.current,
                        type: .current
                    )
                }
                self.powerData.append(contentsOf: currentData)

                // Update available sensors if needed
                let currentSensorNames = Set(currentSensors.map(\.name))
                if self.availableSensors.isEmpty || self.currentTab == .current {
                    if currentSensorNames != Set(self.availableSensors.filter { sensor in
                        powerData.contains { $0.sensorName == sensor && $0.type == .current }
                    }) {
                        self.updateAvailableSensors(Array(currentSensorNames))
                    }
                }
            }

            // Keep data capped to manage memory
            let maxPoints = 3 * 60 * 60 // 3 hours with 1 reading per second
            if self.powerData.count > maxPoints {
                self.powerData = Array(self.powerData.suffix(maxPoints))
            }
        }
    }

    private func updateAvailableSensors(_ sensorNames: [String]) {
        self.availableSensors = sensorNames.sorted()

        // Auto-select sensors if none are selected yet
        if self.selectedSensors.isEmpty, !self.availableSensors.isEmpty {
            // Select up to 3 sensors by default
            let sensorsToSelect = min(3, availableSensors.count)
            self.selectedSensors = Set(self.availableSensors.prefix(sensorsToSelect))
        }
    }
}


struct PowerSensorsView_Previews: PreviewProvider {
    static var previews: some View {
        PowerSensorsView()
    }
}