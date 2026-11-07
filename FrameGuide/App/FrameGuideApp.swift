import SwiftUI

@main
struct FrameGuideApp: App {
    var body: some Scene {
        WindowGroup {
            CameraView()
                .preferredColorScheme(.dark)
        }
    }
}
