import SwiftUI

/// Display for temperature statistics

struct TemperatureStats: View {
    /// Minimum temperature
    let minTemperature: Double
    
    /// Average temperature
    let avgTemperature: Double
    
    /// Maximum temperature
    let maxTemperature: Double
    
    var body: some View {
        HStack(spacing: 20) {
            StatBox(title: "Min", value: String(format: "%.1f°C", minTemperature))
            StatBox(title: "Avg", value: String(format: "%.1f°C", avgTemperature))
            StatBox(title: "Max", value: String(format: "%.1f°C", maxTemperature))
        }
        .padding()
    }
}