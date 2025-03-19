import SwiftUI

/// UI for selecting sensors to display in charts
@available(iOS 16.0, *)
struct SensorSelector: View {
    /// Available sensors to select from
    let availableSensors: [String]
    
    /// Currently selected sensors
    @Binding var selectedSensors: Set<String>
    
    var body: some View {
        List {
            Section(header: Text("Select Sensors")) {
                ForEach(availableSensors, id: \.self) { sensor in
                    Button(action: {
                        if selectedSensors.contains(sensor) {
                            selectedSensors.remove(sensor)
                        } else {
                            selectedSensors.insert(sensor)
                        }
                    }) {
                        HStack {
                            Text(sensor)
                            Spacer()
                            if selectedSensors.contains(sensor) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        }
    }
}