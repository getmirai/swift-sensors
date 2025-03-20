import SwiftUI

@main
struct SwiftSensorsAppApp: App {
    @State private var sensorsViewModel = SensorsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.sensorsViewModel, self.sensorsViewModel)
        }
    }
}
