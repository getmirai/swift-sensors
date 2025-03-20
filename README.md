# SwiftSensors

A Swift package for accessing real device sensor readings, including thermal readings, memory, CPU, and disk statistics.

## Features

- Access thermal sensor readings (temperature readings from internal sensors)
- Memory usage statistics (free, active, inactive, wired, compressed)
- CPU usage statistics (total, user, system, idle)
- Disk space information
- System information (thermal state, uptime, OS version)
- Battery information
- Formatted output for human-readable display

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/getmirai/swift-sensors.git", from: "0.0.1")
]
```

## Usage

```swift
import SwiftSensors

// Get an instance of the sensor manager
let sensors = SwiftSensors.shared

// Get thermal sensor readings
let thermalReadings = await sensors.getThermalSensorReadings()
for reading in thermalReadings {
    print("\(reading.name): \(SensorFormatter.shared.formatTemperature(reading.temperature))")
}

// Get memory statistics
let memoryStats = await sensors.getMemoryStats()
print("Memory Usage: \(await sensors.getFormattedMemoryUsage())")

// Get CPU statistics
let cpuStats = await sensors.getCPUStats()
print("CPU Usage: \(await sensors.getFormattedCPUUsage())")

// Get disk statistics
let diskStats = await sensors.getDiskStats()
print("Disk Usage: \(await sensors.getFormattedDiskUsage())")

// Get thermal state
let thermalState = await sensors.getThermalState()
print("Thermal State: \(thermalState.rawValue)")

// Get system uptime
print("System Uptime: \(await sensors.getFormattedUptime())")
```

## Requirements

- iOS 16.0+
- Swift 6.0+

## Note on Thermal Sensors

The thermal sensor functionality uses private APIs to access internal device temperature sensors. While this works well for development and diagnostic purposes, be aware that using private APIs may not be acceptable for App Store submissions.

## License

This project is available under the MIT license. See the LICENSE file for more info.
