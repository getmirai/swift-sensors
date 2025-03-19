import SwiftUI

/// Display for current temperature reading
@available(iOS 16.0, *)
struct TemperatureDisplay: View {
    /// The temperature value to display
    let temperature: Double
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text(String(format: "%.1f", temperature))
                .font(.system(size: 72, weight: .bold, design: .rounded))
            Text("°C")
                .font(.title)
                .padding(.bottom, 8)
        }
        .padding()
    }
}