import Foundation

/// Represents a single sensor reading for display in charts
struct SensorData: Identifiable, Equatable {
    /// Unique identifier
    let id = UUID()

    /// When the reading was taken
    let timestamp: Date

    /// Name of the sensor
    let sensorName: String

    /// Value of the reading
    let value: Double

    /// Category of the reading (optional)
    let category: String?

    init(timestamp: Date, sensorName: String, value: Double, category: String? = nil) {
        self.timestamp = timestamp
        self.sensorName = sensorName
        self.value = value
        self.category = category
    }

    // Implementation of Equatable
    static func == (lhs: SensorData, rhs: SensorData) -> Bool {
        lhs.id == rhs.id &&
            lhs.timestamp == rhs.timestamp &&
            lhs.sensorName == rhs.sensorName &&
            lhs.value == rhs.value &&
            lhs.category == rhs.category
    }
}

/// Different types of system metric categories
enum MetricType: String, CaseIterable {
    case memory = "Memory"
    case cpu = "CPU"
    case disk = "Disk"
}

/// Different memory metric types
enum MemoryMetricType: Int, CaseIterable {
    case total = 0
    case free = 1
    case active = 2
    case inactive = 3
    case wired = 4
    case compressed = 5
    case sum = 6
    case appAvailable = 7
    case appUnavailable = 8

    var name: String {
        switch self {
        case .total: return "Total Physical"
        case .free: return "Free"
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .wired: return "Wired"
        case .compressed: return "Compressed"
        case .sum: return "Sum"
        case .appAvailable: return "Available to App"
        case .appUnavailable: return "Unavailable Remainder"
        }
    }
}

/// Different CPU metric types
enum CPUMetricType: Int, CaseIterable {
    case total = 0
    case user = 1
    case system = 2

    var name: String {
        switch self {
        case .total: return "Total Usage"
        case .user: return "User Usage"
        case .system: return "System Usage"
        }
    }
}

/// Different disk metric types
enum DiskMetricType: Int, CaseIterable {
    case total = 0
    case used = 1
    case free = 2

    var name: String {
        switch self {
        case .total: return "Total Space"
        case .used: return "Used Space"
        case .free: return "Free Space"
        }
    }
}