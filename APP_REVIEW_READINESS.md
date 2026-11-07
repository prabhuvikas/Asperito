# Asperito — App Review / TestFlight readiness audit
Updated 7 November 2026

This is a **pre-submission audit**, not a guarantee of Apple approval. A passing Simulator build does not validate physical camera capture, hardware flash, orientation and Photos permissions.

## Visual checks (17 simulator screens)

- [x] Brand name and gold/dark camera chrome consistent.
- [x] 12 composition guide types present in app and screenshot harness.
- [x] Camera chrome labels improved for contrast; primary controls enlarged to 44pt.
- [x] Guide selection cells use high-contrast text.
- [x] Tutorial illustration uses the same brand colors.
- [x] Onboarding is scrollable for short screens and accessible text sizes.
- [x] Privacy policy accessible in Settings.
- [ ] **High-resolution original director artwork on GitHub**: onboarding image in this repository is still a small raster; the local downloadable branded project has the full original.
- [ ] Inspect screenshots from the newest 17-screen CI artifact. A prior custom-grid frame was blank; the workflow now retries incomplete frames.

## Functional / device tests that MUST be completed on a real iPhone

- [ ] Fresh installation: camera permission granted; viewfinder appears.
- [ ] Fresh installation: camera denied; Settings recovery works.
- [ ] Front/rear switch and flash enabled only where supported.
- [ ] Tap-to-focus and exposure adjustment.
- [ ] 4:3, square, 16:9 photo capture and orientation/crop.
- [ ] Save with Photos Add Only granted and denied; user feedback shown in both cases.
- [ ] Multiple quick shutter taps, background/foreground, incoming-call interruption.
- [ ] Timer cancellation when app backgrounds.
- [ ] Gyroscope horizon overlay and rotation on a real phone.
- [ ] Physical iPhone portrait and landscape; large text / VoiceOver.
- [ ] Battery, thermal and memory testing with extended camera use.

## App Store Connect and release blocks

- [ ] Active Apple Developer Program membership and distribution signing.
- [ ] App Store Connect app record, screenshot sets, age questionnaire, descriptions, privacy declaration.
- [ ] **Public, stable Privacy Policy URL**: PRIVACY.md currently lives on the feature branch; host a permanent public policy (for example GitHub Pages) before App Store review. Apple additionally requires an in-app policy link (now available).
- [ ] **Support URL and contact** must be supplied by the developer.
- [ ] App Review notes explaining that overlays are viewfinder-only, no login/network is needed, and the camera requires a physical device.
- [ ] Confirm rights to the brand name and director artwork.
- [ ] Never use screenshot-only simulated scenery in App Store images as if captured by the physical camera.
- [ ] Submit real iPhone photos / authentic screenshots to represent actual functionality.
- [ ] Merge development PR only after clean CI and on-device acceptance.

Apple references:
https://developer.apple.com/app-store/review/guidelines/
https://developer.apple.com/design/tips/
https://developer.apple.com/help/app-review/before-submitting-for-review/complete-review

## Reproducible CI

`.github/workflows/ios.yml`: Xcode simulator build, XCTest, coverage.
`.github/workflows/screenshots.yml`: Debug-only screenshot harness, actual SwiftUI composition UI above a **simulated** scenery. Includes 4 attempts per frame, minimum output-size check, and a hard check for 17 PNGs.

The debug screenshot fixture is behind `#if DEBUG` and isn't included in Release builds.
