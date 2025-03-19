#ifndef PrivateAPI_h
#define PrivateAPI_h

#include <Foundation/Foundation.h>

typedef struct __IOHIDEventSystemClient* IOHIDEventSystemClientRef;
typedef struct __IOHIDEvent *IOHIDEventRef;
typedef double IOHIDFloat;

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

@interface HIDServiceClient: NSObject {
    struct {
        struct __IOHIDEventSystemClient *system;
        void *serviceID;
        struct __CFDictionary *cachedProperties;
        struct IOHIDServiceFastPathInterface **fastPathInterface;
        struct IOCFPlugInInterfaceStruct **plugInInterface;
        void *removalHandler;
        unsigned int primaryUsagePage;
        unsigned int primaryUsage;
        struct _IOHIDServiceClientUsagePair *usagePairs;
        unsigned int usagePairsCount;
    } _client;
}

- (id)description;
- (void)dealloc;
- (unsigned long long)_cfTypeID;

@end

IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client, CFDictionaryRef match);
CFArrayRef IOHIDEventSystemClientCopyServices(IOHIDEventSystemClientRef x);
CFStringRef IOHIDServiceClientCopyProperty(HIDServiceClient *service, CFStringRef property);
IOHIDEventRef IOHIDServiceClientCopyEvent(HIDServiceClient *event, int64_t , int32_t, int64_t);
IOHIDFloat IOHIDEventGetFloatValue(IOHIDEventRef event, int32_t field);

#endif /* PrivateAPI_h */
