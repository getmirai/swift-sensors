import SwiftUI

/// Navigation section for charts

struct ChartNavigationSection: View {
    /// Action for temperature charts
    var onTemperatureChartsSelected: () -> Void
    
    /// Action for power charts
    var onPowerChartsSelected: () -> Void
    
    var body: some View {
        Section {
            Button {
                onTemperatureChartsSelected()
            } label: {
                Text("View Temperature Charts")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Button {
                onPowerChartsSelected()
            } label: {
                Text("View Power Charts")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
    }
}