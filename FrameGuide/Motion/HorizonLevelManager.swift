import CoreMotion
import SwiftUI
import UIKit

@MainActor
final class HorizonLevelManager: ObservableObject {
    @Published private(set) var roll: Double = 0
    private let motion = CMMotionManager()

    func start() {
        guard motion.isDeviceMotionAvailable, !motion.isDeviceMotionActive else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 30.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let gravity = motion?.gravity else { return }
            let orientation = UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.interfaceOrientation }.first ?? .portrait
            let measured: Double
            switch orientation {
            case .landscapeLeft: measured = atan2(gravity.y, -gravity.x)
            case .landscapeRight: measured = atan2(-gravity.y, gravity.x)
            case .portraitUpsideDown: measured = atan2(-gravity.x, gravity.y)
            default: measured = atan2(gravity.x, -gravity.y)
            }
            self?.roll = (self?.roll ?? 0) * 0.75 + measured * 0.25
        }
    }
    func stop() { motion.stopDeviceMotionUpdates() }
}
