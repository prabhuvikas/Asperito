# Asperito — Six additional composition guides

The composition library now contains **18** guides (formerly 12). Six new guides render as native, vector-based SwiftUI Canvas overlays. No formulas, numbers, or scene-recognition claims appear on the camera guides.

| Guide | Camera effect | Controls |
| --- | --- | --- |
| Leading Lines | Two prominent converging gold guides and finer guides toward a focal marker | Focal horizontal/vertical position, rotate, mirror |
| Symmetry & Reflection | Gold symmetry axis and subtle equidistant reflection reference lines | Vertical/horizontal, axis position, spacing |
| Golden Triangle | Major gold diagonal with two supporting triangular divisions | Rotate, mirror |
| Frame Within Frame | Rounded inner photo-frame reference with subtle center markers | Size, horizontal/vertical offset, rotate |
| Negative Space | Subject circle and space-direction arrow | Subject position, space amount, direction |
| S-Curve | Smooth double Bézier flow guide | Bend, rotate, mirror |

Controls live in the existing **Guides** picker, and preferences persist through AppStorage. Six new offline tutorials are included.

All 18 guides are included in automated portrait/landscape geometry tests, and all six new guides have dedicated iPhone Simulator capture cases. The screenshot workflow outputs **23 PNGs**: 18 guide views plus onboarding, main camera, picker, tutorial, and settings.

**Simulator disclosure:** The camera previews use synthetic landscape imagery for repeatable automated inspection; they are genuine running-app UI captures, not photos captured with physical camera hardware. Test sensor-based features and Photos saving on a real iPhone before distribution.

## Gesture rotation (iOS camera)

Creative guides now support **two-finger rotation** on the real live camera preview.
One-finger tap-to-focus remains untouched, and the overlay never modifies a captured photo.

- Free rotation is available for Golden Spiral, Diagonal Guides, Perspective Lines, Leading Lines, Symmetry & Reflection, Golden Triangle, Frame Within Frame, Negative Space and S-Curve.
- Device-native `UIRotationGestureRecognizer` handles two touches on the existing `AVCaptureVideoPreviewLayer` wrapper. Single taps still use `UITapGestureRecognizer`.
- A temporary angle chip appears during rotation; subtle haptic ticks indicate right-angle alignment.
- Each composition's fine angle is saved separately in the on-device `overlay.gestureRotations` preference, and is restored when reselected.
- Fixed grids, horizon sensor and aspect-ratio masks do not rotate independently of the photo frame.
- SwiftUI Canvas applies the rotation to vector paths only. The preview, focus and saved photographs are not transformed.

Gesture behavior needs final testing with two fingers on a physical iPhone; GitHub's iPhone Simulator capture cannot verify multitouch feel.

## Native in-camera motion tutorial

The gesture demonstration now lives **inside the iPhone camera viewfinder**, not just on GitHub Pages:

- On first selection of an eligible, rotatable guide, Asperito presents a brief **Twist two fingers** coaching overlay.
- The *same* native vector composition overlay rotates between two demonstrated orientations while two translucent fingertip markers trace the motion; the camera feed remains fixed.
- **Replay** restarts the demonstration; **Try it** dismisses it and exposes the real two-finger camera gesture; **Gesture** beside the Learn action reopens it anytime.
- The first-use prompt is remembered in `education.rotationCoachSeen`. The demonstration does not alter the selected guide's saved angle or the saved photograph.
- Reduce Motion displays a still 35-degree example instead of continuous animation.
- UI tests launch the actual iOS camera fixture in `--asperito-screen=gesture` mode and exercise replay, dismiss and reopen.

This is an animated usage explanation in the real SwiftUI camera UI, not a GIF overlaid onto the final photograph, and not a substitute for physical-device multitouch QA.

## Cinematic Minimal camera redesign

The camera now uses the selected Option 1 layout: a quiet dark header, one compact composition selector rather than an always-visible horizontal list, a larger camera preview, and a slim lower control deck. The full 18-guide picker remains available through **Guides**. Shutter, front/rear switching, capture ratio, timer, exposure, and zoom remain available; the zoom slider opens from the compact zoom button. The native two-finger gesture coach retains Replay, Try it, and Close, but now uses a minimal translucent banner over the viewfinder rather than a large opaque instructional panel. Controls remain at least 44 points across their primary hit targets, with accessibility labels and existing UI tests retained. No photo-rendering pipeline is changed.
