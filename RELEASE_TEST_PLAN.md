# Asperito — Release Acceptance and Automated Testing

Updated 8 November 2026. **Passing Simulator tests does not establish physical camera, multi-touch, Photos authorization, or haptic correctness.**

## Automated CI gates

The `.github/workflows/ios.yml` job builds and tests the Xcode project on a real macOS GitHub runner and fails on:
- Swift compile, link, XCTest or XCUITest failures
- Malformed project or privacy manifests
- Missing `xccov` reports or less than **40% measured line coverage** for **each** core implementation file: `OverlayGeometry.swift`, `OverlayType.swift`, `OverlayLesson.swift`

Coverage reports and `TestResults.xcresult` are retained as artifacts. Threshold applies to these *core modules only*, not to the full app. Hardware-specific methods are not faked to inflate coverage. Do not advertise the percentage as total product code coverage.

**XCTest unit coverage**
- Exactly 18 unique guides and 18 offline lessons.
- Every overlay renders in portrait and landscape.
- Six newer guides: rotation, mirror, geometry and bounds.
- Golden Spiral construction and orientation.
- Save permissions: accepted and denied Photo Library statuses.
- JPEG conversion and 4:3 / square / 16:9 photo crop outputs, invalid image handling.
- Separate per-guide angle state, normalization and corrupt settings handling.
- Guide rotation geometry and fixed versus rotatable guide types.
- Camera aspect ratio definitions and custom grid clamping.

**XCUITest integration coverage**
- Actual iOS simulator app launches in a deterministic test scene.
- Camera toolbar contains capture, switch, settings and exposure buttons.
- Overlay visibility can be toggled.
- All 18 selectable composition guides are present in picker.
- Golden Spiral is selected and its rotation action exists.
- Offline tutorial navigation.
- Settings guide-visibility toggle persists across termination/relaunch.
- Privacy policy is reachable and displays content.

`.github/workflows/screenshots.yml` captures **23** distinct Simulator screenshots (18 guide screens plus 5 app screens), verifies PNG outputs and uploads originals. The GitHub Pages website workflow exercises **all 18** selector controls in desktop and mobile browser viewports, checking each selected screenshot loads.

## Physical iPhone acceptance matrix (manual — not claimed as complete)

Record iPhone model, iOS version, app commit, signed build number, tester, observed result and evidence for every check. Do not submit to TestFlight external testers until all high-severity functional checks pass.

| Area | Procedure | Expected result | Evidence |
| --- | --- | --- | --- |
| Fresh install | Delete app, reinstall, reject Camera permission | Clear notice and working Settings recovery | Screenshot |
| Camera permission recovery | Grant Camera in Settings, reopen | Live preview resumes without restarting iPhone | Video |
| Rear/front camera | Switch camera repeatedly | Correct feed, no stale frame or freeze | Video |
| Focus | Tap at multiple viewfinder locations | Focus/exposure updates, no rotation | Video |
| Gesture rotation | Select Golden Spiral; twist with two fingers to +30°, -60°, and +90° | Overlay rotates fluidly; camera feed remains fixed | Video |
| Gesture cancellation | Begin rotating, interrupt with another action or background | Angle doesn't jump; viewfinder remains usable | Video |
| Tap-to-focus isolation | Single tap immediately after two-finger rotation | Tap focuses; no unintended guide rotation | Video |
| Haptic feedback | Cross 0°, 90°, 180° and 270° | Subtle haptic at threshold, no continuous buzz | Device note |
| Guide persistence | Rotate two different guides, force-close and reopen | Each remembers its own free-rotation angle | Video |
| Fixed guides | Switch to Rule of Thirds, Custom Grid, Horizon | No free two-finger rotation of fixed grids | Video |
| Guide visibility | Hide and show overlay | Guides vanish/return; saved photo remains clean | Screenshot |
| Scene behavior | Rotate phone portrait/landscape | Guide and camera orientation remain correct | Images |
| Zoom | Change zoom and capture | Magnification updates; no freezes | Photos |
| Exposure | Change exposure bias | Live exposure changes on supported hardware | Video |
| Flash | Flash enabled/disabled; change front/rear camera | Accurate flash availability; no unsupported activation | Photos |
| Photos allow | Shoot in 4:3, 1:1, 16:9 | Photo saved with correct crop and orientation | Three images |
| Photos deny | Deny Add Photos and shoot | Clear error; second attempt remains usable | Screenshot |
| Shutter stability | Tap repeatedly while saving | No overlapping captures, app remains responsive | Video |
| Timers | Capture with 3 and 10 second timer | Exactly one photo at end of each countdown | Photo metadata |
| Timer interruption | Background app before timer finishes | Countdown cancelled; no hidden capture | Video |
| Interruptions | Incoming call, app switch, lock/unlock | Session recovers, no crash or black view | Device note |
| Accessibility | VoiceOver, large text, reduce motion | Usable controls and no clipped critical elements | Video |
| Device health | 20 minutes of continuous preview and rotation | No excessive heat, runaway memory or crashes | Instruments report |
| App review readiness | Verify public privacy/support links and real-device marketing screenshots | Accurate App Store Connect metadata | URL + checklist |

## Documentation and release decision

- The Simulator's landscape picture is synthetic and is **not** evidence of live iPhone camera performance.
- Browser tests are desktop/mobile emulations rather than physical Safari verification.
- XCUITest automation cannot confirm actual gyroscope behavior, haptics, flash, or the real Photos permission sheet; retain physical acceptance evidence.
- Don't mark a manual row *passed* without executing it.
- Review [APP_REVIEW_READINESS.md](APP_REVIEW_READINESS.md), [COMPOSITION_GUIDES_V2.md](COMPOSITION_GUIDES_V2.md), and [SCREENSHOT_CAPTURE.md](SCREENSHOT_CAPTURE.md).
