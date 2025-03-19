#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Set up variables
TEMP_DIR="$(mktemp -d)"
FRAMEWORKS_DIR="$(pwd)/Frameworks"
mkdir -p "$FRAMEWORKS_DIR"
OUTPUT_DIR="$FRAMEWORKS_DIR/IOKit.xcframework"

# Make sure output directory doesn't exist (remove it if it does)
rm -rf "$OUTPUT_DIR"

# Define iOS SDK paths
IOS_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
IOS_IOKIT_PATH="${IOS_SDK_PATH}/System/Library/Frameworks/IOKit.framework"
IOS_IOKIT_TBD="${IOS_IOKIT_PATH}/Versions/A/IOKit.tbd"
IOS_FRAMEWORK_DIR="${TEMP_DIR}/iPhoneOS/IOKit.framework"

echo "Creating minimal IOKit framework for iOS..."

# Check if iOS SDK exists
if [ ! -d "$IOS_SDK_PATH" ]; then
  echo "Error: iOS SDK not found at $IOS_SDK_PATH"
  exit 1
fi

# Check if IOKit framework exists in the SDK
if [ ! -d "$IOS_IOKIT_PATH" ]; then
  echo "Error: IOKit framework not found for iOS at $IOS_IOKIT_PATH"
  exit 1
fi

# Create minimal framework structure
mkdir -p "$IOS_FRAMEWORK_DIR"

# Copy the TBD file or create it if not found
if [ -f "$IOS_IOKIT_TBD" ]; then
  echo "Copying IOKit.tbd from SDK"
  cp "$IOS_IOKIT_TBD" "$IOS_FRAMEWORK_DIR/IOKit.tbd"
else
  echo "Creating IOKit.tbd file manually"
  cat > "$IOS_FRAMEWORK_DIR/IOKit.tbd" << EOF
--- !tapi-tbd
tbd-version:     4
targets:         [ arm64-ios ]
flags:           [ not_app_extension_safe ]
install-name:    '/System/Library/Frameworks/IOKit.framework/IOKit'
current-version: 275.0
exports:
  - targets:         [ arm64-ios ]
    symbols:         [ _IOKitVersionNumber, _IOKitVersionString, _IOHIDEventSystemClientCreate, 
                       _IOHIDEventSystemClientSetMatching, _IOHIDEventSystemClientCopyServices,
                       _IOHIDServiceClientCopyProperty, _IOHIDServiceClientCopyEvent,
                       _IOHIDEventGetFloatValue ]
...
EOF
fi

# Create Info.plist
cat > "$IOS_FRAMEWORK_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>IOKit</string>
    <key>CFBundleIdentifier</key>
    <string>com.apple.iokit</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>IOKit</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>12.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>iPhoneOS</string>
    </array>
    <key>UIDeviceFamily</key>
    <array><integer>1</integer><integer>2</integer></array>
</dict>
</plist>
EOF

# Create a dummy binary
echo "Creating binary stub for iOS"
COMPILE_DIR="$(mktemp -d)"
cat > "$COMPILE_DIR/IOKit.c" << EOF
#include <stdint.h>

// Export required symbols
const double IOKitVersionNumber = 1.0;
const char IOKitVersionString[] = "1.0";

// Dummy function to force export of symbols
void *_IOKitRetainSymbols(void) {
    return (void*)&IOKitVersionNumber;
}
EOF

# Compile the dummy binary for iOS
(cd "$COMPILE_DIR" && \
 xcrun clang -arch arm64 \
 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
 -mios-version-min=12.0 -dynamiclib -o IOKit IOKit.c \
 -install_name "/System/Library/Frameworks/IOKit.framework/IOKit" \
 -compatibility_version 1.0 -current_version 1.0)

# Copy the binary to the framework
if [ -f "$COMPILE_DIR/IOKit" ]; then
  cp "$COMPILE_DIR/IOKit" "$IOS_FRAMEWORK_DIR/IOKit"
  echo "Binary stub created successfully"
else
  echo "Error: Failed to compile binary stub"
  exit 1
fi

# Clean up compilation directory
rm -rf "$COMPILE_DIR"

# Create XCFramework with the iOS framework
echo "Creating XCFramework..."
xcodebuild -create-xcframework -framework "$IOS_FRAMEWORK_DIR" -output "$OUTPUT_DIR"

# Check if the XCFramework was successfully created
if [ -d "$OUTPUT_DIR" ]; then
  echo "Success: IOKit.xcframework has been created at $OUTPUT_DIR"
else
  echo "Error: Failed to create IOKit.xcframework"
  exit 1
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"
echo "Done!"
