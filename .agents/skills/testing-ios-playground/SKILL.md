---
name: test-ios-playground-simulator
description: Build and visually test the iOS Playground catalog in the iOS Simulator and capture a native screenshot tour.
---

# iOS Playground Simulator testing

## Devin Secrets Needed

None: the sample application has no account or authentication.

## Launch

- The committed `iOSPlayground.xcodeproj` can be built directly. Run `xcodegen generate` only after changing `project.yml`.
- Inspect available Xcode installations and Simulator runtimes when destination resolution fails. On this machine the verified pair is Xcode 27 RC and iPhone 17 / iOS 27:
  `/Applications/Xcode-27.0-RC.app/Contents/Developer/usr/bin/xcodebuild -project iOSPlayground.xcodeproj -scheme iOSPlayground -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' build`.
- Set `DEVELOPER_DIR=/Applications/Xcode-27.0-RC.app/Contents/Developer` for `xcrun simctl` commands so they use the same toolchain. Install the built `.app` into the booted device; launch `com.devin.iosplayground`.
- Use the build output to locate the `.app`; DerivedData paths can change between machines.

## Visual coverage

- Derive the demo list from `App/*/*Tab.swift`, not an assumed count. Visit all five tabs, each demo, and its top-right How it works sheet. Expand/scroll the sheet to see the explanation and code.
- Wait for navigation transitions before the next tap.
- Record native UI input and use `xcrun simctl io booted screenshot <path>` for clean full-resolution PNGs. Store artifacts outside `/tmp`, such as `~/ios-tour`.
- Capture five tab lists and materials, hero grid/detail, canvas, chart, map, and UIKit collection views.
- The photo picker can use Simulator sample images; local-notification permission can be granted within the test.
- For drag/long-press evidence, keep the mouse held while capturing transient state. Long press should show green/Holding, then return to gray with an incremented count.
- Simulator Option-drag multi-touch may not be reliable through automation. Never count a normal drag as proof of pinch or rotation; require visible changed scale/angle or mark them untested.
- Check UIKit page-control dot contrast on the light card and verify both dot taps and page swipes synchronize the displayed SwiftUI page number.
