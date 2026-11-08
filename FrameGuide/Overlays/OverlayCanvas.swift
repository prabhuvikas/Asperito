import SwiftUI

struct OverlayCanvas: View {
    let kind: OverlayKind
    var color: Color = .white
    var opacity: Double = 0.8
    var settings: GuideSettings = .init()
    var levelRoll: Double = 0

    var body: some View {
        Canvas(rendersAsynchronously: true) { context, size in
            let bounds = CGRect(origin: .zero, size: size)
            if kind == .safeArea || kind == .cinematic {
                let ratio = kind == .safeArea ? settings.safeAreaRatio : settings.cinematicRatio
                let target = OverlayGeometry.framingRect(inside: bounds, targetAspect: ratio)
                let masks = [
                    CGRect(x:0,y:0,width:size.width,height:target.minY),
                    CGRect(x:0,y:target.maxY,width:size.width,height:max(0,size.height-target.maxY)),
                    CGRect(x:0,y:target.minY,width:target.minX,height:target.height),
                    CGRect(x:target.maxX,y:target.minY,width:max(0,size.width-target.maxX),height:target.height)
                ]
                masks.forEach { if !$0.isEmpty { context.fill(Path($0),with:.color(.black.opacity(0.5))) } }
            }
            if kind == .horizon {
                var rotated = context
                rotated.translateBy(x:size.width/2,y:size.height/2)
                rotated.rotate(by:.radians(-levelRoll))
                let measured = Path { path in
                    path.move(to:CGPoint(x:-size.width/3,y:0)); path.addLine(to:CGPoint(x:size.width/3,y:0))
                }
                rotated.stroke(measured,with:.color(abs(levelRoll)<0.04 ? .green : color),lineWidth:2)
                let fixed = Path { p in p.move(to:CGPoint(x:size.width/2-15,y:size.height/2)); p.addLine(to:CGPoint(x:size.width/2+15,y:size.height/2)) }
                context.stroke(fixed,with:.color(.white),lineWidth:2)
                return
            }
            if kind == .goldenSpiral {
                for guide in OverlayGeometry.lines(for: kind, in: bounds, settings: settings) {
                    let ink = guide.accent ? AsperitoPalette.gold : Color.white
                    let alpha = guide.accent ? opacity : opacity * (guide.dashed ? 0.25 : 0.45)
                    let lineWidth: CGFloat = guide.accent ? 2.8 : 0.85
                    let style = StrokeStyle(lineWidth: lineWidth,
                                            lineCap: .round,
                                            lineJoin: .round,
                                            dash: guide.dashed ? [3, 5] : [])
                    context.stroke(guide.path, with: .color(ink.opacity(alpha)), style: style)
                }
                return
            }
            for guide in OverlayGeometry.lines(for:kind,in:bounds,settings:settings) {
                let stroke = StrokeStyle(lineWidth:guide.accent ? 1.8 : 1, dash:guide.dashed ? [7,5] : [])
                context.stroke(guide.path, with:.color(color.opacity(opacity)), style:stroke)
            }
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}
