#!/bin/sh
#
# Xcode Cloud post-clone hook.
#
# Xcode Cloud clones the repo and runs `xcodebuild archive` directly. Nothing
# in that path runs Flutter, so ios/Flutter/Generated.xcconfig (a gitignored,
# machine-specific build artifact that Release.xcconfig #includes) never
# exists and the archive fails on the very first xcconfig line. This script
# installs Flutter on the build machine and lets it generate that file — and
# integrate the native plugins (Swift Package Manager by default in Flutter
# 3.44, CocoaPods fallback for plugins without a Package.swift) — before
# xcodebuild starts.
#
# The Flutter version is PINNED to the one this repo was built with. Tracking
# `stable` would let the CI toolchain drift away from pubspec.lock.

set -e

# Xcode Cloud starts this script inside ci_scripts/; work from the repo root.
cd "$CI_PRIMARY_REPOSITORY_PATH"

FLUTTER_VERSION="3.44.9"
git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter --version
flutter precache --ios
flutter pub get

# CocoaPods is still required for any plugin that has no Package.swift;
# `flutter build ios --config-only` generates the Podfile and runs `pod
# install` itself when that is the case.
export HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

# Writes ios/Flutter/Generated.xcconfig and flutter_export_environment.sh,
# resolves plugins and wires them into the Xcode project. Does NOT compile —
# xcodebuild does that next, with FLUTTER_ROOT now defined.
flutter build ios --config-only --release --no-codesign

exit 0
