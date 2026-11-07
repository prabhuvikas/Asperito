# FrameGuide MVP Validation Snapshot

**Date:** 2026-11-07

| Check | Result |
|---|---|
| Swift syntax (`swiftc -frontend -parse` over all `.swift` files) | Passed |
| Xcode project plist (`plutil -lint`) | Passed |
| Privacy manifest plist (`plutil -lint`) | Passed |
| Xcode project/scheme XML structure | Passed |
| Native iOS build (`xcodebuild` on macOS) | Not run — macOS/Xcode unavailable |
| Simulator tests | Not run — macOS/Xcode unavailable |
| Real iPhone camera test | Not run — physical iPhone unavailable |
| TestFlight / code signing | Not run — Apple developer team required |

**Status:** complete source implementation and test scaffolding; compilation and device acceptance remain unverified. Do not treat the static parsing checks as proof that the application builds or runs on iOS.

## Manual first-device QA

1. Grant camera permission, verify live camera works; deny and retry from Settings.
2. Check all 12 guides, overlay opacity, color and settings persistence.
3. Switch portrait/landscape and front/rear cameras; check preview/captured framing alignment.
4. Capture photos in 4:3, 1:1 and 16:9. Compare actual image dimensions and guide-free pixels.
5. Test flash, exposure bias, touch focus, zoom, timer, Photos permission denial and low storage.
6. Verify horizon leveling in both orientations and test camera interruption (phone call/background).
7. Run `xcodebuild ... test`, then run TestFlight beta on the oldest supported iPhone.
