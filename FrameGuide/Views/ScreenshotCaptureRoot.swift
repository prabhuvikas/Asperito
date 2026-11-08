import SwiftUI

// Debug-only screenshot harness. These are real application SwiftUI screens,
// rendered by the iPhone Simulator and captured using simctl io screenshot.
// No generated mockup or rendered screenshot assets are involved.
#if DEBUG
struct ScreenshotCaptureRoot: View {
    let screen: String
    @State private var kind: OverlayKind = .goldenSpiral
    @State private var rows = 4
    @State private var columns = 4
    @State private var turns = 0
    @State private var mirror = false
    @State private var eyeLine = 0.38
    @State private var perspectiveX = 0.5
    @State private var perspectiveY = 0.38
    @State private var safeRatio = 0.8
    @State private var cinemaRatio = 2.39
    @State private var focusX = 0.5
    @State private var focusY = 0.5
    @State private var guideRotation = 0
    @State private var guideMirrored = false
    @State private var guideScale = 0.7
    @State private var reflectionHorizontal = false
    @State private var curveBend = 0.5
    @State private var colorRaw = GuideColor.white.rawValue
    @State private var opacity = 0.82
    @State private var visible = true
    @State private var timer = 0

    var body: some View {
        switch screen {
        case "onboarding":
            OnboardingView(onContinue: {})
        case "picker":
            OverlayPickerView(selected: $kind, rows: $rows, columns: $columns,
                              spiralTurns: $turns, spiralMirrored: $mirror,
                              eyeLine: $eyeLine, perspectiveX: $perspectiveX,
                              perspectiveY: $perspectiveY, safeRatio: $safeRatio,
                              cinemaRatio: $cinemaRatio, focusX:$focusX,focusY:$focusY,
                              guideRotation:$guideRotation,guideMirrored:$guideMirrored,
                              guideScale:$guideScale,reflectionHorizontal:$reflectionHorizontal,
                              curveBend:$curveBend,onLearn: {})
        case "tutorial":
            TutorialView(kind: .goldenSpiral, onApply: {})
        case "settings":
            SettingsView(colorRaw: $colorRaw, opacity: $opacity,
                         visible: $visible, timerSeconds: $timer)
        default:
            CameraView()
        }
    }
}
#endif
