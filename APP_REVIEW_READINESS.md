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
- [x] **High-resolution director artwork on GitHub**: replaced the 192 × 192 logo with a 1254 × 1254 JPEG derivative of the original director-framing artwork in `FrameGuide/Assets.xcassets/DirectorLogo.imageset/director.jpg`; `Contents.json` references it. Verified in the final simulator onboarding screenshot.
- [x] **17-screen visual regression check**: latest simulator capture [run #42395032783](https://github.com/prabhuvikas/FrameGuide/actions/runs/42395032783) completed successfully. Verified 17 distinct PNG files at 1206 × 2622 px, all valid and visually inspected; Custom Grid displays correct guide lines over the simulated landscape instead of a blank frame. The corresponding iOS simulator build and automated tests [run #42395032822](https://github.com/prabhuvikas/FrameGuide/actions/runs/42395032822) passed.

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
