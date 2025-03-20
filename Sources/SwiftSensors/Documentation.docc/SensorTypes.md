# Sensor Reading Types

SwiftSensors provides several sensor reading types for monitoring device metrics.

## Overview

SwiftSensors categorizes sensor readings into different types to make them easy to access and use. The main categories are:

- Thermal sensor readings: Measure temperature at various points in the device
- Power sensor readings: Track voltage and current for different components
- System metrics: Monitor CPU, memory, disk, and other system parameters

## Thermal Sensor Readings

Thermal sensor readings measure temperature at various points in the device. They are useful for monitoring device health and detecting potential overheating issues.

```swift
// Get all thermal sensor readings
let thermalReadings = await SwiftSensors.shared.getThermalSensorReadings()

// Display temperature readings
for reading in thermalReadings {
    print("\(reading.name): \(reading.temperature)°C")
}
```

## Power Sensor Readings

Power sensor readings track voltage and current for different components. They are divided into voltage readings and current readings.

```swift
// Get all power sensor readings
let powerReadings = await SwiftSensors.shared.getPowerSensorReadings()

// Get only voltage sensor readings
let voltageReadings = await SwiftSensors.shared.getVoltageSensorReadings()

// Get only current sensor readings
let currentReadings = await SwiftSensors.shared.getCurrentSensorReadings()
```

## System Stats

System stats provide information about system resources such as CPU, memory, and disk usage.

```swift
// Get CPU stats
let cpuStats = await SwiftSensors.shared.getCPUStats()
let cpuUsage = await SwiftSensors.shared.getFormattedCPUUsage()

// Get memory stats
let memoryStats = await SwiftSensors.shared.getMemoryStats()
let memoryUsage = await SwiftSensors.shared.getFormattedMemoryUsage()

// Get disk stats
let diskStats = await SwiftSensors.shared.getDiskStats()
let diskUsage = await SwiftSensors.shared.getFormattedDiskUsage()
```

## Topics

### Thermal Sensor Readings

- ``SwiftSensors/ThermalSensorReading``
- ``SwiftSensors/ThermalSensorManager``

### Power Sensor Readings

- ``SwiftSensors/PowerSensorReading``
- ``SwiftSensors/VoltageSensorReading``
- ``SwiftSensors/CurrentSensorReading``
- ``SwiftSensors/PowerSensorManager``

### System Stats

- ``SwiftSensors/MemoryStats``
- ``SwiftSensors/CPUStats``
- ``SwiftSensors/DiskStats``
- ``SwiftSensors/SystemStatsManager``