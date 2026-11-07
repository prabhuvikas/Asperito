import SwiftUI
import AVFoundation

private final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    var focusHandler: ((CGPoint) -> Void)?

    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        let point = previewLayer.captureDevicePointConverted(fromLayerPoint: gesture.location(in: self))
        focusHandler?(point)
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

    func makeUIView(context: Context) -> UIView {
        let view = CameraPreviewUIView()
        view.backgroundColor = .black
        view.previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer.session = session
        view.focusHandler = onFocus
        view.addGestureRecognizer(UITapGestureRecognizer(target:view,action:#selector(CameraPreviewUIView.didTap(_:))))
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? CameraPreviewUIView)?.focusHandler = onFocus
        uiView.setNeedsLayout()
    }
}
