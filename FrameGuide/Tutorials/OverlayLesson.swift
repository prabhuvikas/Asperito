import SwiftUI

struct OverlayLesson {
    let kind: OverlayKind
    let summary: String
    let useFor: String
    let exercise: String

    static func forKind(_ kind: OverlayKind) -> OverlayLesson {
        switch kind {
        case .thirds: .init(kind:kind,summary:"Divide the image into a 3×3 grid. Put your subject at an intersection, or align the horizon with a third.",useFor:"Travel, landscape and portraits",exercise:"Move the subject to the right intersection and compare with a centered photo.")
        case .goldenGrid: .init(kind:kind,summary:"Align subjects using proportional lines at 38.2% and 61.8% of the frame.",useFor:"Still life and natural scenes",exercise:"Position the main subject along one golden division.")
        case .goldenSpiral: .init(kind:kind,summary:"Use a logarithmic golden spiral to guide the eye toward a focal point. Rotate or mirror it for your scene.",useFor:"Nature, architecture and food",exercise:"Place your subject near the tight end of the spiral.")
        case .center: .init(kind:kind,summary:"Align your subject with the middle of the frame. This works best when the surroundings are symmetrical.",useFor:"Buildings, reflections and minimalism",exercise:"Photograph a doorway with equal space on either side.")
        case .diagonal: .init(kind:kind,summary:"Use diagonal leading lines to introduce movement and energy into the photograph.",useFor:"Stairs, roads and street photography",exercise:"Place the edge of a road along a diagonal line.")
        case .square: .init(kind:kind,summary:"A five-by-five grid makes it easier to balance repeated elements and structural details.",useFor:"Architecture, objects and patterns",exercise:"Align repeating windows or tiles along the grid.")
        case .horizon: .init(kind:kind,summary:"The dynamic line responds to device tilt. Green indicates that the phone is close to level.",useFor:"Seascapes, horizons and interiors",exercise:"Keep the guide green while photographing a distant horizon.")
        case .eyeLine: .init(kind:kind,summary:"Keep a person's eyes at a consistent height. Adjust the eye-line position to match the portrait.",useFor:"Portraits, headshots and interviews",exercise:"Align both eyes with the line, then capture.")
        case .safeArea: .init(kind:kind,summary:"Preview how content can fit into a narrower social-media composition. The overlay will not be saved.",useFor:"Social posts and stories",exercise:"Keep the subject inside the safe rectangle before shooting.")
        case .perspective: .init(kind:kind,summary:"Move the vanishing point to line up leading edges. These are manual guides, not automatic scene detection.",useFor:"Buildings, corridors and roads",exercise:"Align receding architectural lines with the dashed rays.")
        case .cinematic: .init(kind:kind,summary:"Preview wide cinematic framing, including 16:9 and 2.39:1. The photo is not automatically cropped by this overlay.",useFor:"Environmental portraits and cinematic scenes",exercise:"Compose a scene inside the widescreen window.")
        case .custom: .init(kind:kind,summary:"Choose the number of rows and columns to make your own composition guide.",useFor:"Product photos, patterns and repeatable framing",exercise:"Set four rows and six columns and use the same layout for three shots.")
        }
    }
}
