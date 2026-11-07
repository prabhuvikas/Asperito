# FrameGuide MVP Product Specification

**Platform:** iPhone, iOS 17+, SwiftUI + AVFoundation. **Release:** 1.0. **Goal:** compose, learn and capture, offline.

## Scope

Live rear/front camera, flash when supported, zoom, tap focus, exposure, timer, camera permission, photo capture, framing crops (4:3 / 1:1 / 16:9), saving to Photos, and 12 composition guides. Colors, opacity and relevant guide parameters are adjustable. Guided explanations and exercises for every overlay work offline.

## Screen flow

Launch → Camera authorization → Live Camera → Overlay Picker (sheet) → Tutorial (sheet) → Camera → Shutter → Photos save. Settings opens as a separate sheet. The last overlay and settings persist.

## Acceptance gates

1. All 12 guides render on supported preview sizes and both orientations.
2. Preview-aligned framing and actual photo crop are verified on real iPhone cameras.
3. Guide pixels never appear in the photo data.
4. Front/rear switch, tap to focus, zoom, flash, exposure and timer work correctly when hardware supports them.
5. 12 lessons function without any network access.
6. Permission denial, background/foreground, camera interruptions, and save failure are handled gracefully.
7. UI labels, Dynamic Type, and VoiceOver are reviewed.

## Explicitly out of scope

Video, image import/edit, RAW, AI coaching, automatic perspective detection, accounts, subscriptions and backend services.

## Shipping checkpoints

Source code, syntax scan, Xcode simulator build, device smoke test, orientation/flash/zoom matrix, Photos permission testing, TestFlight, and App Store privacy review. Simulator and real-device stages have not been completed in this delivery.
