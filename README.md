# iOS Playground

A tap-through catalogue of how modern iOS apps are built. Every screen is an interactive example with a
"How it works" explanation behind the ⓘ button in the navigation bar, so you can understand a pattern
without reading the source first.

Everything runs offline in the Simulator: no accounts, no network, no third-party dependencies.

## Running it

```bash
open iOSPlayground.xcodeproj    # then ⌘R
```

From the command line:

```bash
xcodebuild -project iOSPlayground.xcodeproj -scheme iOSPlayground \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Requires an Xcode whose iOS SDK matches an installed Simulator runtime (the project targets iOS 26.0).

## The five tabs

| Tab | What it covers |
| --- | --- |
| **Foundations** | Materials and Liquid Glass, typography, layout, lists, controls, navigation, presentation, accessibility |
| **Data** | State ownership, `@Observable`, SwiftData, async/await, loading/empty/error states |
| **Motion** | Springs, transitions, gestures, scroll effects |
| **Platform** | Sharing, haptics, maps, charts, notifications, localisation |
| **Interop** | `UIViewRepresentable`, `UIViewControllerRepresentable`, `UIHostingController`, coordinators |

## How the catalogue is wired

- `App/Catalog/Demo.swift` — the `Demo` model: an id, a summary, the explanation shown in the sheet, and the view itself
- `App/Catalog/DemoCatalog.swift` — the list of tabs; adding a demo here is all it takes to make it appear
- `App/Components/DemoScreen.swift` — hosts a demo and hangs the explanation off the toolbar
- `App/<Tab>/…` — the demos themselves, one file per screen

Because navigation is driven by `DemoID`, the UI test suite can walk the entire catalogue automatically:
any new demo is opened and smoke-tested without touching the tests.

## Project generation

The Xcode project is committed, so you do not need any tooling to open it. It is generated from
`project.yml` — if you change targets or build settings, edit that file and run:

```bash
brew install xcodegen
xcodegen generate
```

## Tests

- `Tests/` — Swift Testing unit tests (catalogue integrity, view models, data layer)
- `UITests/` — XCUITest suite that opens every demo in every tab
