import Foundation
#if canImport(UIKit)
import UIKit
#endif
import os

/// A structure representing memory statistics
public struct MemoryStats: Sendable {
    /// Total physical memory in bytes
    public let totalMemory: UInt64
    /// Free memory in bytes
    public let freeMemory: UInt64
    /// Active memory in bytes
    public let activeMemory: UInt64
    /// Inactive memory in bytes
    public let inactiveMemory: UInt64
    /// Wired memory in bytes
    public let wiredMemory: UInt64
    /// Compressed memory in bytes
    public let compressedMemory: UInt64
    /// Total used memory in bytes
    public let totalUsedMemory: UInt64
    /// Memory available to the application in bytes
    public let appAvailableMemory: UInt64
}

/// A structure representing CPU statistics
public struct CPUStats: Sendable {
    /// Total CPU usage as a percentage
    public let totalUsage: Double
    /// User CPU usage as a percentage
    public let userUsage: Double
    /// System CPU usage as a percentage
    public let systemUsage: Double
    /// Idle CPU usage as a percentage
    public let idleUsage: Double
    /// Nice CPU usage as a percentage
    public let niceUsage: Double
    /// Number of active processors
    public let activeProcessors: Int
    /// Total number of processors
    public let totalProcessors: Int
}

/// A structure representing disk space statistics
public struct DiskStats: Sendable {
    /// Total disk space in bytes
    public let totalSpace: UInt64
    /// Used disk space in bytes
    public let usedSpace: UInt64
    /// Free disk space in bytes
    public let freeSpace: UInt64
}

/// An enumeration for thermal state
public enum ThermalState: String, Sendable {
    case nominal = "Nominal"
    case fair = "Fair"
    case serious = "Serious"
    case critical = "Critical"
    case unknown = "Unknown"
}

/// An actor to retrieve system statistics
public actor SystemStatsManager {
    /// Shared instance for easy access
    public static let shared = SystemStatsManager()

    /// Last CPU info for delta calculations
    private var lastCPUTime: TimeInterval = Date().timeIntervalSince1970
    private var lastCPUUsage: Double = 0

    /// Private initializer for singleton pattern
    private init() {}

    /// Get current memory statistics (simulated for iOS)
    public func getMemoryStats() -> MemoryStats {
        // Get real device memory total
        let physicalMemory = ProcessInfo.processInfo.physicalMemory

        // Generate realistic simulated values
        let appUsage = Float.random(in: 0.05...0.15) // 5-15% for app
        let systemUsage = Float.random(in: 0.3...0.6) // 30-60% for system
        let totalUsage = appUsage + systemUsage

        let totalMemory = physicalMemory
        let totalUsedMemory = UInt64(Float(totalMemory) * totalUsage)
        let freeMemory = totalMemory - totalUsedMemory
        let activeMemory = UInt64(Float(totalMemory) * (appUsage + 0.15))
        let wiredMemory = UInt64(Float(totalMemory) * 0.2)
        let inactiveMemory = UInt64(Float(totalMemory) * 0.1)
        let compressedMemory = UInt64(Float(totalMemory) * 0.05)
        #if os(iOS)
        let appAvailableMemory = UInt64(os_proc_available_memory())
        #else
        let appAvailableMemory = freeMemory + inactiveMemory
        #endif

        return MemoryStats(
            totalMemory: totalMemory,
            freeMemory: freeMemory,
            activeMemory: activeMemory,
            inactiveMemory: inactiveMemory,
            wiredMemory: wiredMemory,
            compressedMemory: compressedMemory,
            totalUsedMemory: totalUsedMemory,
            appAvailableMemory: appAvailableMemory
        )
    }

    /// Get current CPU statistics (simulated for iOS)
    public func getCPUStats() -> CPUStats {
        // Generate simulated CPU usage that varies over time
        let currentTime = Date().timeIntervalSince1970
        let elapsed = currentTime - self.lastCPUTime

        // Create a somewhat realistic usage pattern
        var newUsage = self.lastCPUUsage
        if elapsed > 0.1 {
            // Add some random variation to the usage
            let change = Double.random(in: -10...10)
            newUsage += change

            // Ensure the value stays in a reasonable range
            newUsage = max(5, min(newUsage, 85))

            // Update the last values
            self.lastCPUTime = currentTime
            self.lastCPUUsage = newUsage
        }

        // Distribute the usage between user and system
        let totalUsage = newUsage
        let userRatio = Double.random(in: 0.6...0.8) // User processes use 60-80% of CPU
        let userUsage = totalUsage * userRatio
        let systemUsage = totalUsage * (1 - userRatio)
        let idleUsage = 100 - totalUsage
        let niceUsage = systemUsage * 0.1

        return CPUStats(
            totalUsage: totalUsage,
            userUsage: userUsage,
            systemUsage: systemUsage,
            idleUsage: idleUsage,
            niceUsage: niceUsage,
            activeProcessors: ProcessInfo.processInfo.activeProcessorCount,
            totalProcessors: ProcessInfo.processInfo.processorCount
        )
    }

    /// Get current disk statistics
    public func getDiskStats() -> DiskStats {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let freeSpace = attributes[.systemFreeSize] as? NSNumber
            let totalSpace = attributes[.systemSize] as? NSNumber

            if let freeSpace = freeSpace, let totalSpace = totalSpace {
                let freeSpaceBytes = UInt64(truncating: freeSpace)
                let totalSpaceBytes = UInt64(truncating: totalSpace)
                let usedSpaceBytes = totalSpaceBytes - freeSpaceBytes

                return DiskStats(
                    totalSpace: totalSpaceBytes,
                    usedSpace: usedSpaceBytes,
                    freeSpace: freeSpaceBytes
                )
            }
        } catch {
            // If there's an error, return zeros
        }

        return DiskStats(totalSpace: 0, usedSpace: 0, freeSpace: 0)
    }

    /// Get current thermal state
    public func getThermalState() -> ThermalState {
        let thermalStatus = ProcessInfo.processInfo.thermalState
        switch thermalStatus {
        case .nominal:
            return .nominal
        case .fair:
            return .fair
        case .serious:
            return .serious
        case .critical:
            return .critical
        default:
            return .unknown
        }
    }

    /// Get system uptime in seconds
    public func getSystemUptime() -> TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }

    /// Format uptime into a readable string
    public func getFormattedUptime() -> String {
        let uptime = self.getSystemUptime()
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute, .second]

        let uptimeDate = Date(timeIntervalSinceNow: -uptime)
        let formattedUptime = formatter.string(from: uptimeDate, to: Date()) ?? "Unknown"
        return formattedUptime
    }

    /// Get the OS version
    public func getOSVersion() -> String {
        ProcessInfo.processInfo.operatingSystemVersionString
    }

    /// Get the battery level (iOS only)
    @MainActor
    public func getBatteryLevel() -> Float {
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
        #else
        return 1.0 // Default to 100% for non-iOS platforms
        #endif
    }

    /// Get the device type (iOS only)
    @MainActor
    public func getDeviceType() -> String {
        #if canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .unspecified:
            return "Unspecified"
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .tv:
            return "Apple TV"
        case .carPlay:
            return "CarPlay"
        case .mac:
            return "Mac"
        default:
            return "Unknown"
        }
        #else
        return "Unknown"
        #endif
    }
}
