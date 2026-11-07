# FrameGuide — Compose. Learn. Capture.

Native iPhone camera app using SwiftUI and AVFoundation, with 12 live composition guides, offline photographic tutorials and saved photos free of guides.

## Quick start

1. Open `FrameGuide.xcodeproj` in Xcode 16+.
2. Choose your Apple development team in Signing & Capabilities and set a unique bundle identifier.
3. Select a real iPhone running iOS 17 or later to test the camera.
4. Allow camera access when requested; allow Add Photos access on the first save.

No backend, account, cloud infrastructure, or network access required.

## Guides

Rule of Thirds; Golden Ratio Grid; Golden Spiral (rotation/mirror); Center Cross; Diagonal Guides; Square Grid; Horizon Level; Portrait Eye Line; Social Safe Area; Perspective Lines; Cinematic Frame; Custom Grid.

## Camera

Front/rear capture, flash on supported hardware, zoom, focus, exposure, optional timer, 4:3 / 1:1 / 16:9 framing, photo saving to the iOS Photos library, opacity and color preferences.

## Automated pull-request tests

GitHub Actions runs a simulator build and XCTest suite on each pull request, with code coverage and build/test artifact uploads. See [PR_AUTOMATION.md](PR_AUTOMATION.md). A separate GitHub branch protection rule is needed to require passing checks before merge.

## Scope / limits

iOS app build and tests need macOS/Xcode. A camera feed is not available in standard iPhone simulators. Real device testing is essential before TestFlight. No video capture, RAW support, AI scene detection, photo import, or cloud syncing in MVP.
