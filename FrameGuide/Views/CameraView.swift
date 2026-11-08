import SwiftUI
import UIKit

struct CameraView: View {
    @StateObject private var camera = CameraManager()
    @StateObject private var motion = HorizonLevelManager()
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("overlay.kind") private var overlayRaw = OverlayKind.thirds.rawValue
    @AppStorage("overlay.color") private var colorRaw = GuideColor.white.rawValue
    @AppStorage("overlay.opacity") private var opacity = 0.82
    @AppStorage("camera.aspect") private var aspectRaw = CaptureAspect.fourThree.rawValue
    @AppStorage("overlay.visible") private var isGuideVisible = true
    @AppStorage("overlay.customRows") private var rows = 4
    @AppStorage("overlay.customColumns") private var columns = 4
    @AppStorage("overlay.spiralTurns") private var spiralTurns = 0
    @AppStorage("overlay.spiralMirrored") private var spiralMirrored = false
    @AppStorage("overlay.eyeLine") private var eyeLine = 0.38
    @AppStorage("overlay.perspectiveX") private var perspectiveX = 0.5
    @AppStorage("overlay.perspectiveY") private var perspectiveY = 0.38
    @AppStorage("overlay.safeRatio") private var safeRatio = 0.8
    @AppStorage("overlay.cinemaRatio") private var cinemaRatio = 2.39
    @AppStorage("overlay.focusX") private var focusX = 0.5
    @AppStorage("overlay.focusY") private var focusY = 0.5
    @AppStorage("overlay.guideRotation") private var guideRotation = 0
    @AppStorage("overlay.guideMirrored") private var guideMirrored = false
    @AppStorage("overlay.guideScale") private var guideScale = 0.7
    @AppStorage("overlay.reflectionHorizontal") private var reflectionHorizontal = false
    @AppStorage("overlay.curveBend") private var curveBend = 0.5
    @AppStorage("overlay.gestureRotations") private var gestureRotationsJSON = "{}"
    @AppStorage("education.rotationCoachSeen") private var rotationCoachSeen = false
    @AppStorage("camera.timer") private var timerSeconds = 0
    @AppStorage("onboarding.complete") private var onboardingComplete = false

    @State private var showingPicker = false
    @State private var showingOnboarding = false
    @State private var showingPhotoPreview = false
    @State private var showingLesson = false
    @State private var showingSettings = false
    @State private var showingExposure = false
    @State private var showingZoom = false
    @State private var secondsRemaining = 0
    @State private var countdownTask: Task<Void, Never>?
    @State private var rotationGestureDelta = 0.0
    @State private var rotatingGuide = false
    @State private var lastHapticQuarter: Int?
    @State private var showingRotationCoach = false
    @State private var rotationCoachReplay = 0

    private var selectedKind: OverlayKind {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--asperito-screen=gesture") {
            return .goldenSpiral
        }
        if let raw = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--asperito-screen=overlay-") })?.replacingOccurrences(of: "--asperito-screen=overlay-", with: ""),
           let kind = OverlayKind(rawValue: raw) { return kind }
        #endif
        return OverlayKind(rawValue: overlayRaw) ?? .thirds
    }
    private var selectedColor: GuideColor { GuideColor(rawValue:colorRaw) ?? .white }
    private var selectedAspect: CaptureAspect { CaptureAspect(rawValue:aspectRaw) ?? .fourThree }
    private func savedRotation(for kind: OverlayKind) -> Double {
        GuideRotationStore.read(gestureRotationsJSON)[kind.rawValue] ?? 0
    }
    private var currentRotation: Double {
        savedRotation(for:selectedKind) + (rotatingGuide ? rotationGestureDelta : 0)
    }
    private func handleRotation(_ degrees: Double, state: UIGestureRecognizer.State) {
        guard selectedKind.supportsGestureRotation, isGuideVisible,
              !camera.permissionDenied, !showingRotationCoach else { return }
        switch state {
        case .began, .changed:
            rotatingGuide = true
            rotationGestureDelta = degrees
            let total = currentRotation
            let quarter = Int((total/90).rounded())
            if abs(total - Double(quarter)*90) < 2.0 {
                if lastHapticQuarter != quarter {
                    UIImpactFeedbackGenerator(style:.light).impactOccurred()
                    lastHapticQuarter = quarter
                }
            } else {
                lastHapticQuarter = nil
            }
        case .ended:
            var allAngles = GuideRotationStore.read(gestureRotationsJSON)
            allAngles[selectedKind.rawValue] = GuideRotationStore.normalized(
                savedRotation(for:selectedKind) + degrees)
            gestureRotationsJSON = GuideRotationStore.write(allAngles)
            rotationGestureDelta = 0
            rotatingGuide = false
            lastHapticQuarter = nil
        case .cancelled, .failed:
            rotationGestureDelta = 0
            rotatingGuide = false
            lastHapticQuarter = nil
        default: break
        }
    }
    private var guideSettings: GuideSettings {
        GuideSettings(customRows:rows,customColumns:columns,eyeLinePosition:eyeLine,
                      perspectivePoint:CGPoint(x:perspectiveX,y:perspectiveY),
                      spiralTurns:spiralTurns,spiralMirrored:spiralMirrored,
                      safeAreaRatio:safeRatio,cinematicRatio:cinemaRatio,
                      focusPoint:CGPoint(x:focusX,y:focusY),
                      guideRotation:guideRotation,guideMirrored:guideMirrored,
                      guideScale:guideScale,reflectionHorizontal:reflectionHorizontal,
                      curveBend:curveBend)
    }

    var body: some View {
        GeometryReader { root in
            let landscape = root.size.width > root.size.height
            let ratio = landscape ? 1 / selectedAspect.portraitRatio : selectedAspect.portraitRatio
            VStack(spacing:6) {
                topBar
                GeometryReader { area in
                    let fit = fittedSize(in:area.size,aspect:ratio)
                    ZStack {
                        Group {
                            #if DEBUG
                            if ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("--asperito-screen=") }) {
                                ScreenshotScenePreview()
                            } else {
                                CameraPreview(session:camera.session,onFocus:{ camera.focus(at:$0) },
                                              onRotation:{ handleRotation($0,state:$1) })
                            }
                            #else
                            CameraPreview(session:camera.session,onFocus:{ camera.focus(at:$0) },
                                              onRotation:{ handleRotation($0,state:$1) })
                            #endif
                        }
                        if isGuideVisible && !showingRotationCoach {
                            OverlayCanvas(kind:selectedKind,color:selectedColor.color,opacity:opacity,
                                          settings:guideSettings,levelRoll:motion.roll,
                                          gestureRotationDegrees:currentRotation)
                        }
                        if showingRotationCoach && selectedKind.supportsGestureRotation && isGuideVisible {
                            RotationCoachView(kind:selectedKind,
                                              settings:guideSettings,
                                              baseRotation:savedRotation(for:selectedKind),
                                              replayID:rotationCoachReplay,
                                              onReplay:{ rotationCoachReplay += 1 },
                                              onDismiss:{ showingRotationCoach = false })
                        }
                        if rotatingGuide && selectedKind.supportsGestureRotation {
                            VStack {
                                HStack {
                                    Image(systemName:"rotate.3d")
                                    Text("\(Int(currentRotation.rounded()))°")
                                        .monospacedDigit()
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AsperitoPalette.gold)
                                .padding(.horizontal,14).padding(.vertical,8)
                                .background(AsperitoPalette.midnight.opacity(0.86),
                                            in:Capsule())
                                .padding(.top,12)
                                Spacer()
                            }
                            .allowsHitTesting(false)
                        }
                        if secondsRemaining > 0 {
                            Color.black.opacity(0.18)
                            Text("\(secondsRemaining)")
                                .font(.system(size:72,weight:.light,design:.rounded))
                                .shadow(radius:8)
                        }
                        if camera.permissionDenied {
                            VStack(spacing:14) {
                                Image(systemName:"camera.fill").font(.largeTitle)
                                Text("Camera access required").font(.headline)
                                Text("Enable camera access in iPhone Settings to use Asperito.")
                                    .font(.subheadline).multilineTextAlignment(.center)
                                Button("Open Settings") {
                                    if let url = URL(string:UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                                }.buttonStyle(.borderedProminent)
                            }
                            .padding(24)
                            .frame(maxWidth:.infinity,maxHeight:.infinity)
                            .background(.black.opacity(0.85))
                        }
                    }
                    .frame(width:fit.width,height:fit.height)
                    .background(.black)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius:9))
                    .position(x:area.size.width/2,y:area.size.height/2)
                }
                VStack(spacing:8) {
                    HStack(spacing:10) {
                        Button { showingPicker = true } label: {
                            HStack(spacing:8) {
                                Image(systemName:selectedKind.symbol)
                                    .foregroundStyle(AsperitoPalette.gold)
                                Text(selectedKind.title)
                                    .lineLimit(1)
                                    .font(.subheadline.weight(.semibold))
                                Image(systemName:"chevron.down")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(AsperitoPalette.mist)
                            }
                            .padding(.horizontal,13)
                            .frame(height:42)
                            .background(AsperitoPalette.graphite,in:Capsule())
                        }
                        .accessibilityLabel("Guides")
                        .accessibilityHint("Choose from eighteen composition guides")
                        Spacer(minLength:4)
                        if selectedKind.supportsGestureRotation {
                            Button {
                                isGuideVisible = true
                                rotationCoachSeen = true
                                showingRotationCoach = true
                                rotationCoachReplay += 1
                            } label: {
                                Image(systemName:"hand.draw")
                                    .frame(width:44,height:44)
                            }
                            .accessibilityLabel("Show rotation tutorial")
                            .accessibilityHint("Watch how to rotate this composition with two fingers")
                        }
                        Button { showingLesson = true } label: {
                            Image(systemName:"book.closed")
                                .frame(width:44,height:44)
                        }
                        .accessibilityLabel("Learn")
                    }
                    .foregroundStyle(AsperitoPalette.ivory)
                    .buttonStyle(.plain)
                    .padding(.horizontal,3)
                    controlBar
                }
            }
            .padding(.horizontal,9)
            .padding(.vertical,5)
        }
        .background(AsperitoPalette.midnight.ignoresSafeArea())
        .sheet(isPresented:$showingOnboarding) {
            OnboardingView {
                onboardingComplete = true
                showingOnboarding = false
                camera.start()
            }
                .interactiveDismissDisabled()
        }
        .sheet(isPresented:$showingPicker) { pickerSheet }
        .sheet(isPresented:$showingLesson) {
            TutorialView(kind:selectedKind) {
                isGuideVisible = true
                showingLesson = false
            }
        }
        .sheet(isPresented:$showingSettings) { settingsSheet }
        .fullScreenCover(isPresented:$showingPhotoPreview) {
            if let image = camera.lastThumbnail { CapturedPhotoView(image:image) }
        }
        .alert("Camera notice",isPresented:Binding(get:{ camera.errorMessage != nil },set:{ if !$0 { camera.errorMessage = nil } })) {
            Button("OK",role:.cancel) { camera.errorMessage = nil }
        } message: { Text(camera.errorMessage ?? "Unknown error") }
        .onAppear {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("--asperito-screen=") }) {
                onboardingComplete = true
            } else {
                if onboardingComplete { camera.start() }
                else { showingOnboarding = true }
            }
            #else
            if onboardingComplete { camera.start() }
            else { showingOnboarding = true }
            #endif
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--asperito-screen=gesture") {
                isGuideVisible = true
                showingRotationCoach = true
            }
            #endif
            refreshMotion()
        }
        .onDisappear {
            camera.stop(); motion.stop(); countdownTask?.cancel()
            rotationGestureDelta = 0
            rotatingGuide = false
            showingRotationCoach = false
        }
        .onChange(of:scenePhase) { _,new in
            if new == .active {
                #if DEBUG
                if !ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("--asperito-screen=") }) {
                    if onboardingComplete { camera.start() }
                }
                #else
                if onboardingComplete { camera.start() }
                #endif
                refreshMotion()
            }
            else { camera.stop(); motion.stop(); countdownTask?.cancel(); secondsRemaining = 0 }
        }
        .onChange(of:overlayRaw) { _,_ in
            showingRotationCoach = false
            if selectedKind.supportsGestureRotation && !rotationCoachSeen {
                #if DEBUG
                if !ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("--asperito-screen=") }) {
                    showingRotationCoach = true
                    rotationCoachSeen = true
                }
                #else
                showingRotationCoach = true
                rotationCoachSeen = true
                #endif
            }
            rotationGestureDelta = 0
            rotatingGuide = false
            lastHapticQuarter = nil
            refreshMotion()
        }
    }

    private var topBar: some View {
        HStack(spacing:6) {
            Button { showingSettings = true } label: {
                Image(systemName:"gearshape")
                    .frame(width:44,height:44)
            }
            .accessibilityLabel("Settings")
            Spacer(minLength:2)
            AsperitoWordmark()
            Spacer(minLength:2)
            Button { isGuideVisible.toggle() } label: {
                Image(systemName:isGuideVisible ? "eye" : "eye.slash")
                    .frame(width:44,height:44)
            }
            .accessibilityLabel(isGuideVisible ? "Hide overlay" : "Show overlay")
            Button { camera.flashEnabled.toggle() } label: {
                Image(systemName:camera.flashEnabled ? "bolt.fill" : "bolt.slash")
                    .frame(width:44,height:44)
            }
            .disabled(!camera.flashAvailable)
            .accessibilityLabel(camera.flashEnabled ? "Flash on" : "Flash off")
        }
        .font(.system(size:18,weight:.regular))
        .buttonStyle(.plain)
        .foregroundStyle(AsperitoPalette.ivory)
        .frame(height:46)
    }

    private var controlBar: some View {
        VStack(spacing:7) {
            HStack(spacing:2) {
                Menu {
                    ForEach(CaptureAspect.allCases) { aspect in
                        Button(aspect.rawValue) { aspectRaw = aspect.rawValue }
                    }
                } label: {
                    Label(selectedAspect.rawValue,systemImage:"aspectratio")
                        .frame(minWidth:60,minHeight:40)
                }
                .accessibilityLabel("Photo aspect ratio")
                Spacer(minLength:2)
                Menu {
                    ForEach([0,3,10],id:\.self) { seconds in
                        Button(seconds == 0 ? "Off" : "\(seconds) seconds") { timerSeconds = seconds }
                    }
                } label: {
                    Label(timerSeconds == 0 ? "Timer" : "\(timerSeconds)s",systemImage:"timer")
                        .frame(minWidth:58,minHeight:40)
                }
                Spacer(minLength:2)
                Button { showingZoom.toggle() } label: {
                    Text("\(camera.zoomFactor,specifier:"%.1f")×")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .frame(minWidth:50,minHeight:40)
                }
                .accessibilityLabel("Zoom controls")
                .accessibilityValue("\(camera.zoomFactor,specifier:"%.1f") times")
                Spacer(minLength:2)
                Button { showingExposure.toggle() } label: {
                    Image(systemName:"plusminus.circle")
                        .frame(width:44,height:44)
                }
                .accessibilityLabel("Exposure adjustment")
            }
            .font(.caption.weight(.medium))
            .tint(AsperitoPalette.ivory)
            .foregroundStyle(AsperitoPalette.ivory)
            if showingExposure {
                HStack(spacing:9) {
                    Image(systemName:"sun.min")
                    Slider(value:Binding(get:{ Double(camera.exposureBias) },
                                         set:{ camera.setExposure(Float($0)) }),
                           in:-2...2,step:0.25)
                        .tint(AsperitoPalette.gold)
                        .accessibilityLabel("Exposure")
                    Image(systemName:"sun.max")
                }
                .padding(.horizontal,13)
            }
            if showingZoom {
                HStack(spacing:10) {
                    Text("1×")
                    Slider(value:Binding(get:{ Double(camera.zoomFactor) },
                                         set:{ camera.setZoom(CGFloat($0)) }),in:1...5)
                        .tint(AsperitoPalette.gold)
                        .accessibilityLabel("Zoom")
                    Text("5×")
                }
                .font(.caption.monospacedDigit())
                .padding(.horizontal,13)
            }
            HStack(alignment:.center,spacing:12) {
                Button { showingPhotoPreview = camera.lastThumbnail != nil } label: {
                    Group {
                        if let image = camera.lastThumbnail {
                            Image(uiImage:image).resizable().scaledToFill()
                                .frame(width:42,height:42)
                                .clipShape(RoundedRectangle(cornerRadius:9))
                        } else {
                            Image(systemName:"photo")
                                .frame(width:42,height:42)
                                .background(.white.opacity(0.075),
                                            in:RoundedRectangle(cornerRadius:9))
                        }
                    }
                    .frame(width:44,height:44)
                }
                .disabled(camera.lastThumbnail == nil)
                .accessibilityLabel("Preview last captured photo")
                .frame(maxWidth:.infinity,alignment:.leading)
                Button(action:shutter) {
                    Circle().fill(.white)
                        .frame(width:59,height:59)
                        .padding(5)
                        .overlay(Circle().stroke(.white,lineWidth:2.5))
                }
                .disabled(!camera.isRunning || camera.isSaving ||
                          secondsRemaining > 0 || camera.permissionDenied)
                .accessibilityLabel("Take photo")
                Button { camera.flipCamera() } label: {
                    Image(systemName:"arrow.triangle.2.circlepath.camera")
                        .font(.title3)
                        .frame(width:44,height:44)
                }
                .accessibilityLabel("Switch camera")
                .frame(maxWidth:.infinity,alignment:.trailing)
            }
            .padding(.horizontal,12)
            if camera.isSaving {
                ProgressView().tint(AsperitoPalette.gold)
                    .accessibilityLabel("Saving photo")
            } else if let saved = camera.savedMessage {
                Text(saved).font(.caption).foregroundStyle(AsperitoPalette.gold)
            }
        }
        .foregroundStyle(AsperitoPalette.ivory)
        .padding(.vertical,8)
        .padding(.horizontal,8)
        .background(AsperitoPalette.graphite.opacity(0.78),
                    in:RoundedRectangle(cornerRadius:18))
    }

    private var pickerSheet: some View {
        OverlayPickerView(selected:Binding(get:{selectedKind},set:{overlayRaw=$0.rawValue}),
                          rows:$rows,columns:$columns,spiralTurns:$spiralTurns,
                          spiralMirrored:$spiralMirrored,eyeLine:$eyeLine,
                          perspectiveX:$perspectiveX,perspectiveY:$perspectiveY,
                          safeRatio:$safeRatio,cinemaRatio:$cinemaRatio,
                          focusX:$focusX,focusY:$focusY,guideRotation:$guideRotation,
                          guideMirrored:$guideMirrored,guideScale:$guideScale,
                          reflectionHorizontal:$reflectionHorizontal,curveBend:$curveBend,
                          onLearn:{ showingPicker = false; DispatchQueue.main.asyncAfter(deadline:.now()+0.35) { showingLesson = true } })
            .presentationDetents([.medium,.large])
    }
    private var settingsSheet: some View {
        SettingsView(colorRaw:$colorRaw,opacity:$opacity,visible:$isGuideVisible,timerSeconds:$timerSeconds)
            .presentationDetents([.medium,.large])
    }
    private func refreshMotion() {
        if selectedKind == .horizon && scenePhase == .active { motion.start() }
        else { motion.stop() }
    }
    private func takePhoto() {
        let orientation = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.interfaceOrientation }.first ?? .portrait
        camera.capture(aspect:selectedAspect,orientation:orientation)
    }
    private func shutter() {
        UIImpactFeedbackGenerator(style:.medium).impactOccurred()
        guard timerSeconds > 0 else { takePhoto(); return }
        countdownTask?.cancel()
        countdownTask = Task { @MainActor in
            for n in stride(from:timerSeconds,through:1,by:-1) {
                secondsRemaining = n
                try? await Task.sleep(for:.seconds(1))
                if Task.isCancelled { secondsRemaining = 0; return }
            }
            secondsRemaining = 0
            takePhoto()
        }
    }
    private func fittedSize(in available: CGSize, aspect: CGFloat) -> CGSize {
        guard available.width > 0, available.height > 0 else { return .zero }
        if available.width / available.height > aspect { return CGSize(width:available.height*aspect,height:available.height) }
        return CGSize(width:available.width,height:available.width/aspect)
    }
}


/// Camera-local, first-use gesture coaching: the *actual vector composition
/// guide* animates while the AVCaptureVideoPreviewLayer stays stationary.
/// It is an instructional animation, not a stored rotation or photo effect.
private struct RotationCoachView: View {
    let kind: OverlayKind
    let settings: GuideSettings
    let baseRotation: Double
    let replayID: Int
    let onReplay: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            RotationCoachMotion(kind:kind,settings:settings,baseRotation:baseRotation)
                .id(replayID)
                .allowsHitTesting(false)

            VStack(spacing:10) {
                HStack(spacing:10) {
                    Image(systemName:"hand.draw")
                        .font(.title3)
                        .foregroundStyle(AsperitoPalette.gold)
                    VStack(alignment:.leading,spacing:3) {
                        Text("TWIST TWO FINGERS")
                            .font(.caption.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(AsperitoPalette.gold)
                        Text("Rotate the guide. Not the photo.")
                            .font(.caption)
                            .foregroundStyle(AsperitoPalette.ivory)
                    }
                    Spacer(minLength:0)
                    Button(action:onDismiss) {
                        Image(systemName:"xmark")
                            .font(.caption.weight(.semibold))
                            .frame(width:36,height:36)
                    }
                    .accessibilityLabel("Close rotation tutorial")
                    .tint(.white)
                }
                .padding(12)
                .background(AsperitoPalette.midnight.opacity(0.88),
                            in:RoundedRectangle(cornerRadius:15))
                .padding(.horizontal,12)
                .padding(.top,12)
                Spacer(minLength:0)
                HStack(spacing:10) {
                    Button(action:onReplay) {
                        Label("Replay",systemImage:"arrow.counterclockwise")
                            .frame(maxWidth:.infinity,minHeight:44)
                    }
                    .accessibilityLabel("Replay gesture animation")
                    .foregroundStyle(AsperitoPalette.ivory)
                    .background(AsperitoPalette.midnight.opacity(0.88),
                                in:Capsule())
                    Button(action:onDismiss) {
                        Label("Try it",systemImage:"checkmark")
                            .fontWeight(.semibold)
                            .frame(maxWidth:.infinity,minHeight:44)
                    }
                    .accessibilityLabel("Try rotation gesture")
                    .foregroundStyle(AsperitoPalette.midnight)
                    .background(AsperitoPalette.gold,in:Capsule())
                }
                .font(.subheadline)
                .padding(.horizontal,18)
                .padding(.bottom,12)
            }
        }
        .accessibilityIdentifier("rotation-coach")
    }
}

private struct RotationCoachMotion: View {
    let kind: OverlayKind
    let settings: GuideSettings
    let baseRotation: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var exampleDegrees = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // The same Canvas used by the live camera: only the guide moves.
                OverlayCanvas(kind:kind,color:AsperitoPalette.gold,opacity:0.94,
                              settings:settings,
                              gestureRotationDegrees:baseRotation + exampleDegrees)
                HStack(spacing:48) {
                    fingertip
                    fingertip
                }
                .rotationEffect(.degrees(exampleDegrees))
                .position(x:geometry.size.width*0.5,y:geometry.size.height*0.48)
                .shadow(color:.black.opacity(0.3),radius:7)
            }
            .frame(width:geometry.size.width,height:geometry.size.height)
        }
        .onAppear {
            exampleDegrees = reduceMotion ? 35 : 0
            if !reduceMotion {
                withAnimation(.easeInOut(duration:2.25).repeatForever(autoreverses:true)) {
                    exampleDegrees = 55
                }
            }
        }
    }

    private var fingertip: some View {
        Circle()
            .fill(AsperitoPalette.gold.opacity(0.45))
            .frame(width:27,height:27)
            .overlay {
                Circle().stroke(.white.opacity(0.9),lineWidth:2)
                    .padding(-5)
            }
    }
}
