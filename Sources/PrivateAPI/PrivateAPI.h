#ifndef PrivateAPI_h
#define PrivateAPI_h

#include <Foundation/Foundation.h>

typedef struct __IOHIDEventSystemClient* IOHIDEventSystemClientRef;
typedef struct __IOHIDServiceClient *IOHIDServiceClientRef;
typedef struct __IOHIDEvent *IOHIDEventRef;
typedef double IOHIDFloat;

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
