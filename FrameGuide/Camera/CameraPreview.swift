import SwiftUI
import AVFoundation

private final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    var focusHandler: ((CGPoint) -> Void)?
    var rotationHandler: ((Double, UIGestureRecognizer.State) -> Void)?

    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        let point = previewLayer.captureDevicePointConverted(fromLayerPoint: gesture.location(in: self))
        focusHandler?(point)
    }
    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        rotationHandler?(Double(gesture.rotation) * 180 / .pi, gesture.state)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let connection = previewLayer.connection else { return }
        let angle: CGFloat
        switch window?.windowScene?.interfaceOrientation {
        case .landscapeLeft: angle = 0
        case .landscapeRight: angle = 180
        case .portraitUpsideDown: angle = 270
        default: angle = 90
        }
        if connection.isVideoRotationAngleSupported(angle) { connection.videoRotationAngle = angle }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    var onFocus: (CGPoint) -> Void
    var onRotation: (Double, UIGestureRecognizer.State) -> Void = { _, _ in }

    func makeUIView(context: Context) -> UIView {
        let view = CameraPreviewUIView()
        view.backgroundColor = .black
        view.previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer.session = session
        view.focusHandler = onFocus
        view.rotationHandler = onRotation
        view.addGestureRecognizer(UITapGestureRecognizer(target:view,action:#selector(CameraPreviewUIView.didTap(_:))))
        // UIRotationGestureRecognizer requires two touches. A single finger
        // continues to use the existing native tap-to-focus recognizer.
        view.addGestureRecognizer(UIRotationGestureRecognizer(
            target:view,action:#selector(CameraPreviewUIView.didRotate(_:))))
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? CameraPreviewUIView)?.focusHandler = onFocus
        (uiView as? CameraPreviewUIView)?.rotationHandler = onRotation
        uiView.setNeedsLayout()
    }
}
