import SwiftUI

@main
struct FrameGuideApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if let screen = ProcessInfo.processInfo.arguments
                .first(where: { $0.hasPrefix("--asperito-screen=") })?
                .split(separator: "=").last.map(String.init) {
                ScreenshotCaptureRoot(screen: screen)
                    .tint(AsperitoPalette.gold)
            } else {
                CameraView().tint(AsperitoPalette.gold)
            }
            #else
            CameraView().tint(AsperitoPalette.gold)
            #endif
        }
    }
}
