import SwiftUI

/// UI for selecting sensors to display in charts

struct SensorSelector: View {
    /// Available sensors to select from
    let availableSensors: [String]

    /// Currently selected sensors
    @Binding var selectedSensors: Set<String>

    var body: some View {
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
}