#!/usr/bin/env bash
set -euo pipefail

GENERATOR_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

APP_DIR="$WORK_DIR/Example"
mkdir -p "$APP_DIR/Shared/Swift" "$APP_DIR/Shared/Icons" "$WORK_DIR/bin" "$WORK_DIR/jdk"
cat > "$APP_DIR/ConcordUI.info" <<'INFO'
formatVersion=1
name=Example
displayName=Example
key=com.example
version=0.1.0
build=1
copyright=© 2026 Example
repo=https://github.com/Zodiac-Innovations/ConcordUIExperiment.git
branch=experiment
INFO
printf 'public final class ExampleApplication {}\n' > "$APP_DIR/Shared/Swift/ExampleApplication.swift"
printf 'png' > "$APP_DIR/Shared/Icons/appicon-1024.png"
cat > "$WORK_DIR/bin/gradle" <<'GRADLE'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p gradle/wrapper
printf '#!/usr/bin/env bash\n' > gradlew
printf '@echo off\n' > gradlew.bat
printf 'jar' > gradle/wrapper/gradle-wrapper.jar
printf 'distributionUrl=fake\n' > gradle/wrapper/gradle-wrapper.properties
GRADLE
chmod +x "$WORK_DIR/bin/gradle"
PATH="$WORK_DIR/bin:$PATH" JAVA_HOME="$WORK_DIR/jdk" \
  xcrun swift run --package-path "$GENERATOR_DIR" concordui-android-generate --project "$APP_DIR"

test -f "$APP_DIR/Android/app/src/main/java/com/example/example/MainActivity.kt"
test -f "$APP_DIR/Android/SwiftBridge/ConcordAndroidBridge.swift"
test -f "$APP_DIR/Android/gradlew"
grep -q 'ConcordUIExperiment.git' "$APP_DIR/Package.swift"
grep -q 'branch: "experiment"' "$APP_DIR/Package.swift"
