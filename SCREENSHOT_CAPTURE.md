# Asperito screenshot capture pack

The iOS Actual Screenshots GitHub Action builds the real app in Debug on an iPhone Simulator and saves 23 original PNGs as a downloadable artifact.

**Camera limitation:** The Simulator has no live camera. Camera and overlay screenshots display a deterministic *simulator landscape fixture* beneath the actual SwiftUI camera UI and real vector guide rendering. These are UI inspection screenshots, not photographs and not evidence of the real camera hardware working.

## Capture checklist

| File | What it shows |
|---|---|
| onboarding.png | Director-inspired onboarding, brand and call to action |
| camera.png | Camera interface / default Rule of Thirds |
| picker.png | 18-guide selection library |
| tutorial.png | Golden Spiral tutorial |
| settings.png | Overlay color and camera controls |
| overlay-thirds.png | Rule of Thirds |
| overlay-goldenGrid.png | Golden Ratio grid |
| overlay-goldenSpiral.png | Golden Spiral |
| overlay-center.png | Center Cross |
| overlay-diagonal.png | Diagonal Guides |
| overlay-square.png | Square Grid |
| overlay-horizon.png | Horizon Level; device motion does not reflect a real phone |
| overlay-eyeLine.png | Portrait Eye Line |
| overlay-safeArea.png | Social Safe Area |
| overlay-perspective.png | Perspective Lines |
| overlay-cinematic.png | Cinematic Frame |
| overlay-custom.png | Custom Grid |
| overlay-leadingLines.png | Leading Lines |
| overlay-reflection.png | Symmetry & Reflection |
| overlay-goldenTriangle.png | Golden Triangle |
| overlay-frameWithinFrame.png | Frame Within Frame |
| overlay-negativeSpace.png | Negative Space |
| overlay-sCurve.png | S-Curve |

## Suggested App Store story order (only after true-device photography tests)
1. Frame better photos — Rule of Thirds
2. Find natural balance — Golden Ratio
3. Make the eye travel — Golden Spiral
4. Keep horizons straight — Horizon Level
5. Design your own grid — Custom Grid
6. Learn while shooting — Tutorial

The screenshot workflow runs on relevant pull requests or manually via Actions. GitHub artifacts have a limited retention period; download the ZIP for long-term reference.
