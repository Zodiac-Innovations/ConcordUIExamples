#!/usr/bin/env bash
set -euo pipefail

ANDROID_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$ANDROID_DIR/.." && pwd)"
TRIPLE="${CONCORD_SWIFT_ANDROID_TRIPLE:-aarch64-unknown-linux-android28}"
CONFIGURATION="${CONCORD_SWIFT_CONFIGURATION:-debug}"
OUTPUT_DIR="$ANDROID_DIR/app/build/generated/jniLibs/arm64-v8a"
NDK_VERSION="${CONCORD_ANDROID_NDK_VERSION:-29.0.14206865}"
SWIFTLY_BIN="${SWIFTLY_BIN:-$HOME/.swiftly/bin/swiftly}"

if [[ -x "$SWIFTLY_BIN" ]]; then
    TOOLCHAIN_ROOT="$($SWIFTLY_BIN use --print-location 2>/dev/null || true)"
    if [[ -n "$TOOLCHAIN_ROOT" && -d "$TOOLCHAIN_ROOT/usr/bin" ]]; then
        export PATH="$TOOLCHAIN_ROOT/usr/bin:$HOME/.swiftly/bin:$PATH"
    else
        export PATH="$HOME/.swiftly/bin:$PATH"
    fi
fi

SWIFT_BIN="$(command -v swift || true)"
[[ -n "$SWIFT_BIN" ]] || { echo "Swift was not found. Install the ConcordUI-required Swift toolchain with Swiftly." >&2; exit 1; }

ANDROID_SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$ANDROID_SDK" && -f "$ANDROID_DIR/local.properties" ]]; then
    ANDROID_SDK="$(sed -n 's/^sdk\.dir=//p' "$ANDROID_DIR/local.properties" | head -n 1)"
    ANDROID_SDK="${ANDROID_SDK//\:/:}"
    ANDROID_SDK="${ANDROID_SDK//\ / }"
fi
if [[ -z "$ANDROID_SDK" && -d "$HOME/Library/Android/sdk" ]]; then
    ANDROID_SDK="$HOME/Library/Android/sdk"
fi

NDK_ROOT="${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}"
if [[ -z "$NDK_ROOT" && -n "$ANDROID_SDK" && -d "$ANDROID_SDK/ndk/$NDK_VERSION" ]]; then
    NDK_ROOT="$ANDROID_SDK/ndk/$NDK_VERSION"
fi
[[ -n "$NDK_ROOT" ]] || { echo "Android NDK $NDK_VERSION was not found." >&2; exit 1; }

SWIFT_SDK_SEARCH_ROOT="${CONCORD_SWIFT_SDK_ROOT:-$HOME/Library/org.swift.swiftpm/swift-sdks}"
SWIFT_STATIC_RESOURCES="$(find "$SWIFT_SDK_SEARCH_ROOT" -type d -path '*/swift-android/swift-resources/usr/lib/swift_static-aarch64' -print -quit 2>/dev/null || true)"
[[ -n "$SWIFT_STATIC_RESOURCES" ]] || { echo "Swift Android static resources were not found." >&2; exit 1; }

cd "$PROJECT_DIR"
echo "==> Building ConcordUI application for Android"
BUILD_ARGS=(build --configuration "$CONFIGURATION" --product ConcordUIAndroidApplication -Xswiftc -static-stdlib -Xswiftc -resource-dir -Xswiftc "$SWIFT_STATIC_RESOURCES")
if [[ -n "${CONCORD_SWIFT_ANDROID_SDK:-}" ]]; then
    "$SWIFT_BIN" "${BUILD_ARGS[@]}" --swift-sdk "$CONCORD_SWIFT_ANDROID_SDK" --triple "$TRIPLE"
else
    "$SWIFT_BIN" "${BUILD_ARGS[@]}" --swift-sdk "$TRIPLE"
fi

LIBRARY="$PROJECT_DIR/.build/$TRIPLE/$CONFIGURATION/libConcordUIAndroidApplication.so"
[[ -f "$LIBRARY" ]] || { echo "Swift Android library was not found at: $LIBRARY" >&2; exit 1; }
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/*.so
cp "$LIBRARY" "$OUTPUT_DIR/"

SWIFT_RUNTIME_DIR="$(find "$SWIFT_SDK_SEARCH_ROOT" -type d -path '*/swift-android/swift-resources/usr/lib/swift-aarch64/android' -print -quit 2>/dev/null || true)"
[[ -n "$SWIFT_RUNTIME_DIR" ]] || { echo "Swift Android runtime libraries were not found." >&2; exit 1; }
cp "$SWIFT_RUNTIME_DIR"/*.so "$OUTPUT_DIR/"

CXX_LIBRARY="$(find "$NDK_ROOT/toolchains/llvm/prebuilt" -path '*/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so' -print -quit)"
[[ -f "$CXX_LIBRARY" ]] || { echo "libc++_shared.so was not found." >&2; exit 1; }
cp "$CXX_LIBRARY" "$OUTPUT_DIR/"