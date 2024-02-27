//
//  CLCameraConfig.swift
//  CLDemo-Swift
//
//  Created by Chen JmoVxia on 2024/2/26.
//

import UIKit

struct CLCameraConfig {
    // 是否允许拍摄照片
    var allowTakingPhoto = true

    // 是否允许拍摄视频
    var allowTakingVideo = true

    // 视频拍摄最长时长
    var captureMaximumVideoDuration: TimeInterval = 5

    // 拍摄闪光灯开关
    var captureFlashMode = CLCameraFlashMode.off

    // 视频拍摄格式
    var captureFileType = CLCameraVideoFileType.mp4

    // 视频拍摄帧率
    var captureVideoFrameRate: Double = 60

    // 视频拍摄预设
    var captureSessionPreset: CLCameraSessionPreset = .hd4K3840x2160

    // 视频拍摄防抖模式
    var captureVideoStabilizationMode: CLCameraVideoStabilizationMode = .off
}
