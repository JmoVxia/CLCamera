//
//  AVCaptureDevice+Extensions.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/1/4.
//

import AVFoundation
import UIKit

extension AVCaptureDevice {
    func availableActiveFormat(for captureConfig: CLCameraConfig) -> AVCaptureDevice.Format? {
        let formats = formats.filter { format in
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let presetSize = captureConfig.captureSessionPreset.size

            let sizeSupport = CGFloat(dimensions.width) == presetSize.width && CGFloat(dimensions.height) == presetSize.height

            let frameRateSupport = format.videoSupportedFrameRateRanges.filter {
                $0.maxFrameRate >= captureConfig.captureVideoFrameRate
            }.count > 0

            let stabilizationMode = captureConfig.captureVideoStabilizationMode.avPreferredVideoStabilizationMode
            let stabilizationModeSupport = format.isVideoStabilizationModeSupported(stabilizationMode)

            return sizeSupport && frameRateSupport && stabilizationModeSupport
        }
        return formats.last
    }
}
