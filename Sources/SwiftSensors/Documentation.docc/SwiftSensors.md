# ``SwiftSensors``

A Swift library for accessing device sensor readings and system information in iOS.

## Overview

SwiftSensors provides a Swift interface to access various hardware sensor readings and system information on iOS devices. This library makes it easy to monitor thermal readings, power readings, memory, CPU, disk usage, and other system metrics.

## Features

- Access thermal sensor readings for temperature data
- Monitor power sensor readings (voltage and current)
- Track system resources (CPU, memory, disk)
- Get device information (OS version, device type, uptime)
- Battery level monitoring
- Formatted output for human-readable metrics

## Getting Started

To start using SwiftSensors, import the package and use the shared instance:

```swift
import SwiftSensors

// Access the shared instance
let sensors = SwiftSensors.shared

// Get thermal sensor readings
let thermalReadings = await sensors.getThermalSensorReadings()
for reading in thermalReadings {
    print("\(reading.name): \(reading.temperature)°C")
}

// Get system information
let cpuUsage = await sensors.getFormattedCPUUsage()
let memoryUsage = await sensors.getFormattedMemoryUsage()
let diskUsage = await sensors.getFormattedDiskUsage()
let uptime = await sensors.getFormattedUptime()
```

## Topics

### Essentials

- ``SwiftSensors/SwiftSensors``
- ``SwiftSensors/ThermalSensorReading``
- ``SwiftSensors/PowerSensorReading``

### Sensor Managers

- ``SwiftSensors/ThermalSensorManager``
- ``SwiftSensors/PowerSensorManager``
- ``SwiftSensors/SystemStatsManager``

### System Stats

- ``SwiftSensors/MemoryStats``
- ``SwiftSensors/CPUStats``
- ``SwiftSensors/DiskStats``