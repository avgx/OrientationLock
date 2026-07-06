# OrientationLock

SPM library for controlling iOS app orientation: portrait by default, forced landscape on button tap (like YouTube / VK Video).

## Policy vs Action

The library separates two independent operations:

| | Policy (`allow`) | Action (`force`) |
|---|---|---|
| **UIKit equivalent** | `supportedInterfaceOrientations` | `requestGeometryUpdate` / `setValue` |
| **Question** | Which orientations are **allowed**? | **Rotate** the screen right now |
| **Rotates the screen?** | No | Yes |

```swift
// Camera screen opens — landscape left is allowed, phone held vertically → nothing happens
CameraView().allowedOrientations(.landscapeLeft)

// User taps the landscape button → screen rotates
LandscapeToggleButton()
```

## Why AppDelegate is required

UIKit asks `UIApplicationDelegate` for `supportedInterfaceOrientations`. Without `OrientationLockAppDelegate`, `requestGeometryUpdate` cannot change the allowed orientation mask — the system silently rejects the update.

## Integration

### 1. Info.plist

`UISupportedInterfaceOrientations` must include both portrait and landscape orientations.

### 2. AppDelegate

```swift
import OrientationLock
import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(OrientationLockAppDelegate.self)
    private var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

Default allowed orientations is `.portrait` — no extra setup needed.

### 3. Camera / video screen

```swift
CameraView()
    .allowedOrientations(.landscapeLeft)
    .resetsLandscapeOnDisappear()

.toolbar {
    ToolbarItem(placement: .primaryAction) {
        LandscapeToggleButton()
    }
}
```

Or programmatically:

```swift
OrientationLock.shared.enterLandscape()
OrientationLock.shared.exitLandscape()
```

### 4. Advanced API

```swift
OrientationLock.shared.allow(.landscapeLeft)  // policy only
OrientationLock.shared.force(.landscapeLeft)  // policy + rotate
OrientationLock.shared.forceLandscape()
```

## System rotation lock

On iOS 16+, rotation uses `requestGeometryUpdate` only (no `UIDevice.setValue`). If the user has rotation locked in Control Center, forced rotation may not work.

On iOS 15, `force` falls back to `UIDevice.setValue`.

## iPad

On iPad with multitasking (Split View / Slide Over), orientation behavior may differ from iPhone.
