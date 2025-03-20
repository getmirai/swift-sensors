import Foundation

/// Defines all possible navigation destinations in the app
enum NavigationDestination: Hashable {
    /// Detail view for a specific sensor
    case sensorDetail(sensorName: String)
    
    /// Specific section detail+chart view
    case sectionDetail(section: SensorSection)
}

/// Represents different sensor sections in the app
enum SensorSection: String, Hashable, CaseIterable {
    case thermal = "Thermal Sensors"
    case voltage = "Voltage Sensors"
    case current = "Current Sensors"
    case memory = "Memory"
    case cpu = "CPU"
    case disk = "Disk"
    case system = "System"
}