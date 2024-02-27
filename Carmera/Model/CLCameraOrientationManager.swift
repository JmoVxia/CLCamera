//
//  CLCameraOrientationManager.swift
//  CLDemo-Swift
//
//  Created by Chen JmoVxia on 2024/2/26.
//

import AVFoundation
import CoreMotion
import UIKit

protocol CLCameraOrientationManagerDelegate: AnyObject {
    func captureOrientation(_ deviceOrientation: CLCameraOrientationManager, didUpdate orientation: CaptureOrientation)
}

class CLCameraOrientationManager: NSObject {
    weak var delegate: CLCameraOrientationManagerDelegate?

    let motionManager = CMMotionManager()

    override init() {
        super.init()
        motionManager.deviceMotionUpdateInterval = 0.5
    }

    func startUpdates() {
        if motionManager.isDeviceMotionAvailable,
           let queue = OperationQueue.current
        {
            motionManager.startDeviceMotionUpdates(to: queue) { motion, _ in
                self.deviceMotion(motion)
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    func deviceMotion(_ motion: CMDeviceMotion?) {
        guard let motion else {
            delegate?.captureOrientation(self, didUpdate: .up)
            return
        }

        let x = motion.gravity.x
        let y = motion.gravity.y

        let angle = atan2(y, x)
        let threshold: Double = .pi / 4 // 45 degrees

        if abs(angle) < threshold {
            if x > 0 {
                delegate?.captureOrientation(self, didUpdate: .right)
            } else {
                delegate?.captureOrientation(self, didUpdate: .left)
            }
        } else {
            if y > 0 {
                delegate?.captureOrientation(self, didUpdate: .down)
            } else {
                delegate?.captureOrientation(self, didUpdate: .up)
            }
        }
    }
}

enum CaptureOrientation {
    case up
    case left
    case down
    case right
}

extension CaptureOrientation {
    var captureVideoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .up:
            .portrait
        case .left:
            .landscapeRight
        case .down:
            .portraitUpsideDown
        case .right:
            .landscapeLeft
        }
    }

    var imageOrientation: UIImage.Orientation {
        switch self {
        case .up:
            .up
        case .left:
            .left
        case .down:
            .down
        case .right:
            .right
        }
    }
}
