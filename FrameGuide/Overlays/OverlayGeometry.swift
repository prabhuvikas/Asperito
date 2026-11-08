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
            return goldenSpiralGuides(in: rect, settings: settings)
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


    // Golden rectangle construction: a chain of decreasing squares with
    // quarter-circle arcs, matching the classic photography golden spiral.
    // The geometry contains no numerical labels, and is only an overlay.
    static func goldenSpiralGuides(in bounds: CGRect, settings: GuideSettings = .init()) -> [GuideStroke] {
        guard bounds.width > 0, bounds.height > 0 else { return [] }

        // Fit the golden rectangle to the current preview in either orientation.
        let portrait = bounds.height >= bounds.width
        let base = framingRect(inside: bounds, targetAspect: CGFloat(1 / phi))
        var available = base
        var spiral = Path()
        var construction: [GuideStroke] = []
        var firstPoint = true

        // The top/right/bottom/left order produces a continuous inward spiral
        // from the upper-left of the portrait golden rectangle.
        for index in 0..<10 {
            let direction = index % 4
            let side = direction.isMultiple(of: 2) ? available.width : available.height
            guard side > min(base.width, base.height) * 0.002 else { break }

            let square: CGRect
            switch direction {
            case 0:
                square = CGRect(x: available.minX, y: available.minY, width: side, height: side)
                available = CGRect(x: available.minX, y: available.minY + side,
                                   width: available.width, height: max(0, available.height - side))
            case 1:
                square = CGRect(x: available.maxX - side, y: available.minY, width: side, height: side)
                available = CGRect(x: available.minX, y: available.minY,
                                   width: max(0, available.width - side), height: available.height)
            case 2:
                square = CGRect(x: available.minX, y: available.maxY - side, width: side, height: side)
                available = CGRect(x: available.minX, y: available.minY,
                                   width: available.width, height: max(0, available.height - side))
            default:
                square = CGRect(x: available.minX, y: available.minY, width: side, height: side)
                available = CGRect(x: available.minX + side, y: available.minY,
                                   width: max(0, available.width - side), height: available.height)
            }

            let center: CGPoint
            switch direction {
            case 0: center = CGPoint(x: square.minX, y: square.maxY)
            case 1: center = CGPoint(x: square.minX, y: square.minY)
            case 2: center = CGPoint(x: square.maxX, y: square.minY)
            default: center = CGPoint(x: square.maxX, y: square.maxY)
            }

            // A 90-degree circular arc inscribed in each successively
            // smaller square. Subdivision keeps Canvas paths smooth.
            for step in 0...40 {
                let angle = (-CGFloat.pi / 2) + CGFloat(index) * (.pi / 2)
                          + CGFloat(step) / 40 * (.pi / 2)
                let point = CGPoint(x: center.x + side * cos(angle),
                                    y: center.y + side * sin(angle))
                if firstPoint {
                    spiral.move(to: point)
                    firstPoint = false
                } else {
                    spiral.addLine(to: point)
                }
            }

            // Thin visible square construction edges, plus subtle diagonals.
            construction.append(GuideStroke(path: Path(square)))
            if index < 5 {
                var diagonal = Path()
                diagonal.move(to: CGPoint(x: square.minX, y: square.minY))
                diagonal.addLine(to: CGPoint(x: square.maxX, y: square.maxY))
                construction.append(GuideStroke(path: diagonal, dashed: true))
            }
        }

        var border = Path()
        border.addRect(base)
        // Put the main spiral first so callers and tests can identify it.
        let strokes = [GuideStroke(path: spiral, accent: true),
                       GuideStroke(path: border)] + construction

        // Rotation and mirroring remain available from the guide picker.
        // Uniformly scale after rotation so no line runs outside preview.
        let quarterTurns = (((settings.spiralTurns % 4) + 4) % 4 + (portrait ? 0 : 1)) % 4
        let rotation = CGFloat(quarterTurns) * .pi / 2
        let rotatedWidth = quarterTurns.isMultiple(of: 2) ? base.width : base.height
        let rotatedHeight = quarterTurns.isMultiple(of: 2) ? base.height : base.width
        let scale = min(1, min(bounds.width / rotatedWidth, bounds.height / rotatedHeight))
        let centerX = bounds.midX, centerY = bounds.midY
        var transform = CGAffineTransform(translationX: centerX, y: centerY)
        transform = transform.rotated(by: rotation)
        transform = transform.scaledBy(x: scale, y: scale)
        if settings.spiralMirrored { transform = transform.scaledBy(x: -1, y: 1) }
        transform = transform.translatedBy(x: -centerX, y: -centerY)
        return strokes.map { stroke in
            GuideStroke(path: stroke.path.applying(transform),
                        accent: stroke.accent, dashed: stroke.dashed)
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
