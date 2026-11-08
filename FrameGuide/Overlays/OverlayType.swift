import SwiftUI

enum OverlayKind: String, CaseIterable, Identifiable, Codable {
    case thirds, goldenGrid, goldenSpiral, center, diagonal, square
    case horizon, eyeLine, safeArea, perspective, cinematic, custom
    case leadingLines, reflection, goldenTriangle, frameWithinFrame, negativeSpace, sCurve

    var id: String { rawValue }
    var title: String {
        switch self {
        case .thirds: "Rule of Thirds"
        case .goldenGrid: "Golden Ratio"
        case .goldenSpiral: "Golden Spiral"
        case .center: "Center Cross"
        case .diagonal: "Diagonal Guides"
        case .square: "Square Grid"
        case .horizon: "Horizon Level"
        case .eyeLine: "Portrait Eye Line"
        case .safeArea: "Social Safe Area"
        case .perspective: "Perspective Lines"
        case .cinematic: "Cinematic Frame"
        case .custom: "Custom Grid"
        case .leadingLines: "Leading Lines"
        case .reflection: "Symmetry & Reflection"
        case .goldenTriangle: "Golden Triangle"
        case .frameWithinFrame: "Frame Within Frame"
        case .negativeSpace: "Negative Space"
        case .sCurve: "S-Curve"
        }
    }
    var symbol: String {
        switch self {
        case .thirds, .square, .custom: "grid"
        case .goldenGrid: "square.grid.3x3"
        case .goldenSpiral: "circle.dotted.circle"
        case .center: "plus"
        case .diagonal: "arrow.up.right"
        case .horizon: "level"
        case .eyeLine: "eye"
        case .safeArea: "aspectratio"
        case .perspective: "point.topleft.down.curvedto.point.bottomright.up"
        case .cinematic: "film"
        case .leadingLines: "arrow.up.forward"
        case .reflection: "square.split.2x1"
        case .goldenTriangle: "triangle"
        case .frameWithinFrame: "square.on.square"
        case .negativeSpace: "circle.dotted"
        case .sCurve: "point.topleft.down.to.point.bottomright.curvepath"
        }
    }
}

enum GuideColor: String, CaseIterable, Identifiable {
    case white, yellow, cyan, red
    var id: String { rawValue }
    var color: Color {
        switch self {
        case .white: .white
        case .yellow: .yellow
        case .cyan: .cyan
        case .red: .red
        }
    }
}

enum CaptureAspect: String, CaseIterable, Identifiable {
    case fourThree = "4:3", square = "1:1", sixteenNine = "16:9"
    var id: String { rawValue }
    // width / height in portrait; camera output is cropped to match these guides.
    var portraitRatio: CGFloat {
        switch self {
        case .fourThree: 3.0 / 4.0
        case .square: 1
        case .sixteenNine: 9.0 / 16.0
        }
    }
    var outputRatio: CGFloat {
        portraitRatio
    }
}

struct GuideSettings {
    var customRows: Int = 4
    var customColumns: Int = 4
    var eyeLinePosition: CGFloat = 0.38
    var perspectivePoint: CGPoint = CGPoint(x: 0.5, y: 0.38)
    var spiralTurns: Int = 0
    var spiralMirrored: Bool = false
    var safeAreaRatio: CGFloat = 4.0 / 5.0
    var cinematicRatio: CGFloat = 2.39
    var focusPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var guideRotation: Int = 0
    var guideMirrored: Bool = false
    var guideScale: CGFloat = 0.7
    var reflectionHorizontal: Bool = false
    var curveBend: CGFloat = 0.5
}
