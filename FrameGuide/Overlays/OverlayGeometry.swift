import SwiftUI

struct GuideStroke {
    let path: Path
    var accent = false
    var dashed = false
}

enum OverlayGeometry {
    private static let phi = (1 + sqrt(5.0)) / 2

    static func lines(for kind: OverlayKind, in rect: CGRect, settings: GuideSettings = .init()) -> [GuideStroke] {
        let w = rect.width, h = rect.height
        guard w > 0 && h > 0 else { return [] }
        func line(_ a: CGPoint, _ b: CGPoint, accent: Bool = false, dashed: Bool = false) -> GuideStroke {
            var p = Path(); p.move(to: a); p.addLine(to: b)
            return GuideStroke(path: p, accent: accent, dashed: dashed)
        }
        func v(_ x: CGFloat) -> GuideStroke { line(CGPoint(x: rect.minX + w * x, y: rect.minY), CGPoint(x: rect.minX + w * x, y: rect.maxY)) }
        func horizontal(_ y: CGFloat) -> GuideStroke { line(CGPoint(x: rect.minX, y: rect.minY + h * y), CGPoint(x: rect.maxX, y: rect.minY + h * y)) }
        switch kind {
        case .thirds:
            return [v(1.0 / 3), v(2.0 / 3), horizontal(1.0 / 3), horizontal(2.0 / 3)]
        case .goldenGrid:
            let a = (3 - sqrt(5.0)) / 2
            return [v(a), v(1-a), horizontal(a), horizontal(1-a)]
        case .goldenSpiral:
            // True logarithmic golden spiral: radius changes by phi per quarter-turn.
            // Rotate/mirror in normalized coordinates so all device aspect ratios are supported.
            let center = CGPoint(x: 0.618, y: 0.382)
            let turns = CGFloat(((settings.spiralTurns % 4) + 4) % 4) * .pi / 2
            var path = Path()
            for step in 0...420 {
                let theta = CGFloat(step) / 420 * 5 * .pi
                let r = 0.77 * pow(phi, -Double(theta / (.pi / 2)))
                let originalX = CGFloat(r) * cos(theta)
                let originalY = CGFloat(r) * sin(theta)
                let x = settings.spiralMirrored ? -originalX : originalX
                let nx = center.x + x * cos(turns) - originalY * sin(turns)
                let ny = center.y + x * sin(turns) + originalY * cos(turns)
                let p = CGPoint(x: rect.minX + nx * w, y: rect.minY + ny * h)
                if step == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            return [GuideStroke(path: path, accent: true)]
        case .center:
            let c = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(w, h) * 0.045
            return [v(0.5), horizontal(0.5), GuideStroke(path: Path(ellipseIn: CGRect(x: c.x-radius, y: c.y-radius, width: radius*2, height: radius*2)), accent: true)]
        case .diagonal:
            let topLeft = CGPoint(x: rect.minX, y: rect.minY), topRight = CGPoint(x: rect.maxX, y: rect.minY)
            let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY), bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
            return [line(topLeft, bottomRight), line(topRight, bottomLeft), line(CGPoint(x: rect.midX,y:rect.minY), CGPoint(x:rect.minX,y:rect.midY),dashed:true), line(CGPoint(x:rect.midX,y:rect.minY),CGPoint(x:rect.maxX,y:rect.midY),dashed:true)]
        case .square:
            return (1..<5).map { v(CGFloat($0)/5) } + (1..<5).map { horizontal(CGFloat($0)/5) }
        case .horizon:
            return [horizontal(0.5), line(CGPoint(x: rect.midX, y: rect.midY-18), CGPoint(x: rect.midX, y: rect.midY+18), accent: true)]
        case .eyeLine:
            return [horizontal(min(0.95, max(0.05, settings.eyeLinePosition)))]
        case .safeArea, .cinematic:
            let ratio = kind == .safeArea ? settings.safeAreaRatio : settings.cinematicRatio
            return [GuideStroke(path: Path(framingRect(inside: rect, targetAspect: ratio)), accent: true)]
        case .perspective:
            let x = rect.minX + w * min(1,max(0,settings.perspectivePoint.x))
            let y = rect.minY + h * min(1,max(0,settings.perspectivePoint.y))
            let vanishing = CGPoint(x:x,y:y)
            let targets = [CGPoint(x:rect.minX,y:rect.minY), CGPoint(x:rect.maxX,y:rect.minY), CGPoint(x:rect.minX,y:rect.maxY), CGPoint(x:rect.maxX,y:rect.maxY), CGPoint(x:rect.midX,y:rect.minY), CGPoint(x:rect.midX,y:rect.maxY)]
            return targets.map { line(vanishing, $0, dashed:true) } + [GuideStroke(path:Path(ellipseIn:CGRect(x:x-4,y:y-4,width:8,height:8)),accent:true)]
        case .custom:
            let cols = max(2,min(10,settings.customColumns)), rows = max(2,min(10,settings.customRows))
            return (1..<cols).map { v(CGFloat($0)/CGFloat(cols)) } + (1..<rows).map { horizontal(CGFloat($0)/CGFloat(rows)) }
        }
    }

    // Aspect ratios are specified width/height in the *displayed* orientation.
    static func framingRect(inside bounds: CGRect, targetAspect: CGFloat) -> CGRect {
        guard bounds.width > 0, bounds.height > 0, targetAspect > 0 else { return bounds }
        let current = bounds.width / bounds.height
        if current > targetAspect {
            let width = bounds.height * targetAspect
            return CGRect(x:bounds.midX-width/2, y:bounds.minY, width:width, height:bounds.height)
        } else {
            let height = bounds.width / targetAspect
            return CGRect(x:bounds.minX, y:bounds.midY-height/2, width:bounds.width, height:height)
        }
    }
}
