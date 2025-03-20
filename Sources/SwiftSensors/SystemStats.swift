import Darwin
import Foundation
import os
import UIKit

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
    private var lastCPUInfo: host_cpu_load_info?

    /// Private initializer for singleton pattern
    private init() {}

    /// Get current memory statistics
    public func getMemoryStats() -> MemoryStats {
        let memInfo = self.getMemoryInfo()

        return MemoryStats(
            totalMemory: memInfo.physicalMemory,
            freeMemory: memInfo.free,
            activeMemory: memInfo.active,
            inactiveMemory: memInfo.inactive,
            wiredMemory: memInfo.wired,
            compressedMemory: memInfo.compressed,
            totalUsedMemory: memInfo.totalUsed,
            appAvailableMemory: UInt64(os_proc_available_memory())
        )
    }

    /// Get memory info using host_statistics64
    private func getMemoryInfo() -> (
        free: UInt64,
        active: UInt64,
        inactive: UInt64,
        wired: UInt64,
        compressed: UInt64,
        totalUsed: UInt64,
        physicalMemory: UInt64
    ) {
        var host_size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.stride)
        var host_info = vm_statistics64_data_t()
        let result = withUnsafeMutablePointer(to: &host_info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(host_size)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &host_size)
            }
        }

        if result == KERN_SUCCESS {
            // Get the page size in a concurrency-safe manner using getpagesize()
            let pageSize = UInt64(getpagesize())

            // Calculate the basic memory statistics
            let free = UInt64(host_info.free_count) * pageSize
            let active = UInt64(host_info.active_count) * pageSize
            let inactive = UInt64(host_info.inactive_count) * pageSize
            let wired = UInt64(host_info.wire_count) * pageSize
            let compressed = UInt64(host_info.compressor_page_count) * pageSize
            let totalUsed = active + inactive + wired + compressed

            // Get physical memory size
            let hostInfo = self.getHostBasicInfo()
            let physicalMemory = hostInfo.max_mem

            return (free, active, inactive, wired, compressed, totalUsed, physicalMemory)
        } else {
            // Fallback to ProcessInfo if Mach calls fail
            let physicalMemory = ProcessInfo.processInfo.physicalMemory
            return (0, 0, 0, 0, 0, physicalMemory, physicalMemory)
        }
    }

    /// Get host basic info
    private func getHostBasicInfo() -> host_basic_info {
        var size = mach_msg_type_number_t(MemoryLayout<host_basic_info>.size / MemoryLayout<integer_t>.size)
        let hostInfo = host_basic_info_t.allocate(capacity: 1)

        defer {
            hostInfo.deallocate()
        }

        var hostInfoData = host_basic_info()

        let result = withUnsafeMutablePointer(to: &hostInfoData) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_info(mach_host_self(), HOST_BASIC_INFO, $0, &size)
            }
        }

        if result == KERN_SUCCESS {
            return hostInfoData
        } else {
            // Return default struct with zeros on error
            return host_basic_info()
        }
    }

    /// Get current CPU statistics
    public func getCPUStats() -> CPUStats {
        guard let newInfo = hostCPULoadInfo()
        else {
            return CPUStats(
                totalUsage: 0,
                userUsage: 0,
                systemUsage: 0,
                idleUsage: 0,
                niceUsage: 0,
                activeProcessors: ProcessInfo.processInfo.activeProcessorCount,
                totalProcessors: ProcessInfo.processInfo.processorCount
            )
        }

        // Default values
        var cpuUsage: Double = 0
        var userCPUUsage: Double = 0
        var systemCPUUsage: Double = 0
        var idleCPUUsage: Double = 0
        var niceCPUUsage: Double = 0

        // Calculate CPU usage percentages if we have previous measurements
        if let lastInfo = lastCPUInfo {
            let userDiff = Double(newInfo.cpu_ticks.0 - lastInfo.cpu_ticks.0)
            let systemDiff = Double(newInfo.cpu_ticks.1 - lastInfo.cpu_ticks.1)
            let idleDiff = Double(newInfo.cpu_ticks.2 - lastInfo.cpu_ticks.2)
            let niceDiff = Double(newInfo.cpu_ticks.3 - lastInfo.cpu_ticks.3)

            let totalDiff = userDiff + systemDiff + idleDiff + niceDiff
            let nonIdleTicks = totalDiff - idleDiff

            if totalDiff > 0 {
                cpuUsage = (nonIdleTicks / totalDiff) * 100
                userCPUUsage = (userDiff / totalDiff) * 100
                systemCPUUsage = (systemDiff / totalDiff) * 100
                idleCPUUsage = (idleDiff / totalDiff) * 100
                niceCPUUsage = (niceDiff / totalDiff) * 100
            }
        }

        // Update last info for the next calculation
        self.lastCPUInfo = newInfo

        return CPUStats(
            totalUsage: cpuUsage,
            userUsage: userCPUUsage,
            systemUsage: systemCPUUsage,
            idleUsage: idleCPUUsage,
            niceUsage: niceCPUUsage,
            activeProcessors: ProcessInfo.processInfo.activeProcessorCount,
            totalProcessors: ProcessInfo.processInfo.processorCount
        )
    }

    /// Get CPU load info
    private func hostCPULoadInfo() -> host_cpu_load_info? {
        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        var cpuLoadInfo = host_cpu_load_info()

        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }

        if result != KERN_SUCCESS {
            return nil
        }

        return cpuLoadInfo
    }

    /// Get current disk statistics
    public func getDiskStats() -> DiskStats {
        let fileManager = FileManager.default
        guard let attributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
              let freeSpace = attributes[.systemFreeSize] as? NSNumber,
              let totalSpace = attributes[.systemSize] as? NSNumber
        else { return DiskStats(totalSpace: 0, usedSpace: 0, freeSpace: 0) }

        let freeSpaceBytes = UInt64(truncating: freeSpace)
        let totalSpaceBytes = UInt64(truncating: totalSpace)
        let usedSpaceBytes = totalSpaceBytes - freeSpaceBytes

        return DiskStats(
            totalSpace: totalSpaceBytes,
            usedSpace: usedSpaceBytes,
            freeSpace: freeSpaceBytes
        )
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

    /// Get the battery level
    @MainActor
    public func getBatteryLevel() -> Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }

    /// Get the device type
    @MainActor
    public func getDeviceType() -> String {
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
    }
}
