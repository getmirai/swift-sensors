import SwiftUI


@main
struct SwiftSensorsAppApp: App {
    // Create the view model at the app level so it's shared
    @State private var sensorsViewModel = SensorsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.sensorsViewModel, sensorsViewModel) // Provide view model to environment
        }
    }
}