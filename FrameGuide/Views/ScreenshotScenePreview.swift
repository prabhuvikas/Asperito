import SwiftUI

// Debug-only deterministic simulated landscape (not an actual camera image).
// The real camera controls and OverlayCanvas remain unchanged.
#if DEBUG
struct ScreenshotScenePreview: View {
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                LinearGradient(colors: [
                    Color(red:0.14,green:0.25,blue:0.35),
                    Color(red:0.40,green:0.48,blue:0.49),
                    Color(red:0.76,green:0.57,blue:0.43)
                ], startPoint:.top,endPoint:.bottom)
                Circle().fill(Color(red:0.98,green:0.83,blue:0.58))
                    .frame(width:w*0.18,height:w*0.18)
                    .position(x:w*0.72,y:h*0.30)
                Path { p in
                    p.move(to:CGPoint(x:0,y:h*0.7))
                    p.addLine(to:CGPoint(x:w*0.26,y:h*0.46))
                    p.addLine(to:CGPoint(x:w*0.48,y:h*0.65))
                    p.addLine(to:CGPoint(x:w*0.72,y:h*0.50))
                    p.addLine(to:CGPoint(x:w,y:h*0.72))
                    p.addLine(to:CGPoint(x:w,y:h))
                    p.addLine(to:CGPoint(x:0,y:h))
                }.fill(Color(red:0.19,green:0.32,blue:0.36))
                Path { p in
                    p.move(to:CGPoint(x:0,y:h*0.84))
                    p.addLine(to:CGPoint(x:w*0.32,y:h*0.68))
                    p.addLine(to:CGPoint(x:w*0.62,y:h*0.80))
                    p.addLine(to:CGPoint(x:w*0.82,y:h*0.69))
                    p.addLine(to:CGPoint(x:w,y:h*0.79))
                    p.addLine(to:CGPoint(x:w,y:h))
                    p.addLine(to:CGPoint(x:0,y:h))
                }.fill(Color(red:0.08,green:0.18,blue:0.23))
            }.clipped()
        }
        .accessibilityLabel("Simulator landscape fixture — not a live camera")
    }
}
#endif
