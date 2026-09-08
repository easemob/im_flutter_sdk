#!/usr/bin/env bash
set -euo pipefail

# Fully automated, idempotent Android emulator setup for the Flutter IM SDK tests.
# Detects each piece and installs it if missing; skips what already exists:
#   JDK -> cmdline-tools -> emulator/platform-tools -> system image -> two minimal AVDs
# No Android Studio required.

fail() { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# ---- OS / arch ----
case "$(uname -s)" in
  Darwin) OS="mac" ;;
  Linux)  OS="linux" ;;
  *) fail "unsupported OS: $(uname -s)" ;;
esac

case "$(uname -m)" in
  arm64|aarch64) ABI="arm64-v8a" ;;
  x86_64|amd64)  ABI="x86_64" ;;
  *) fail "unsupported arch: $(uname -m)" ;;
esac

# ---- SDK root ----
detect_sdk_root() {
  local sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [[ -n "$sdk" && -d "$sdk" ]]; then echo "$sdk"; return 0; fi
  for sdk in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    if [[ -d "$sdk" ]]; then echo "$sdk"; return 0; fi
  done
  return 1
}

if sdk="$(detect_sdk_root)"; then
  SDK_ROOT="$sdk"
else
  SDK_ROOT="$HOME/Library/Android/sdk"
  [[ "$OS" == "linux" ]] && SDK_ROOT="$HOME/Android/Sdk"
  info "SDK root not found, using $SDK_ROOT"
  mkdir -p "$SDK_ROOT"
fi
export ANDROID_HOME="$SDK_ROOT"
export ANDROID_SDK_ROOT="$SDK_ROOT"

# ---- 1. JDK (17+) ----
ensure_java() {
  local ver=""

  # 1. Check PATH java version
  if command -v java >/dev/null 2>&1; then
    ver=$(java -version 2>&1 | head -1 | grep -oE '"[0-9]+' | tr -d '"')
    if [[ -n "$ver" && "$ver" -ge 17 ]]; then
      info "Java 17+ found: $(java -version 2>&1 | head -1)"
      return 0
    fi
    info "Java found but too old (version ${ver:-unknown}), looking for Java 17+ ..."
  fi

  # 2. macOS: prefer an already-installed Java 17 (brew openjdk@17 or java_home)
  if [[ "$OS" == "mac" ]]; then
    local candidates=(
      "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
      "/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
    )
    local jh
    jh="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
    [[ -n "$jh" ]] && candidates+=("$jh")
    local c
    for c in "${candidates[@]}"; do
      if [[ -x "$c/bin/java" ]]; then
        export JAVA_HOME="$c"
        export PATH="$JAVA_HOME/bin:$PATH"
        info "Using Java 17 from: $c"
        return 0
      fi
    done
  fi

  # 3. Auto-install
  info "Java 17+ not found, attempting auto-install ..."
  if [[ "$OS" == "mac" ]] && command -v brew >/dev/null 2>&1; then
    brew install --cask temurin17 || true
    local c
    for c in "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" \
             "/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"; do
      if [[ -x "$c/bin/java" ]]; then
        export JAVA_HOME="$c"
        export PATH="$JAVA_HOME/bin:$PATH"
        info "Java 17 installed at: $c"
        return 0
      fi
    done
  elif [[ "$OS" == "linux" ]] && command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq && sudo apt-get install -y -qq openjdk-17-jdk-headless
  fi

  # Final validation
  command -v java >/dev/null 2>&1 || fail "JDK 17+ required; install it and add java to PATH"
  ver=$(java -version 2>&1 | head -1 | grep -oE '"[0-9]+' | tr -d '"')
  [[ -n "$ver" && "$ver" -ge 17 ]] || fail "JDK 17+ required (found version: ${ver:-unknown})"
  info "Java 17+ ready: $(java -version 2>&1 | head -1)"
}

# ---- 2. cmdline-tools (sdkmanager / avdmanager) ----
CMD_TOOLS_VERSION="11076708"
SM="$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
AM="$SDK_ROOT/cmdline-tools/latest/bin/avdmanager"

ensure_cmdline_tools() {
  if [[ -x "$SM" && -x "$AM" ]]; then
    info "cmdline-tools found, skip"
    return 0
  fi
  info "cmdline-tools not found, downloading ..."
  local url="https://dl.google.com/android/repository/commandlinetools-${OS}-${CMD_TOOLS_VERSION}_latest.zip"
  local zip="/tmp/commandlinetools.zip"
  local tmp="/tmp/cmdline-tools-extract"
  curl -fL --max-time 600 -o "$zip" "$url"
  rm -rf "$tmp"; mkdir -p "$tmp"
  unzip -q "$zip" -d "$tmp"
  mkdir -p "$SDK_ROOT/cmdline-tools"
  rm -rf "$SDK_ROOT/cmdline-tools/latest"
  mv "$tmp/cmdline-tools" "$SDK_ROOT/cmdline-tools/latest"
  rm -rf "$tmp" "$zip"
  info "cmdline-tools installed"
}

# ---- 3. emulator + platform-tools ----
ensure_emulator() {
  local need=""
  [[ -x "$SDK_ROOT/emulator/emulator" ]] || need="emulator"
  [[ -x "$SDK_ROOT/platform-tools/adb" ]] || need="$need platform-tools"
  if [[ -n "$need" ]]; then
    info "Installing: $need (this downloads from Google, may take a while) ..."
    yes | "$SM" --sdk_root="$SDK_ROOT" $need
    info "Installed: $need"
  else
    info "emulator + platform-tools found, skip"
  fi
}

# ---- 4. system image ----
IMAGE="system-images;android-34;default;$ABI"

ensure_image() {
  if "$SM" --sdk_root="$SDK_ROOT" --list_installed 2>/dev/null | grep -q "$IMAGE"; then
    info "system image found, skip"
    return 0
  fi
  info "Downloading system image $IMAGE (first run only, may take a while) ..."
  yes | "$SM" --sdk_root="$SDK_ROOT" "$IMAGE"
  info "system image installed"
}

# ---- 5. two minimal AVDs ----
AVD_A="im_flutter_test_a"
AVD_B="im_flutter_test_b"

MIN_CONFIG='hw.lcd.width=720
hw.lcd.height=1280
hw.lcd.density=160
hw.gpu.mode=off
hw.gpu.enabled=no
disk.dataPartition.size=4G
hw.ramSize=2G
hw.cpu.ncore=4'

apply_min_config() {
  local cfg="$1"
  grep -vE '^(hw\.lcd\.width|hw\.lcd\.height|hw\.lcd\.density|hw\.gpu\.mode|hw\.gpu\.enabled|disk\.dataPartition\.size|hw\.ramSize|hw\.cpu\.ncore)=' \
    "$cfg" > "$cfg.tmp"
  mv "$cfg.tmp" "$cfg"
  printf '%s\n' "$MIN_CONFIG" >> "$cfg"
}

create_avd() {
  local name="$1"
  if "$SDK_ROOT/emulator/emulator" -list-avds 2>/dev/null | grep -qx "$name"; then
    info "AVD $name exists, skip"
    return 0
  fi
  info "Creating minimal AVD $name ..."
  echo "no" | "$AM" create avd -n "$name" -k "$IMAGE" --device pixel_2 --force >/dev/null 2>&1
  local cfg="$HOME/.android/avd/$name.avd/config.ini"
  [[ -f "$cfg" ]] || fail "AVD config not found: $cfg"
  apply_min_config "$cfg"
  info "AVD $name created ($ABI, 720x1280, gpu off)"
}

# ---- main ----
ensure_java
ensure_cmdline_tools
ensure_emulator
ensure_image
create_avd "$AVD_A"
create_avd "$AVD_B"

info "Emulators ready: $AVD_A, $AVD_B"
echo "    AVD_A=$AVD_A"
echo "    AVD_B=$AVD_B"
