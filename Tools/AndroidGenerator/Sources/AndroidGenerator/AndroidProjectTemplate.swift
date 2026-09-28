import Foundation

enum AndroidProjectTemplate {
    static let gradleVersionCatalog = """
[versions]
agp = "9.3.1"
coreKtx = "1.10.1"
lifecycleRuntimeKtx = "2.6.1"
activityCompose = "1.8.0"
kotlin = "2.2.10"
composeBom = "2026.02.01"

[libraries]
androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "coreKtx" }
androidx-lifecycle-runtime-ktx = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycleRuntimeKtx" }
androidx-activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activityCompose" }
androidx-compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "composeBom" }
androidx-compose-ui = { group = "androidx.compose.ui", name = "ui" }
androidx-compose-ui-graphics = { group = "androidx.compose.ui", name = "ui-graphics" }
androidx-compose-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
androidx-compose-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
androidx-compose-material3 = { group = "androidx.compose.material3", name = "material3" }
androidx-compose-material-icons-extended = { group = "androidx.compose.material", name = "material-icons-extended" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-compose = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
"""

    static let topLevelBuildGradle = """
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.compose) apply false
}
"""

    static let gradleProperties = """
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
org.gradle.configuration-cache=true
kotlin.code.style=official
"""

    static func settingsGradle(projectName: String) -> String {
        """
pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\\\.android.*")
                includeGroupByRegex("com\\\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "\(projectName)"
include(":app")
"""
    }

    static func appBuildGradle(
        packageName: String,
        version: String,
        build: Int
    ) -> String {
        """
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "\(packageName)"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    defaultConfig {
        applicationId = "\(packageName)"
        minSdk = 24
        targetSdk = 36
        versionCode = \(build)
        versionName = "\(version)"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    buildFeatures {
        compose = true
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDir("build/generated/jniLibs")
            assets.srcDir("../../Shared/Files")
        }
    }
}

val buildSwiftLibrary by tasks.registering(Exec::class) {
    workingDir(rootProject.projectDir)
    commandLine("bash", "build-swift.sh")
}

tasks.named("preBuild") {
    dependsOn(buildSwiftLibrary)
}

dependencies {
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.material.icons.extended)
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    debugImplementation(libs.androidx.compose.ui.tooling)
}
"""
    }

    static func manifest(themeName: String) -> String {
        """
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/\(themeName)">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:label="@string/app_name"
            android:theme="@style/\(themeName)"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
"""
    }

    static func strings(displayName: String, copyright: String) -> String {
        let escapedDisplayName = xmlEscaped(displayName)
        let escapedCopyright = xmlEscaped(copyright)

        return """
<resources>
    <string name="app_name">\(escapedDisplayName)</string>
    <string name="app_copyright" formatted="false">\(escapedCopyright)</string>
</resources>
"""
    }

    private static func xmlEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "\\'")
    }

    static func themes(themeName: String) -> String {
        """
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="\(themeName)" parent="android:Theme.Material.Light.NoActionBar" />
</resources>
"""
    }

    static func packageSwift(applicationType: String, repository: String, branch: String) -> String {
        let packageIdentity = repository.split(separator: "/").last.map(String.init)?
            .replacingOccurrences(of: ".git", with: "") ?? "ConcordUI"
        return """
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ConcordUIAndroidApplication",
    products: [
        .library(name: "ConcordUIAndroidApplication", type: .dynamic, targets: ["AndroidBridge"])
    ],
    dependencies: [
        .package(url: \(String(reflecting: repository)), branch: \(String(reflecting: branch)))
    ],
    targets: [
        .target(
            name: "SharedApplication",
            dependencies: [.product(name: "ConcordUI", package: "\(packageIdentity)")],
            path: "Shared/Swift"
        ),
        .target(
            name: "AndroidBridge",
            dependencies: [
                "SharedApplication",
                .product(name: "ConcordUI", package: "\(packageIdentity)")
            ],
            path: "Android/SwiftBridge"
        )
    ]
)
"""
    }

    static func buildSwift() -> String {
        """
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
    ANDROID_SDK="$(sed -n 's/^sdk\\.dir=//p' "$ANDROID_DIR/local.properties" | head -n 1)"
    ANDROID_SDK="${ANDROID_SDK//\\:/:}"
    ANDROID_SDK="${ANDROID_SDK//\\ / }"
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
"""
    }
}
