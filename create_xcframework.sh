#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Set up variables
TEMP_DIR="$(mktemp -d)"
FRAMEWORKS_DIR="$(pwd)/Frameworks"
mkdir -p "$FRAMEWORKS_DIR"
OUTPUT_DIR="$FRAMEWORKS_DIR/IOKit.xcframework"

# Define supported platforms
PLATFORMS=(
  "iPhoneOS"
)

# Function to create framework for a specific platform
create_framework() {
  local platform=$1
  local sdk_name=$platform

  # Adjust SDK name for simulator
  if [ "$platform" == "iPhoneSimulator" ]; then
    sdk_name="iPhoneSimulator"
  fi

  # Define paths
  local sdk_path="/Applications/Xcode.app/Contents/Developer/Platforms/${platform}.platform/Developer/SDKs/${sdk_name}.sdk"
  local sdk_iokit="${sdk_path}/System/Library/Frameworks/IOKit.framework"
  local framework_dir="${TEMP_DIR}/${platform}/IOKit.framework"
  
  echo "Creating framework structure for $platform in $framework_dir"
  
  # Check if the platform SDK exists
  if [ ! -d "$sdk_path" ]; then
    echo "Warning: $platform SDK not found at $sdk_path, skipping..."
    return 1
  fi
  
  # Check if IOKit framework exists in the SDK
  if [ ! -d "$sdk_iokit" ]; then
    echo "Warning: IOKit framework not found for $platform, skipping..."
    return 1
  fi
  
  # Create framework directory structure
  mkdir -p "$framework_dir/Headers"
  mkdir -p "$framework_dir/Modules"
  
  # Copy headers from SDK
  cp -r "$sdk_iokit/Headers/"* "$framework_dir/Headers/" 2>/dev/null || echo "Warning: No headers found in $platform SDK"
  
  # Create umbrella header (IOKit.h) since it might not exist in the SDK
  cat > "$framework_dir/Headers/IOKit.h" << EOF
/* IOKit umbrella header */

#ifndef IOKit_h
#define IOKit_h

#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFSerialize.h>
#include <IOKit/IOCFUnserialize.h>
#include <IOKit/IODataQueueClient.h>
#include <IOKit/IODataQueueShared.h>
#include <IOKit/IOKitKeys.h>
#include <IOKit/IOMapTypes.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOReturn.h>
#include <IOKit/IOTypes.h>
#include <IOKit/OSMessageNotification.h>

#endif /* IOKit_h */
EOF
  
  # Create the module map
  cat > "$framework_dir/Modules/module.modulemap" << EOF
framework module IOKit {
  umbrella header "IOKit.h"
  export *
  module * { export * }
}
EOF
  
  # Create Info.plist with explicit platform and architectures
  local supported_platform=""
  local device_family=""
  local min_os_version="12.0"
  
  case "$platform" in
    "iPhoneOS")
      supported_platform="iPhoneOS"
      device_family="<array><integer>1</integer><integer>2</integer></array>"
      ;;
    "iPhoneSimulator")
      supported_platform="iPhoneSimulator"
      device_family="<array><integer>1</integer><integer>2</integer></array>"
      ;;
    "MacOSX")
      supported_platform="MacOSX"
      device_family=""
      min_os_version="10.15"
      ;;
  esac
  
  # Create Info.plist
  cat > "$framework_dir/Info.plist" << EOF
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
    <string>$min_os_version</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>$supported_platform</string>
    </array>
EOF

  if [ -n "$device_family" ]; then
    cat >> "$framework_dir/Info.plist" << EOF
    <key>UIDeviceFamily</key>
    $device_family
EOF
  fi

  cat >> "$framework_dir/Info.plist" << EOF
</dict>
</plist>
EOF
  
  # Create binary stub instead of using TBD file
  echo "Creating binary stub for $platform"
  
  # Define architecture based on platform
  local arch_flags=""
  case "$platform" in
    "iPhoneOS")
      arch_flags="-arch arm64"
      ;;
    "iPhoneSimulator")
      arch_flags="-arch arm64 -arch x86_64"
      ;;
    "MacOSX")
      arch_flags="-arch arm64 -arch x86_64"
      ;;
  esac
  
  # Create a temp directory for compilation
  local compile_dir="$(mktemp -d)"
  
  # Create a minimal C file with IOKit symbols
  cat > "$compile_dir/IOKit.c" << EOF
#include <stdint.h>

// Export required symbols
const double IOKitVersionNumber = 1.0;
const char IOKitVersionString[] = "1.0";

// Dummy function to force export of symbols
void *_IOKitRetainSymbols(void) {
    return (void*)&IOKitVersionNumber;
}
EOF
  
  # Compile the stub library
  local sdk_flag=""
  local min_version_flag=""
  case "$platform" in
    "iPhoneOS")
      sdk_flag="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
      min_version_flag="-mios-version-min=12.0"
      ;;
    "iPhoneSimulator")
      sdk_flag="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"
      min_version_flag="-mios-simulator-version-min=12.0"
      ;;
    "MacOSX")
      sdk_flag="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
      min_version_flag="-mmacosx-version-min=10.15"
      ;;
  esac
  
  # Compile and create the dynamic library
  (cd "$compile_dir" && \
   xcrun clang $arch_flags $sdk_flag $min_version_flag -dynamiclib -o IOKit IOKit.c \
   -install_name "/System/Library/Frameworks/IOKit.framework/IOKit" \
   -compatibility_version 1.0 -current_version 1.0)
  
  if [ $? -eq 0 ] && [ -f "$compile_dir/IOKit" ]; then
    cp "$compile_dir/IOKit" "$framework_dir/IOKit"
    rm -rf "$compile_dir"
    return 0
  else
    echo "Error: Failed to compile binary stub for $platform"
    rm -rf "$compile_dir"
    return 1
  fi
}

# Main execution starts here
echo "Creating IOKit.xcframework for multiple platforms..."

# Make sure output directory doesn't exist (remove it if it does)
rm -rf "$OUTPUT_DIR"

# Create an array to hold the framework arguments for xcodebuild
FRAMEWORK_ARGS=()

# Create frameworks for each platform
for platform in "${PLATFORMS[@]}"; do
    if create_framework "$platform"; then
        framework_path="${TEMP_DIR}/${platform}/IOKit.framework"
        FRAMEWORK_ARGS+=("-framework" "$framework_path")
        echo "Successfully created framework for $platform"
    else
        echo "Skipping $platform due to errors"
    fi
done

# Check if we have any frameworks to include
if [ ${#FRAMEWORK_ARGS[@]} -eq 0 ]; then
    echo "Error: No frameworks could be created for any platform. Exiting."
    exit 1
fi

# Create XCFramework with all available platforms
echo "Creating XCFramework with ${#FRAMEWORK_ARGS[@]} platform frameworks..."
xcodebuild -create-xcframework "${FRAMEWORK_ARGS[@]}" -output "$OUTPUT_DIR"

# Check if the XCFramework was successfully created
if [ -d "$OUTPUT_DIR" ]; then
    echo "Success: IOKit.xcframework has been created at $OUTPUT_DIR"
    echo "Included platforms:"
    for ((i=0; i<${#FRAMEWORK_ARGS[@]}; i+=2)); do
        echo "- ${FRAMEWORK_ARGS[$((i+1))]}" | sed 's|.*/\([^/]*\)/IOKit.framework|\1|'
    done
else
    echo "Error: Failed to create IOKit.xcframework"
    exit 1
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"
echo "Done!"
