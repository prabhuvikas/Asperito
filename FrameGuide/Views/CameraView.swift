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
    @AppStorage("camera.timer") private var timerSeconds = 0
    @AppStorage("onboarding.complete") private var onboardingComplete = false

    @State private var showingPicker = false
    @State private var showingOnboarding = false
    @State private var showingPhotoPreview = false
    @State private var showingLesson = false
    @State private var showingSettings = false
    @State private var showingExposure = false
    @State private var secondsRemaining = 0
    @State private var countdownTask: Task<Void, Never>?

    private var selectedKind: OverlayKind { OverlayKind(rawValue:overlayRaw) ?? .thirds }
    private var selectedColor: GuideColor { GuideColor(rawValue:colorRaw) ?? .white }
    private var selectedAspect: CaptureAspect { CaptureAspect(rawValue:aspectRaw) ?? .fourThree }
    private var guideSettings: GuideSettings {
        GuideSettings(customRows:rows,customColumns:columns,eyeLinePosition:eyeLine,
                      perspectivePoint:CGPoint(x:perspectiveX,y:perspectiveY),
                      spiralTurns:spiralTurns,spiralMirrored:spiralMirrored,
                      safeAreaRatio:safeRatio,cinematicRatio:cinemaRatio)
    }

    var body: some View {
        GeometryReader { root in
            let landscape = root.size.width > root.size.height
            let ratio = landscape ? 1 / selectedAspect.portraitRatio : selectedAspect.portraitRatio
            VStack(spacing:12) {
                topBar
                GeometryReader { area in
                    let fit = fittedSize(in:area.size,aspect:ratio)
                    ZStack {
                        CameraPreview(session:camera.session,onFocus:{ camera.focus(at:$0) })
                        if isGuideVisible {
                            OverlayCanvas(kind:selectedKind,color:selectedColor.color,opacity:opacity,settings:guideSettings,levelRoll:motion.roll)
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
                                Text("Enable camera access in iPhone Settings to use FrameGuide.")
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
                    .clipShape(RoundedRectangle(cornerRadius:14))
                    .position(x:area.size.width/2,y:area.size.height/2)
                }
                VStack(spacing:10) {
                    HStack(spacing:8) {
                        Image(systemName:selectedKind.symbol).foregroundStyle(.yellow)
                        Text(selectedKind.title).font(.subheadline.weight(.semibold))
                        Spacer()
                        Button { showingLesson = true } label: { Label("Learn",systemImage:"book.closed") }
                            .font(.caption.weight(.medium)).tint(.yellow)
                    }
                    .padding(.horizontal,8)
                    ScrollView(.horizontal,showsIndicators:false) {
                        HStack(spacing:8) {
                            ForEach(OverlayKind.allCases) { kind in
                                Button {
                                    overlayRaw = kind.rawValue
                                    UISelectionFeedbackGenerator().selectionChanged()
                                } label: {
                                    Text(kind.title)
                                        .font(.caption.weight(kind == selectedKind ? .bold : .medium))
                                        .padding(.horizontal,12).padding(.vertical,9)
                                        .background(kind == selectedKind ? Color.yellow : Color.white.opacity(0.12),in:Capsule())
                                        .foregroundStyle(kind == selectedKind ? .black : .white)
                                }
                                .accessibilityLabel("Select \(kind.title) overlay")
                            }
                        }
                    }
                    controlBar
                }
            }
            .padding(.horizontal,12)
            .padding(.vertical,8)
        }
        .background(Color(red:0.055,green:0.063,blue:0.075).ignoresSafeArea())
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
            if onboardingComplete { camera.start() }
            else { showingOnboarding = true }
            refreshMotion()
        }
        .onDisappear { camera.stop(); motion.stop(); countdownTask?.cancel() }
        .onChange(of:scenePhase) { _,new in
            if new == .active { if onboardingComplete { camera.start() }; refreshMotion() }
            else { camera.stop(); motion.stop(); countdownTask?.cancel(); secondsRemaining = 0 }
        }
        .onChange(of:overlayRaw) { _,_ in refreshMotion() }
    }

    private var topBar: some View {
        HStack {
            Button { showingSettings = true } label: { Image(systemName:"gearshape") }
                .accessibilityLabel("Settings")
            Spacer()
            Text("FRAMEGUIDE").font(.system(.subheadline,design:.rounded,weight:.heavy)).tracking(2)
            Spacer()
            Button { isGuideVisible.toggle() } label: {
                Image(systemName:isGuideVisible ? "eye" : "eye.slash")
            }.accessibilityLabel(isGuideVisible ? "Hide overlay" : "Show overlay")
            Button { camera.flashEnabled.toggle() } label: {
                Image(systemName:camera.flashEnabled ? "bolt.fill" : "bolt.slash")
            }.disabled(!camera.flashAvailable)
                .accessibilityLabel(camera.flashEnabled ? "Flash on" : "Flash off")
        }
        .font(.title3)
        .buttonStyle(.plain)
        .frame(height:38)
    }

    private var controlBar: some View {
        VStack(spacing:10) {
            HStack {
                Menu {
                    ForEach(CaptureAspect.allCases) { aspect in
                        Button(aspect.rawValue) { aspectRaw = aspect.rawValue }
                    }
                } label: { Label(selectedAspect.rawValue,systemImage:"aspectratio") }
                Spacer()
                Menu {
                    ForEach([0,3,10],id:\.self) { seconds in
                        Button(seconds == 0 ? "Off" : "\(seconds) seconds") { timerSeconds = seconds }
                    }
                } label: { Label(timerSeconds == 0 ? "Timer" : "\(timerSeconds)s",systemImage:"timer") }
                Spacer()
                Button { showingPicker = true } label: { Label("Guides",systemImage:"square.grid.3x3") }
                Spacer()
                Button { showingExposure.toggle() } label: { Image(systemName:"plusminus.circle") }
                    .accessibilityLabel("Exposure adjustment")
            }
            .font(.caption.weight(.medium))
            .tint(.white)
            .padding(.horizontal,8)
            if showingExposure {
                HStack {
                    Image(systemName:"sun.min")
                    Slider(value:Binding(get:{ Double(camera.exposureBias) },set:{ camera.setExposure(Float($0)) }),in:-2...2,step:0.25)
                        .tint(.yellow)
                    Image(systemName:"sun.max")
                }.padding(.horizontal,12)
            }
            HStack(spacing:16) {
                Text("\(camera.zoomFactor, specifier:"%.1f")×")
                    .font(.caption.monospacedDigit()).frame(width:38)
                Slider(value:Binding(get:{ Double(camera.zoomFactor) },set:{ camera.setZoom(CGFloat($0)) }),in:1...5)
                    .tint(.yellow)
                Button { camera.flipCamera() } label: {
                    Image(systemName:"arrow.triangle.2.circlepath.camera")
                        .font(.title3).frame(width:40,height:40)
                }.accessibilityLabel("Switch camera")
            }
            HStack(alignment:.center) {
                Button { showingPhotoPreview = camera.lastThumbnail != nil } label: {
                    Group {
                        if let image = camera.lastThumbnail {
                            Image(uiImage:image).resizable().scaledToFill()
                                .frame(width:44,height:44).clipShape(RoundedRectangle(cornerRadius:9))
                        } else {
                            Image(systemName:"photo").frame(width:44,height:44)
                                .background(.white.opacity(0.1),in:RoundedRectangle(cornerRadius:9))
                        }
                    }.frame(width:44,height:44)
                }
                .disabled(camera.lastThumbnail == nil)
                .accessibilityLabel("Preview last captured photo")
                .frame(maxWidth:.infinity,alignment:.leading)
                Button(action:shutter) {
                    Circle().fill(.white).frame(width:60,height:60)
                        .padding(5).overlay(Circle().stroke(.white,lineWidth:3))
                }
                .disabled(!camera.isRunning || camera.isSaving || secondsRemaining > 0 || camera.permissionDenied)
                .accessibilityLabel("Take photo")
                Group {
                    if camera.isSaving { ProgressView().tint(.white) }
                    else if camera.savedMessage != nil { Image(systemName:"checkmark.circle.fill").foregroundStyle(.green) }
                    else { Image(systemName:"camera") }
                }.frame(maxWidth:.infinity,alignment:.trailing)
            }
            if let saved = camera.savedMessage { Text(saved).font(.caption).foregroundStyle(.green) }
        }
    }

    private var pickerSheet: some View {
        OverlayPickerView(selected:Binding(get:{selectedKind},set:{overlayRaw=$0.rawValue}),
                          rows:$rows,columns:$columns,spiralTurns:$spiralTurns,
                          spiralMirrored:$spiralMirrored,eyeLine:$eyeLine,
                          perspectiveX:$perspectiveX,perspectiveY:$perspectiveY,
                          safeRatio:$safeRatio,cinemaRatio:$cinemaRatio,
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
