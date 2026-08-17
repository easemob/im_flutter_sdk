#!/usr/bin/env bash
set -euo pipefail

udid="$({
  xcrun simctl list devices available --json | ruby -rjson -e '
    devices = JSON.parse(STDIN.read).fetch("devices").values.flatten
    iphone = devices.find { |device| device.fetch("name", "").start_with?("iPhone") }
    abort "No available iPhone simulator was found" unless iphone
    puts iphone.fetch("udid")
  '
})"

xcrun simctl boot "$udid" 2>/dev/null || true
xcrun simctl bootstatus "$udid" -b >&2
printf '%s\n' "$udid"
