import Foundation

/// Defines all possible navigation destinations in the app
enum NavigationDestination: Hashable {
    /// Detail view for a specific sensor
    case sensorDetail(sensorName: String)
    
    /// Temperature charts overview
    case sensorChart
    
    /// Power charts overview
    case powerChart
}