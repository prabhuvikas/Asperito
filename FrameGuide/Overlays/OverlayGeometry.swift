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
        case .leadingLines, .reflection, .goldenTriangle, .frameWithinFrame, .negativeSpace, .sCurve:
            return advancedGuides(for: kind, in: rect, settings: settings)
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
        let base: CGRect
        if portrait {
            base = framingRect(inside: bounds, targetAspect: CGFloat(1 / phi))
        } else {
            // Construct in portrait space, then rotate the resulting rectangle
            // so the composition guide fills a landscape camera viewfinder.
            let finalWidth = min(bounds.width, bounds.height * CGFloat(phi))
            let sourceWidth = finalWidth / CGFloat(phi)
            base = CGRect(x: bounds.midX - sourceWidth / 2,
                          y: bounds.midY - finalWidth / 2,
                          width: sourceWidth, height: finalWidth)
        }
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


    /// All editable advanced compositions are constructed in normalized
    /// viewfinder coordinates; rotated and mirrored guides never spill outside
    /// the preview, regardless of portrait, landscape or aspect ratio.
    static func advancedGuides(for kind: OverlayKind, in rect: CGRect,
                               settings: GuideSettings = .init()) -> [GuideStroke] {
        guard rect.width > 0, rect.height > 0 else { return [] }
        let quarterTurns = ((settings.guideRotation % 4) + 4) % 4
        let fx = min(0.85, max(0.15, settings.focusPoint.x))
        let fy = min(0.85, max(0.15, settings.focusPoint.y))
        let scale = min(0.9, max(0.25, settings.guideScale))
        let bend = min(0.95, max(0.05, settings.curveBend))
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            var nx = min(1, max(0, x))
            var ny = min(1, max(0, y))
            if settings.guideMirrored { nx = 1 - nx }
            for _ in 0..<quarterTurns {
                let oldX = nx
                nx = 1 - ny
                ny = oldX
            }
            return CGPoint(x: rect.minX + nx * rect.width,
                           y: rect.minY + ny * rect.height)
        }
        func line(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat,
                  accent: Bool = false, dashed: Bool = false) -> GuideStroke {
            var p = Path()
            p.move(to: point(x1,y1))
            p.addLine(to: point(x2,y2))
            return GuideStroke(path: p, accent: accent, dashed: dashed)
        }
        func circle(_ x: CGFloat, _ y: CGFloat, radius: CGFloat) -> GuideStroke {
            let center = point(x,y)
            let r = min(rect.width,rect.height)*radius
            return GuideStroke(path: Path(ellipseIn: CGRect(x:center.x-r, y:center.y-r,
                                                          width:r*2, height:r*2)), accent: true)
        }
        switch kind {
        case .leadingLines:
            // Clear sightlines to a movable, manually chosen vanishing point.
            return [
                line(0.03,0.96,fx,fy,accent:true),
                line(0.97,0.96,fx,fy,accent:true),
                line(0.15,0.96,fx,fy,dashed:true),
                line(0.85,0.96,fx,fy,dashed:true),
                circle(fx,fy,radius:0.013)
            ]
        case .reflection:
            let offset: CGFloat = 0.18 * scale / 0.7
            if settings.reflectionHorizontal {
                return [
                    line(0,fy,1,fy,accent:true),
                    line(0,max(0,fy-offset),1,max(0,fy-offset),dashed:true),
                    line(0,min(1,fy+offset),1,min(1,fy+offset),dashed:true)
                ]
            }
            return [
                line(fx,0,fx,1,accent:true),
                line(max(0,fx-offset),0,max(0,fx-offset),1,dashed:true),
                line(min(1,fx+offset),0,min(1,fx+offset),1,dashed:true)
            ]
        case .goldenTriangle:
            // Project corners onto the frame diagonal using the physical
            // viewfinder dimensions, yielding genuinely perpendicular guides.
            let w2 = rect.width * rect.width
            let h2 = rect.height * rect.height
            let upperFoot = w2 / (w2 + h2)
            let lowerFoot = h2 / (w2 + h2)
            return [
                line(0,0,1,1,accent:true),
                line(1,0,upperFoot,upperFoot),
                line(0,1,lowerFoot,lowerFoot)
            ]
        case .frameWithinFrame:
            let width = min(scale * 0.92, 2 * min(fx, 1-fx))
            let height = min(scale * 0.80, 2 * min(fy, 1-fy))
            // Curve segment construction keeps corner radius consistent even
            // if the photographer rotates the rectangular guide.
            let x0 = fx - width/2, x1 = fx + width/2
            let y0 = fy - height/2, y1 = fy + height/2
            let r = min(width,height)*0.13
            let k: CGFloat = 0.55228475
            var frame = Path()
            frame.move(to: point(x0+r,y0))
            frame.addLine(to: point(x1-r,y0))
            frame.addCurve(to:point(x1,y0+r),
                control1:point(x1-r+r*k,y0),control2:point(x1,y0+r-r*k))
            frame.addLine(to:point(x1,y1-r))
            frame.addCurve(to:point(x1-r,y1),
                control1:point(x1,y1-r+r*k),control2:point(x1-r+r*k,y1))
            frame.addLine(to:point(x0+r,y1))
            frame.addCurve(to:point(x0,y1-r),
                control1:point(x0+r-r*k,y1),control2:point(x0,y1-r+r*k))
            frame.addLine(to:point(x0,y0+r))
            frame.addCurve(to:point(x0+r,y0),
                control1:point(x0,y0+r-r*k),control2:point(x0+r-r*k,y0))
            frame.closeSubpath()
            return [GuideStroke(path:frame,accent:true),
                    line(fx-0.06,fy,fx+0.06,fy,dashed:true),
                    line(fx,fy-0.06,fx,fy+0.06,dashed:true)]
        case .negativeSpace:
            // The subject marker is intentionally manual: no scene recognition.
            // Offset arrows indicate the breathing room to leave to its right.
            let start = min(0.98,fx+0.09)
            let end = min(0.98,start + (1-start)*scale)
            return [
                circle(fx,fy,radius:0.045),
                line(start,fy,end,fy,accent:true),
                line(end-0.045,fy-0.035,end,fy,accent:true),
                line(end-0.045,fy+0.035,end,fy,accent:true),
                line((start+end)/2,0.12,(start+end)/2,0.88,dashed:true)
            ]
        case .sCurve:
            let shift = (bend-0.5)*0.55
            var curve = Path()
            curve.move(to:point(0.14,0.90))
            curve.addCurve(to:point(0.51,0.49),
                control1:point(min(0.95,max(0.05,0.90+shift)),0.84),
                control2:point(min(0.95,max(0.05,0.13+shift)),0.59))
            curve.addCurve(to:point(0.86,0.10),
                control1:point(min(0.95,max(0.05,0.87-shift)),0.39),
                control2:point(min(0.95,max(0.05,0.09-shift)),0.16))
            return [GuideStroke(path:curve,accent:true),
                    circle(0.14,0.90,radius:0.013),
                    circle(0.86,0.10,radius:0.013)]
        default: return []
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
