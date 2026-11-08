import XCTest
import SwiftUI
@testable import FrameGuide

final class OverlayGeometryTests: XCTestCase {
    let portrait = CGRect(x: 0, y: 0, width: 300, height: 400)
    let landscape = CGRect(x: 0, y: 0, width: 400, height: 300)

    func testExactlyEighteenDistinctGuides() {
        XCTAssertEqual(OverlayKind.allCases.count, 18)
        XCTAssertEqual(Set(OverlayKind.allCases.map(\.rawValue)).count, 18)
    }

    func testAllEighteenGuidesRenderAtBothOrientations() {
        for kind in OverlayKind.allCases {
            for bounds in [portrait, landscape] {
                XCTAssertFalse(OverlayGeometry.lines(for: kind, in: bounds).isEmpty,
                               "\(kind.title) should render at \(bounds.size)")
            }
        }
    }

    func testSixAdvancedGuidesRemainWithinViewfinder() {
        let kinds: [OverlayKind] = [.leadingLines, .reflection, .goldenTriangle,
                                    .frameWithinFrame, .negativeSpace, .sCurve]
        for frame in [portrait, landscape] {
            for kind in kinds {
                for rotation in 0..<4 {
                    for mirrored in [false,true] {
                        let settings = GuideSettings(
                            focusPoint:CGPoint(x:0.36,y:0.63),guideRotation:rotation,
                            guideMirrored:mirrored,guideScale:0.55,curveBend:0.75)
                        let guides=OverlayGeometry.lines(for:kind,in:frame,settings:settings)
                        XCTAssertFalse(guides.isEmpty,"Missing \(kind.title)")
                        XCTAssertTrue(guides.contains(where:{$0.accent}),"Missing highlighted guide for \(kind.title)")
                        for guide in guides {
                            let box=guide.path.boundingRect
                            XCTAssertGreaterThanOrEqual(box.minX,frame.minX-0.25)
                            XCTAssertGreaterThanOrEqual(box.minY,frame.minY-0.25)
                            XCTAssertLessThanOrEqual(box.maxX,frame.maxX+0.25)
                            XCTAssertLessThanOrEqual(box.maxY,frame.maxY+0.25)
                        }
                    }
                }
            }
        }
    }

    func testAdvancedGuideControlsChangeGeometry() {
        let original=GuideSettings()
        let moved=GuideSettings(focusPoint:CGPoint(x:0.7,y:0.4))
        for kind in [OverlayKind.leadingLines,.frameWithinFrame,.negativeSpace] {
            let a=OverlayGeometry.lines(for:kind,in:portrait,settings:original)[0].path.boundingRect
            let b=OverlayGeometry.lines(for:kind,in:portrait,settings:moved)[0].path.boundingRect
            XCTAssertNotEqual(a,b,"Focus adjustment has no effect on \(kind.title)")
        }
        let a=OverlayGeometry.lines(for:.sCurve,in:portrait,settings:GuideSettings(curveBend:0.2))[0].path
        let b=OverlayGeometry.lines(for:.sCurve,in:portrait,settings:GuideSettings(curveBend:0.8))[0].path
        // The curve's endpoints are unchanged, so its bounding box may also
        // remain unchanged. Check the actual Bézier control points instead.
        func points(_ path: Path) -> [CGPoint] {
            var result: [CGPoint] = []
            path.forEach { element in
                switch element {
                case let .move(to: p), let .line(to: p): result.append(p)
                case let .quadCurve(to: p, control: c): result.append(contentsOf:[p,c])
                case let .curve(to: p, control1: a, control2: b): result.append(contentsOf:[p,a,b])
                case .closeSubpath: break
                }
            }
            return result
        }
        XCTAssertNotEqual(points(a),points(b),"Bend must change the S-curve")
    }

    func testGestureRotationStoreIsPerGuideAndHandlesCorruptData() {
        let input: [String: Double] = ["goldenSpiral": 48.5, "sCurve": -76]
        let output = GuideRotationStore.read(GuideRotationStore.write(input))
        XCTAssertEqual(output["goldenSpiral"],48.5)
        XCTAssertEqual(output["sCurve"],-76)
        XCTAssertEqual(GuideRotationStore.read("not json").count,0)
        XCTAssertEqual(GuideRotationStore.normalized(450),90)
        XCTAssertEqual(GuideRotationStore.normalized(-450),-90)
        XCTAssertEqual(GuideRotationStore.normalized(.infinity),0)
    }

    func testOnlyCreativeGuidesRotateByGesture() {
        for kind in [OverlayKind.goldenSpiral,.diagonal,.perspective,
                     .leadingLines,.reflection,.goldenTriangle,
                     .frameWithinFrame,.negativeSpace,.sCurve] {
            XCTAssertTrue(kind.supportsGestureRotation,kind.title)
        }
        for kind in [OverlayKind.thirds,.goldenGrid,.square,.custom,
                     .horizon,.eyeLine,.safeArea,.cinematic,.center] {
            XCTAssertFalse(kind.supportsGestureRotation,kind.title)
        }
    }

    func testFineRotationTransformsPathsAboutViewfinderCenter() {
        let bounds = CGRect(x:10,y:20,width:200,height:400)
        let guide = GuideStroke(path:Path { p in
            p.move(to: CGPoint(x:110,y:120))
            p.addLine(to: CGPoint(x:110,y:180))
        },accent:true)
        let rotated = OverlayGeometry.rotated([guide],in:bounds,degrees:90)
        let box = rotated[0].path.boundingRect
        XCTAssertEqual(box.minX,150,accuracy:0.001)
        XCTAssertEqual(box.maxX,210,accuracy:0.001)
        XCTAssertEqual(box.midY,220,accuracy:0.001)
        XCTAssertTrue(rotated[0].accent)
        XCTAssertEqual(OverlayGeometry.rotated([guide],in:bounds,degrees:0)[0].path.boundingRect,
                       guide.path.boundingRect)
    }

    func testThirdsAndGoldenRatioHaveFourLines() {
        XCTAssertEqual(OverlayGeometry.lines(for: .thirds, in: portrait).count, 4)
        XCTAssertEqual(OverlayGeometry.lines(for: .goldenGrid, in: portrait).count, 4)
    }

    func testGridDivisionsAreWithinBounds() {
        for kind in [OverlayKind.thirds, .goldenGrid, .square, .custom] {
            for stroke in OverlayGeometry.lines(for: kind, in: portrait) {
                let box = stroke.path.boundingRect
                XCTAssertGreaterThanOrEqual(box.minX, portrait.minX - 0.001)
                XCTAssertGreaterThanOrEqual(box.minY, portrait.minY - 0.001)
                XCTAssertLessThanOrEqual(box.maxX, portrait.maxX + 0.001)
                XCTAssertLessThanOrEqual(box.maxY, portrait.maxY + 0.001)
            }
        }
    }

    func testCustomGridClampsRowsAndColumnsToTwoThroughTen() {
        XCTAssertEqual(OverlayGeometry.lines(for: .custom, in: portrait,
                        settings: GuideSettings(customRows: 4, customColumns: 6)).count, 8)
        XCTAssertEqual(OverlayGeometry.lines(for: .custom, in: portrait,
                        settings: GuideSettings(customRows: 1, customColumns: 1)).count, 2)
        XCTAssertEqual(OverlayGeometry.lines(for: .custom, in: portrait,
                        settings: GuideSettings(customRows: 100, customColumns: 100)).count, 18)
    }

    func testGoldenSpiralHasMainArcAndConstructionGuides() {
        let paths = OverlayGeometry.lines(for: .goldenSpiral, in: portrait)
        XCTAssertGreaterThanOrEqual(paths.count, 12)
        XCTAssertTrue(paths[0].accent, "First path should be the bright spiral")
        XCTAssertTrue(paths.contains(where: { $0.dashed }), "Construction diagonals must be present")
        XCTAssertFalse(paths[1].accent, "Bounding rectangle should not glow")
        XCTAssertFalse(paths[0].path.boundingRect.isEmpty)
    }

    func testGoldenSpiralConstructionWorksInLandscapeAndRotations() {
        for frame in [portrait, landscape] {
            for turns in 0..<4 {
                for mirror in [false, true] {
                    let guides = OverlayGeometry.lines(
                        for: .goldenSpiral, in: frame,
                        settings: GuideSettings(spiralTurns: turns, spiralMirrored: mirror))
                    XCTAssertFalse(guides.isEmpty)
                    for guide in guides {
                        let rect = guide.path.boundingRect
                        XCTAssertGreaterThanOrEqual(rect.minX, frame.minX - 0.25)
                        XCTAssertGreaterThanOrEqual(rect.minY, frame.minY - 0.25)
                        XCTAssertLessThanOrEqual(rect.maxX, frame.maxX + 0.25)
                        XCTAssertLessThanOrEqual(rect.maxY, frame.maxY + 0.25)
                    }
                }
            }
        }
    }

    func testSpiralSupportsRotationAndMirroring() {
        func startingPoint(_ path: Path) -> CGPoint {
            var first: CGPoint?
            path.forEach { element in
                if case let .move(to: point) = element, first == nil { first = point }
            }
            return first ?? .zero
        }
        let normal = startingPoint(OverlayGeometry.lines(for: .goldenSpiral, in: portrait)[0].path)
        let rotated = startingPoint(OverlayGeometry.lines(for: .goldenSpiral, in: portrait,
                          settings: GuideSettings(spiralTurns: 1))[0].path)
        let mirrored = startingPoint(OverlayGeometry.lines(for: .goldenSpiral, in: portrait,
                          settings: GuideSettings(spiralMirrored: true))[0].path)
        XCTAssertNotEqual(normal, rotated)
        XCTAssertNotEqual(normal, mirrored)
    }

    func testFramingGuideMatchesDesiredRatioAndFitsPreview() {
        for bounds in [portrait, landscape] {
            for ratio in [0.5625, 0.8, 1.0, 16.0 / 9.0, 2.39] {
                let result = OverlayGeometry.framingRect(inside: bounds, targetAspect: ratio)
                XCTAssertGreaterThan(result.width, 0)
                XCTAssertGreaterThan(result.height, 0)
                XCTAssertGreaterThanOrEqual(result.minX, bounds.minX - 0.001)
                XCTAssertGreaterThanOrEqual(result.minY, bounds.minY - 0.001)
                XCTAssertLessThanOrEqual(result.maxX, bounds.maxX + 0.001)
                XCTAssertLessThanOrEqual(result.maxY, bounds.maxY + 0.001)
                XCTAssertEqual(result.width / result.height, ratio, accuracy: 0.0001)
            }
        }
    }

    func testEyeLinePositionIsClamped() {
        let below = OverlayGeometry.lines(for: .eyeLine, in: portrait,
                        settings: GuideSettings(eyeLinePosition: -1)).first!.path.boundingRect
        let above = OverlayGeometry.lines(for: .eyeLine, in: portrait,
                        settings: GuideSettings(eyeLinePosition: 2)).first!.path.boundingRect
        XCTAssertEqual(below.midY, portrait.height * 0.05, accuracy: 0.001)
        XCTAssertEqual(above.midY, portrait.height * 0.95, accuracy: 0.001)
    }

    func testZeroSizedBoundsDoNotRenderPaths() {
        for kind in OverlayKind.allCases {
            XCTAssertTrue(OverlayGeometry.lines(for: kind, in: .zero).isEmpty)
        }
    }
}

final class OverlayLessonTests: XCTestCase {
    func testEveryOverlayHasOfflineTutorialContent() {
        for kind in OverlayKind.allCases {
            let lesson = OverlayLesson.forKind(kind)
            XCTAssertEqual(lesson.kind, kind)
            XCTAssertGreaterThan(lesson.summary.count, 30)
            XCTAssertFalse(lesson.useFor.isEmpty)
            XCTAssertFalse(lesson.exercise.isEmpty)
        }
    }
}

final class CaptureAspectTests: XCTestCase {
    func testCaptureAspectRatios() {
        XCTAssertEqual(CaptureAspect.fourThree.portraitRatio, 3.0 / 4, accuracy: 0.0001)
        XCTAssertEqual(CaptureAspect.square.portraitRatio, 1.0, accuracy: 0.0001)
        XCTAssertEqual(CaptureAspect.sixteenNine.portraitRatio, 9.0 / 16, accuracy: 0.0001)
    }
}

import Photos
import UIKit

final class CameraProcessingTests: XCTestCase {
    private func sampleJPEG() -> Data {
        let image = UIGraphicsImageRenderer(size:CGSize(width:400,height:300)).image { ctx in
            UIColor.red.setFill()
            ctx.cgContext.fill(CGRect(x:0,y:0,width:400,height:300))
        }
        return image.jpegData(compressionQuality:0.85)!
    }
    func testSavePermissionStatuses() {
        XCTAssertTrue(CameraManager.maySavePhotos(.authorized))
        XCTAssertTrue(CameraManager.maySavePhotos(.limited))
        XCTAssertFalse(CameraManager.maySavePhotos(.denied))
        XCTAssertFalse(CameraManager.maySavePhotos(.restricted))
        XCTAssertFalse(CameraManager.maySavePhotos(.notDetermined))
    }
    func testPhotoCroppingAndInvalidJPEG() {
        let jpeg=sampleJPEG()
        let unchanged=CameraManager.cropJPEG(jpeg,to:.fourThree)
        XCTAssertEqual(unchanged?.0,jpeg)
        for aspect in [CaptureAspect.square,.sixteenNine] {
            guard let result=CameraManager.cropJPEG(jpeg,to:aspect) else {
                return XCTFail("JPEG processing failed: \(aspect.rawValue)")
            }
            XCTAssertEqual(result.1.size.width/result.1.size.height,
                           1/aspect.outputRatio,accuracy:0.015)
            XCTAssertGreaterThan(result.0.count,1000)
        }
        XCTAssertNil(CameraManager.cropJPEG(Data(),to:.square))
    }
}
