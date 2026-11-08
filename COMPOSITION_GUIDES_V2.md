# Asperito — Six additional composition guides

The composition library now contains **18** guides (formerly 12). Six new guides render as native, vector-based SwiftUI Canvas overlays. No formulas, numbers, or scene-recognition claims appear on the camera guides.

| Guide | Camera effect | Controls |
| --- | --- | --- |
| Leading Lines | Two prominent converging gold guides and finer guides toward a focal marker | Focal horizontal/vertical position, rotate, mirror |
| Symmetry & Reflection | Gold symmetry axis and subtle equidistant reflection reference lines | Vertical/horizontal, axis position, spacing |
| Golden Triangle | Major gold diagonal with two supporting triangular divisions | Rotate, mirror |
| Frame Within Frame | Rounded inner photo-frame reference with subtle center markers | Size, horizontal/vertical offset, rotate |
| Negative Space | Subject circle and space-direction arrow | Subject position, space amount, direction |
| S-Curve | Smooth double Bézier flow guide | Bend, rotate, mirror |

Controls live in the existing **Guides** picker, and preferences persist through AppStorage. Six new offline tutorials are included.

All 18 guides are included in automated portrait/landscape geometry tests, and all six new guides have dedicated iPhone Simulator capture cases. The screenshot workflow outputs **23 PNGs**: 18 guide views plus onboarding, main camera, picker, tutorial, and settings.

**Simulator disclosure:** The camera previews use synthetic landscape imagery for repeatable automated inspection; they are genuine running-app UI captures, not photos captured with physical camera hardware. Test sensor-based features and Photos saving on a real iPhone before distribution.
