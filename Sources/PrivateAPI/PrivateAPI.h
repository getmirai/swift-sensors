#ifndef PrivateAPI_h
#define PrivateAPI_h

#include <Foundation/Foundation.h>

typedef struct __IOHIDEventSystemClient* IOHIDEventSystemClientRef;
typedef struct __IOHIDEvent *IOHIDEventRef;
typedef double IOHIDFloat;
typedef struct __IOHIDServiceClient *IOHIDServiceClient;
typedef IOHIDServiceClient IOHIDServiceClientRef;

// IOHIDEventTypes
#define kIOHIDEventTypeTemperature 15
#define kIOHIDEventTypePower 25
#define IOHIDEventFieldBase(type) (type << 16)

// Apple HID Usage Tables
#define kHIDPage_AppleVendor 0xff00
#define kHIDPage_AppleVendorPowerSensor 0xff08
#define kHIDUsage_AppleVendor_TemperatureSensor 0x0005
#define kHIDUsage_AppleVendorPowerSensor_Current 0x0002
#define kHIDUsage_AppleVendorPowerSensor_Voltage 0x0003

// Function declarations
IOHIDEventSystemClientRef _Nullable IOHIDEventSystemClientCreate(CFAllocatorRef _Nullable allocator);
int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef _Nonnull client, CFDictionaryRef _Nullable match);
CFArrayRef _Nullable IOHIDEventSystemClientCopyServices(IOHIDEventSystemClientRef _Nonnull client);
CFTypeRef _Nullable IOHIDServiceClientCopyProperty(IOHIDServiceClientRef _Nonnull service, CFStringRef _Nonnull key);
IOHIDEventRef _Nullable IOHIDServiceClientCopyEvent(IOHIDServiceClientRef _Nonnull service, int64_t type, int32_t options, int64_t timestamp);
IOHIDFloat IOHIDEventGetFloatValue(IOHIDEventRef _Nonnull event, int32_t field);

// CFArray functions needed for our implementation
CFIndex CFArrayGetCount(CFArrayRef _Nonnull theArray);
const void * _Nullable CFArrayGetValueAtIndex(CFArrayRef _Nonnull theArray, CFIndex idx);

#endif /* PrivateAPI_h */
