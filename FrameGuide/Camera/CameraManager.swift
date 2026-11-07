import AVFoundation
import Photos
import UIKit
import SwiftUI

final class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "com.frameguide.camera.session", qos: .userInitiated)
    private let photoOutput = AVCapturePhotoOutput()
    private var activeInput: AVCaptureDeviceInput?
    private var configured = false
    private var pendingCaptures: [Int64: CaptureAspect] = [:]
    private let captureLock = NSLock()

    @Published private(set) var permissionDenied = false
    @Published private(set) var isRunning = false
    @Published private(set) var isFrontCamera = false
    @Published private(set) var isSaving = false
    @Published private(set) var lastThumbnail: UIImage?
    @Published private(set) var savedMessage: String?
    @Published var errorMessage: String?
    @Published var flashEnabled = false
    @Published private(set) var flashAvailable = false
    @Published var zoomFactor: CGFloat = 1
    @Published var exposureBias: Float = 0

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector:#selector(sessionInterrupted),
            name:AVCaptureSession.wasInterruptedNotification,object:session)
        NotificationCenter.default.addObserver(self, selector:#selector(sessionInterruptionEnded),
            name:AVCaptureSession.interruptionEndedNotification,object:session)
        NotificationCenter.default.addObserver(self, selector:#selector(sessionRuntimeError),
            name:AVCaptureSession.runtimeErrorNotification,object:session)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func sessionInterrupted(_ notification: Notification) {
        DispatchQueue.main.async { self.isRunning = false }
    }
    @objc private func sessionInterruptionEnded(_ notification: Notification) {
        start()
    }
    @objc private func sessionRuntimeError(_ notification: Notification) {
        DispatchQueue.main.async { self.errorMessage = "The camera session was interrupted. Reopen the camera if it does not resume." }
        start()
    }

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { self.permissionDenied = false }
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted { self?.configureAndStart() }
                else { DispatchQueue.main.async { self?.permissionDenied = true } }
            }
        default:
            DispatchQueue.main.async { self.permissionDenied = true }
        }
    }

    private func configureAndStart() {
        queue.async { [weak self] in
            guard let self else { return }
            if !self.configured {
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                      let input = try? AVCaptureDeviceInput(device: camera),
                      self.session.canAddInput(input), self.session.canAddOutput(self.photoOutput) else {
                    self.session.commitConfiguration()
                    DispatchQueue.main.async { self.errorMessage = "A compatible camera is not available." }
                    return
                }
                self.session.addInput(input)
                self.session.addOutput(self.photoOutput)
                self.activeInput = input
                DispatchQueue.main.async { self.flashAvailable = camera.hasFlash }
                self.photoOutput.isHighResolutionCaptureEnabled = true
                self.configured = true
                self.session.commitConfiguration()
            }
            if !self.session.isRunning { self.session.startRunning() }
            DispatchQueue.main.async { self.isRunning = self.session.isRunning }
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning { self.session.stopRunning() }
            DispatchQueue.main.async { self.isRunning = false }
        }
    }

    func flipCamera() {
        queue.async { [weak self] in
            guard let self, let current = self.activeInput else { return }
            let desired: AVCaptureDevice.Position = current.device.position == .back ? .front : .back
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: desired),
                  let next = try? AVCaptureDeviceInput(device: camera) else { return }
            self.session.beginConfiguration()
            self.session.removeInput(current)
            if self.session.canAddInput(next) {
                self.session.addInput(next)
                self.activeInput = next
                DispatchQueue.main.async {
                    self.isFrontCamera = desired == .front
                    self.flashAvailable = camera.hasFlash
                    self.flashEnabled = false
                    self.zoomFactor = 1
                }
            } else { self.session.addInput(current) }
            self.session.commitConfiguration()
        }
    }

    func setZoom(_ requested: CGFloat) {
        queue.async { [weak self] in
            guard let self, let device = self.activeInput?.device else { return }
            let zoom = max(device.minAvailableVideoZoomFactor, min(requested, min(5,device.activeFormat.videoMaxZoomFactor)))
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = zoom
                device.unlockForConfiguration()
                DispatchQueue.main.async { self.zoomFactor = zoom }
            } catch { DispatchQueue.main.async { self.errorMessage = error.localizedDescription } }
        }
    }

    func focus(at normalizedPoint: CGPoint) {
        queue.async { [weak self] in
            guard let self, let device = self.activeInput?.device else { return }
            let point = CGPoint(x: max(0,min(1,normalizedPoint.x)), y:max(0,min(1,normalizedPoint.y)))
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
                    device.focusPointOfInterest = point
                    device.focusMode = .autoFocus
                }
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = .autoExpose
                }
                device.unlockForConfiguration()
            } catch { DispatchQueue.main.async { self.errorMessage = error.localizedDescription } }
        }
    }

    func setExposure(_ requested: Float) {
        queue.async { [weak self] in
            guard let self, let device = self.activeInput?.device else { return }
            let bias = max(device.minExposureTargetBias,min(device.maxExposureTargetBias,requested))
            do {
                try device.lockForConfiguration()
                device.setExposureTargetBias(bias, completionHandler:nil)
                device.unlockForConfiguration()
                DispatchQueue.main.async { self.exposureBias = bias }
            } catch { DispatchQueue.main.async { self.errorMessage = error.localizedDescription } }
        }
    }

    func capture(aspect: CaptureAspect, orientation: UIInterfaceOrientation = .portrait) {
        queue.async { [weak self] in
            guard let self, self.configured, self.session.isRunning else { return }
            if let connection = self.photoOutput.connection(with:.video) {
                let angle: CGFloat
                switch orientation {
                case .landscapeLeft: angle = 0
                case .landscapeRight: angle = 180
                case .portraitUpsideDown: angle = 270
                default: angle = 90
                }
                if connection.isVideoRotationAngleSupported(angle) { connection.videoRotationAngle = angle }
            }
            let settings = AVCapturePhotoSettings()
            settings.photoQualityPrioritization = .balanced
            if self.activeInput?.device.hasFlash == true && self.flashEnabled { settings.flashMode = .on }
            self.captureLock.lock()
            self.pendingCaptures[settings.uniqueID] = aspect
            self.captureLock.unlock()
            DispatchQueue.main.async { self.isSaving = true; self.savedMessage = nil }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    private static func cropJPEG(_ data: Data, to aspect: CaptureAspect) -> (Data, UIImage)? {
        guard let input = UIImage(data: data) else { return nil }
        // Rotate pixels into display orientation before cropping; 4:3 uses original bytes.
        if aspect == .fourThree { return (data, input) }
        let inputSize = input.size
        let sideRotation: Bool
        switch input.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored: sideRotation = true
        default: sideRotation = false
        }
        let nativeSize = sideRotation ? CGSize(width:inputSize.height,height:inputSize.width) : inputSize
        let targetRatio = nativeSize.width > nativeSize.height ? 1 / aspect.outputRatio : aspect.outputRatio
        let cropWidth: CGFloat, cropHeight: CGFloat
        if nativeSize.width / nativeSize.height > targetRatio {
            cropHeight = nativeSize.height; cropWidth = nativeSize.height * targetRatio
        } else {
            cropWidth = nativeSize.width; cropHeight = nativeSize.width / targetRatio
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width:cropWidth,height:cropHeight), format:format)
        let output = renderer.image { _ in
            input.draw(in:CGRect(x:(cropWidth-nativeSize.width)/2, y:(cropHeight-nativeSize.height)/2,
                                 width:nativeSize.width,height:nativeSize.height))
        }
        guard let jpeg = output.jpegData(compressionQuality: 0.92) else { return nil }
        return (jpeg,output)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation() else {
            captureLock.lock()
            pendingCaptures.removeValue(forKey: photo.resolvedSettings.uniqueID)
            captureLock.unlock()
            DispatchQueue.main.async { self.isSaving = false; self.errorMessage = error?.localizedDescription ?? "Could not capture photo." }
            return
        }
        captureLock.lock()
        let aspect = pendingCaptures.removeValue(forKey: photo.resolvedSettings.uniqueID) ?? .fourThree
        captureLock.unlock()
        DispatchQueue.global(qos:.userInitiated).async {
            guard let (photoData, image) = Self.cropJPEG(data, to:aspect) else {
                DispatchQueue.main.async { self.isSaving = false; self.errorMessage = "Photo could not be processed." }
                return
            }
            PHPhotoLibrary.requestAuthorization(for:.addOnly) { status in
                guard status == .authorized || status == .limited else {
                    DispatchQueue.main.async { self.isSaving = false; self.errorMessage = "Allow Photos access in Settings to save pictures." }
                    return
                }
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with:.photo,data:photoData,options:nil)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        self.isSaving = false
                        if success { self.lastThumbnail = image; self.savedMessage = "Saved to Photos" }
                        else { self.errorMessage = error?.localizedDescription ?? "Saving failed." }
                    }
                }
            }
        }
    }
}
