//
//  CLCaptureHelper.swift
//  CLDemo-Swift
//
//  Created by Chen JmoVxia on 2024/2/26.
//

import AVFoundation
import UIKit

protocol CLCaptureHelperDelegate: AnyObject {
    func captureHelper(_ helper: CLCaptureHelper, didOccurredError error: CLCarmeraError)
    func captureHelper(_ helper: CLCaptureHelper, finishTakingPhoto photo: UIImage)
    func captureHelper(_ helper: CLCaptureHelper, finishTakingVideo url: URL)
}

extension CLCaptureHelperDelegate {
    func captureHelper(_ helper: CLCaptureHelper, didOccurredError error: CLCarmeraError) {}
    func captureHelper(_ helper: CLCaptureHelper, finishTakingPhoto photo: UIImage) {}
    func captureHelper(_ helper: CLCaptureHelper, finishTakingVideo url: URL) {}
}

class CLCaptureHelper: NSObject {
    init(captureConfig: CLCameraConfig) {
        self.captureConfig = captureConfig
        super.init()
        configSetting()
    }

    deinit {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    weak var delegate: CLCaptureHelperDelegate?

    private let orientationManager = CLCameraOrientationManager()

    private let sessionQueue = DispatchQueue(label: "com.CameraManager.Session")

    private let movieFileOutputQueue = DispatchQueue(label: "com.CameraManager.Movie")

    private let photoOutputQueue = DispatchQueue(label: "com.CameraManager.Photo")

    private let captureSession = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()

    private let movieFileOutput = AVCaptureMovieFileOutput()

    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var videoDeviceInput: AVCaptureDeviceInput?

    private var audioDeviceInput: AVCaptureDeviceInput?

    private var videoCurrentZoom = 1.0

    private var currentOrientation = CaptureOrientation.up

    private var captureConfig: CLCameraConfig
}

private extension CLCaptureHelper {
    func configSetting() {
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        orientationManager.delegate = self
        sessionQueue.async { [weak self] in
            self?.setupCapture()
            self?.starRunning()
        }
    }

    func setupCapture() {
        captureSession.beginConfiguration()

        let sessionPreset = captureConfig.captureSessionPreset.avSessionPreset
        if captureSession.canSetSessionPreset(sessionPreset) {
            captureSession.sessionPreset = sessionPreset
        } else {
            captureSession.sessionPreset = CLCameraSessionPreset.hd1920x1080.avSessionPreset
        }

        setupDataOutput()
        setupCameraDevice(position: .back)
        setupMicrophoneDevice()

        captureSession.commitConfiguration()
    }

    func setupDataOutput() {
        photoOutput.isHighResolutionCaptureEnabled = true
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        movieFileOutput.movieFragmentInterval = .invalid
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)
        }
    }

    func setupCameraDevice(position: AVCaptureDevice.Position) {
        if let videoDeviceInput = self.videoDeviceInput {
            captureSession.removeInput(videoDeviceInput)
        }
        guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                 mediaType: .video,
                                                                 position: position).devices.first,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice)
        else {
            delegate?.captureHelper(self, didOccurredError: .failedToInitializeCameraDevice)
            return
        }
        self.videoDeviceInput = videoDeviceInput

        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }

        try? videoDevice.lockForConfiguration()

        videoDevice.isSubjectAreaChangeMonitoringEnabled = true
        if videoDevice.isSmoothAutoFocusSupported {
            videoDevice.isSmoothAutoFocusEnabled = true
        }

        if let availableActiveFormat = videoDevice.availableActiveFormat(for: captureConfig) {
            videoDevice.activeFormat = availableActiveFormat
            let frameDuration = CMTime(value: 1, timescale: CMTimeScale(captureConfig.captureVideoFrameRate))
            videoDevice.activeVideoMinFrameDuration = frameDuration
            videoDevice.activeVideoMaxFrameDuration = frameDuration
        }

        if let connection = movieFileOutput.connection(with: .video) {
            let stabilizationMode = captureConfig.captureVideoStabilizationMode.avPreferredVideoStabilizationMode
            connection.preferredVideoStabilizationMode = stabilizationMode
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = position == .front
            }
        }

        if let connection = photoOutput.connection(with: .video) {
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = position == .front
            }
        }

        videoDevice.unlockForConfiguration()
    }

    func setupMicrophoneDevice() {
        guard let audioDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone],
                                                                 mediaType: .audio,
                                                                 position: .unspecified).devices.first,
            let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice)
        else {
            delegate?.captureHelper(self, didOccurredError: .failedToInitializeMicrophoneDevice)
            return
        }
        self.audioDeviceInput = audioDeviceInput
        if captureSession.canAddInput(audioDeviceInput) {
            captureSession.addInput(audioDeviceInput)
        }
    }

    func lockVideoDeviceForConfiguration(_ closure: (AVCaptureDevice) -> Void) {
        guard let videoDeviceInput else { return }
        let captureDevice = videoDeviceInput.device
        try? captureDevice.lockForConfiguration()
        closure(captureDevice)
        captureDevice.unlockForConfiguration()
    }
}

extension CLCaptureHelper {
    func starRunning() {
        orientationManager.startUpdates()
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !captureSession.isRunning {
                captureSession.startRunning()
                zoom(1.0)
            }
        }
    }

    func stopRunning() {
        orientationManager.stopUpdates()
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }
}

extension CLCaptureHelper {
    func setupPreviewLayer(to superView: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = superView.bounds
        superView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
}

extension CLCaptureHelper {
    func capturePhoto() {
        photoOutputQueue.async { [weak self] in
            guard let self else { return }
            let settings = AVCapturePhotoSettings()
            settings.flashMode = captureConfig.captureFlashMode.avFlashMode
            settings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func startRecordingVideo() {
        func createCaptureVideoPath(fileType: CLCameraVideoFileType) -> String {
            let directoryPath = NSTemporaryDirectory() + "CLCamera/" + "Video" + "/"
            if !FileManager.default.fileExists(atPath: directoryPath) {
                try? FileManager.default.createDirectory(at: URL(fileURLWithPath: directoryPath),
                                                         withIntermediateDirectories: true,
                                                         attributes: nil)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD_HH-MM-SS.SSS"
            return directoryPath + dateFormatter.string(from: Date()) + fileType.suffix
        }
        movieFileOutputQueue.async { [weak self] in
            guard let self else { return }
            guard let connection = movieFileOutput.connection(with: .video) else { return }
            let videoPath = createCaptureVideoPath(fileType: captureConfig.captureFileType)
            let fileUrl = URL(fileURLWithPath: videoPath)
            connection.videoOrientation = currentOrientation.captureVideoOrientation
            movieFileOutput.startRecording(to: fileUrl, recordingDelegate: self)
        }
    }

    func stopRecordingVideo() {
        LoadingHUD.showLoading()
        movieFileOutputQueue.async { [weak self] in
            self?.movieFileOutput.stopRecording()
        }
    }
}

extension CLCaptureHelper {
    func switchCamera() {
        if movieFileOutput.isRecording { return }

        guard let videoDeviceInput else { return }
        let currentPosition = videoDeviceInput.device.position
        var toChangePosition = AVCaptureDevice.Position.front
        if currentPosition == .front {
            toChangePosition = .back
        }

        sessionQueue.async { [weak self] in
            self?.captureSession.beginConfiguration()
            self?.setupCameraDevice(position: toChangePosition)
            self?.captureSession.commitConfiguration()
        }
    }

    func prepareForZoom() {
        guard let videoDeviceInput else { return }
        videoCurrentZoom = Double(videoDeviceInput.device.videoZoomFactor)
    }

    func focusAt(_ point: CGPoint) {
        lockVideoDeviceForConfiguration { [weak self] devide in
            guard let previewLayer = self?.previewLayer else { return }
            let cameraPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)

            if devide.isFocusModeSupported(.continuousAutoFocus) {
                devide.focusMode = .continuousAutoFocus
            }
            if devide.isFocusPointOfInterestSupported {
                devide.focusPointOfInterest = cameraPoint
            }
            if devide.isExposurePointOfInterestSupported {
                devide.exposurePointOfInterest = cameraPoint
            }
            if devide.isExposureModeSupported(.continuousAutoExposure) {
                devide.exposureMode = .continuousAutoExposure
            }
        }
    }

    func zoom(_ mulriple: Double) {
        guard let videoDeviceInput else { return }
        let videoMaxZoomFactor = min(5, videoDeviceInput.device.activeFormat.videoMaxZoomFactor)
        let toZoomFactory = max(1, videoCurrentZoom * mulriple)
        let finalZoomFactory = min(toZoomFactory, videoMaxZoomFactor)
        lockVideoDeviceForConfiguration { device in
            device.videoZoomFactor = finalZoomFactory
        }
    }
}

extension CLCaptureHelper: CLCameraOrientationManagerDelegate {
    func captureOrientation(_ deviceOrientation: CLCameraOrientationManager, didUpdate orientation: CaptureOrientation) {
        currentOrientation = orientation
    }
}

extension CLCaptureHelper: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        func createImage(_ data: Data) -> UIImage? {
            guard var image = CIImage(data: data) else { return nil }

            if let source = CGImageSourceCreateWithData(data as CFData, nil),
               let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
               let orlginalOrientation = metadata[kCGImagePropertyOrientation as String] as? Int32
            {
                image = image.oriented(forExifOrientation: orlginalOrientation)
            }

            guard let cgImage = CIContext().createCGImage(image, from: image.extent) else { return nil }
            return UIImage(cgImage: cgImage)
        }
        guard let photoData = photo.fileDataRepresentation(),
              let photo = createImage(photoData)?.rotate(orientation: currentOrientation.imageOrientation)
        else {
            return
        }
        delegate?.captureHelper(self, finishTakingPhoto: photo)
    }
}

extension CLCaptureHelper: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        LoadingHUD.hideLoading()
        DispatchQueue.main.async {
            if let error {
                self.delegate?.captureHelper(self, didOccurredError: .underlying(error))
            } else {
                self.delegate?.captureHelper(self, finishTakingVideo: outputFileURL)
            }
        }
    }
}
