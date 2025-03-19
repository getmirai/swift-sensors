import SwiftUI

/// Reusable information row with label and value
@available(iOS 16.0, *)
struct InfoRow: View {
    /// The label shown on the left
    let label: String
    
    /// The value shown on the right
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}