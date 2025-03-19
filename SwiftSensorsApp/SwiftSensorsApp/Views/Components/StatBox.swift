import SwiftUI

/// A reusable component for displaying a statistic with a title and value

struct StatBox: View {
    /// The title shown above the value
    let title: String
    
    /// The formatted value to display
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(minWidth: 80)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}