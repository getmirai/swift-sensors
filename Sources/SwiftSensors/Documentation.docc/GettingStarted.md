# Getting Started with SwiftSensors

Learn how to integrate and use SwiftSensors in your apps.

## Overview

SwiftSensors is a Swift package that provides access to device sensor readings and system information. This guide will help you get started with basic usage patterns.

## Adding SwiftSensors to Your Project

Add SwiftSensors to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/getmirai/swift-sensors.git", from: "1.0.0")
]
```

Or add it to your Xcode project via File > Add Packages... and enter the repository URL.

## Basic Usage

Import the package and use the shared instance to access sensor reading data:

```swift
import SwiftSensors

func getSensorData() async {
    // Access the shared instance
    let sensors = SwiftSensors.shared
    
    // Get thermal sensor readings
    let thermalReadings = await sensors.getThermalSensorReadings()
    for reading in thermalReadings {
        print("\(reading.name): \(reading.temperature)°C")
    }
    
    // Get power sensor readings
    let powerReadings = await sensors.getPowerSensorReadings()
    for reading in powerReadings {
        print("\(reading.name): \(reading.value)")
    }
    
    // Get system information
    let cpuUsage = await sensors.getFormattedCPUUsage()
    let memoryUsage = await sensors.getFormattedMemoryUsage()
    let diskUsage = await sensors.getFormattedDiskUsage()
    let uptime = await sensors.getFormattedUptime()
    
    print("CPU Usage: \(cpuUsage)")
    print("Memory Usage: \(memoryUsage)")
    print("Disk Usage: \(diskUsage)")
    print("Uptime: \(uptime)")
}
```

## Using with SwiftUI

SwiftSensors works well with SwiftUI when combined with the async/await pattern:

```swift
import SwiftUI
import SwiftSensors

struct SensorReadingsView: View {
    @State private var thermalReadings: [ThermalSensorReading] = []
    @State private var cpuUsage: String = "Loading..."
    @State private var memoryUsage: String = "Loading..."
    
    var body: some View {
        List {
            Section("Thermal Readings") {
                ForEach(thermalReadings, id: \.id) { reading in
                    HStack {
                        Text(reading.name)
                        Spacer()
                        Text("\(String(format: "%.1f", reading.temperature))°C")
                    }
                }
            }
            
            Section("System Stats") {
                HStack {
                    Text("CPU Usage")
                    Spacer()
                    Text(cpuUsage)
                }
                HStack {
                    Text("Memory Usage")
                    Spacer()
                    Text(memoryUsage)
                }
            }
        }
        .task {
            await updateSensorData()
        }
    }
    
    func updateSensorData() async {
        let sensors = SwiftSensors.shared
        
        // Fetch all sensor data in parallel
        async let thermalReadingsTask = sensors.getThermalSensorReadings()
        async let cpuUsageTask = sensors.getFormattedCPUUsage()
        async let memoryUsageTask = sensors.getFormattedMemoryUsage()
        
        // Await all results
        thermalReadings = await thermalReadingsTask
        cpuUsage = await cpuUsageTask
        memoryUsage = await memoryUsageTask
    }
}
```

## Topics

### Essential Classes

- ``SwiftSensors/SwiftSensors``
- ``SwiftSensors/ThermalSensorReading``
- ``SwiftSensors/PowerSensorReading``

### System Monitoring

- ``SwiftSensors/MemoryStats``
- ``SwiftSensors/CPUStats``
- ``SwiftSensors/DiskStats``