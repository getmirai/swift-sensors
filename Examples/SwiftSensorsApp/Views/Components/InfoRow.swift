import SwiftUI

/// Reusable information row with label and value

struct InfoRow: View {
    /// The label shown on the left
    let label: String

    /// The value shown on the right
    let value: String

    var body: some View {
        HStack {
            Text(self.label)
            Spacer()
            Text(self.value)
        }
    }
}