#!/usr/bin/env bash
set -euo pipefail

# update_hyphenate.sh
# One-click updater for HyphenateChat dependency versions across Android & iOS in im_flutter_sdk example app.
# - Updates plugin dependency versions (Android/iOS) to the desired HyphenateChat version
# - Ensures Android Gradle uses JDK 17 for AGP 8.x
# - Ensures iOS platform is >= 12.0 and reinstalls Pods with UTF-8
# - Optionally builds Android and/or iOS to verify

# USAGE
#   HY_CHAT_VERSION=4.19.1 ./scripts/update_hyphenate.sh all --build
#   ./scripts/update_hyphenate.sh android
#   ./scripts/update_hyphenate.sh ios --no-build
# ENV VARS
#   HY_CHAT_VERSION   Target HyphenateChat version (default: 4.19.1)
#   IOS_PLATFORM      iOS minimum deployment target (default: 12.0)
#   JDK17_HOME        Path to JDK 17 (auto-detected if not provided)
#   REPO_ROOT         Repo root (auto-detected to this script's parent if not provided)

HY_CHAT_VERSION="${HY_CHAT_VERSION:-4.19.1}"
IOS_PLATFORM="${IOS_PLATFORM:-12.0}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Monorepo group root that contains platform subpackages as siblings of im_flutter_sdk
GROUP_ROOT="${GROUP_ROOT:-$(cd "$REPO_ROOT/.." && pwd)}"

PLUG_ANDROID_GRADLE="$GROUP_ROOT/im_flutter_sdk_android/android/build.gradle"
EX_ANDROID_DIR="$REPO_ROOT/example/android"
EX_ANDROID_GRADLE_PROPS="$EX_ANDROID_DIR/gradle.properties"

PLUG_IOS_PODSPEC="$GROUP_ROOT/im_flutter_sdk_ios/ios/im_flutter_sdk_ios.podspec"
EX_IOS_DIR="$REPO_ROOT/example/ios"
EX_IOS_PODFILE="$EX_IOS_DIR/Podfile"

color() { local c="$1"; shift; printf "\033[%sm%s\033[0m\n" "$c" "$*"; }
info(){ color 36 "$*"; }
ok(){ color 32 "$*"; }
warn(){ color 33 "$*"; }
err(){ color 31 "$*"; }

find_jdk17(){
  if [[ -n "${JDK17_HOME:-}" && -x "$JDK17_HOME/bin/java" ]]; then
    echo "$JDK17_HOME"; return 0
  fi
  if command -v /usr/libexec/java_home >/dev/null 2>&1; then
    local j; j=$(/usr/libexec/java_home -v 17 2>/dev/null || true)
    if [[ -n "$j" && -x "$j/bin/java" ]]; then echo "$j"; return 0; fi
  fi
  # common macOS Oracle path
  if [[ -x "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/bin/java" ]]; then
    echo "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"; return 0
  fi
  return 1
}

update_android_version(){
  info "[Android] Updating HyphenateChat version to ${HY_CHAT_VERSION} in $PLUG_ANDROID_GRADLE"
  if [[ ! -f "$PLUG_ANDROID_GRADLE" ]]; then err "Missing $PLUG_ANDROID_GRADLE"; return 1; fi
  sed -E -i '' "s#implementation 'io.hyphenate:hyphenate-chat:[^']*'#implementation 'io.hyphenate:hyphenate-chat:${HY_CHAT_VERSION}'#g" "$PLUG_ANDROID_GRADLE"
}

ensure_jdk17(){
  info "[Android] Ensuring Gradle runs with JDK 17"
  mkdir -p "$EX_ANDROID_DIR"
  touch "$EX_ANDROID_GRADLE_PROPS"
  local jdk_home
  if ! jdk_home="$(find_jdk17)"; then
    warn "JDK 17 not found automatically. Please set JDK17_HOME and re-run."
    return 0
  fi
  if grep -q '^org.gradle.java.home=' "$EX_ANDROID_GRADLE_PROPS"; then
    sed -i '' "s#^org\.gradle\.java\.home=.*#org.gradle.java.home=${jdk_home}#" "$EX_ANDROID_GRADLE_PROPS"
  else
    printf "\norg.gradle.java.home=%s\n" "$jdk_home" >> "$EX_ANDROID_GRADLE_PROPS"
  fi
  ok "Using JDK17 at: $jdk_home"
}

build_android(){
  info "[Android] Building example app (assembleDebug)"
  (cd "$EX_ANDROID_DIR" && ./gradlew :app:assembleDebug -x lint)
}

verify_android(){
  info "[Android] Verifying resolved dependency version"
  (cd "$EX_ANDROID_DIR" && ./gradlew :app:dependencyInsight --configuration debugRuntimeClasspath --dependency hyphenate-chat | sed -n '1,120p')
}

update_ios_version(){
  info "[iOS] Updating HyphenateChat version to ${HY_CHAT_VERSION} in $PLUG_IOS_PODSPEC"
  if [[ ! -f "$PLUG_IOS_PODSPEC" ]]; then err "Missing $PLUG_IOS_PODSPEC"; return 1; fi
  sed -E -i '' "s#(s\.dependency 'HyphenateChat'\s*,\s*')[^']*'#\1${HY_CHAT_VERSION}'#g" "$PLUG_IOS_PODSPEC"
}

ensure_ios_platform(){
  info "[iOS] Ensuring Podfile platform :ios, '${IOS_PLATFORM}'"
  if [[ ! -f "$EX_IOS_PODFILE" ]]; then err "Missing $EX_IOS_PODFILE"; return 1; fi
  if grep -Eq "^\s*platform\s*:ios" "$EX_IOS_PODFILE"; then
    sed -E -i '' "s|^\s*platform\s*:ios,.*|platform :ios, '${IOS_PLATFORM}'|" "$EX_IOS_PODFILE"
  elif grep -Eq "^\s*#\s*platform\s*:ios" "$EX_IOS_PODFILE"; then
    sed -E -i '' "s|^\s*#\s*platform\s*:ios,.*|platform :ios, '${IOS_PLATFORM}'|" "$EX_IOS_PODFILE"
  else
    # prepend if no platform found
    printf "platform :ios, '%s'\n\n%s" "$IOS_PLATFORM" "$(cat "$EX_IOS_PODFILE")" > "$EX_IOS_PODFILE.tmp" && mv "$EX_IOS_PODFILE.tmp" "$EX_IOS_PODFILE"
  fi
}

pods_install(){
  info "[iOS] Reinstalling Pods (UTF-8)"
  export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
  (cd "$EX_IOS_DIR" && rm -rf Pods Podfile.lock && pod repo update && pod install)
}

build_ios(){
  info "[iOS] Building Runner for iOS Simulator (Debug)"
  export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
  (cd "$EX_IOS_DIR" && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -destination 'generic/platform=iOS Simulator' build)
}

verify_ios(){
  info "[iOS] Verifying Podfile.lock version"
  if [[ -f "$EX_IOS_DIR/Podfile.lock" ]]; then
    if command -v rg >/dev/null 2>&1; then
      rg -n "HyphenateChat \(${HY_CHAT_VERSION}\)" "$EX_IOS_DIR/Podfile.lock" || true
    else
      grep -n "HyphenateChat (" "$EX_IOS_DIR/Podfile.lock" | head -n 3 || true
    fi
  else
    warn "Podfile.lock not found yet. Run pods_install first."
  fi
}

usage(){
  cat <<USAGE
Usage: $(basename "$0") [android|ios|all] [--build|--no-build]
Defaults: target=all, --no-build
Env: HY_CHAT_VERSION=${HY_CHAT_VERSION}, IOS_PLATFORM=${IOS_PLATFORM}, REPO_ROOT=${REPO_ROOT}
USAGE
}

TARGET="all"
DO_BUILD=false
for arg in "$@"; do
  case "$arg" in
    android|ios|all) TARGET="$arg" ;;
    --build) DO_BUILD=true ;;
    --no-build) DO_BUILD=false ;;
    -h|--help) usage; exit 0 ;;
    *) warn "Unknown arg: $arg" ;;
  esac

done

case "$TARGET" in
  android)
    update_android_version
    ensure_jdk17 || true
    if $DO_BUILD; then build_android; fi
    verify_android || true
    ;;
  ios)
    update_ios_version
    ensure_ios_platform
    pods_install
    if $DO_BUILD; then build_ios; fi
    verify_ios || true
    ;;
  all)
    update_android_version
    ensure_jdk17 || true
    update_ios_version
    ensure_ios_platform
    pods_install
    if $DO_BUILD; then build_android; build_ios; fi
    verify_android || true
    verify_ios || true
    ;;
  *) usage; exit 1 ;;

esac

exit 0
