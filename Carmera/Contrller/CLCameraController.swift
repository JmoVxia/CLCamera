//
//  CLCameraViewControllerDelegate.swift
//  CLDemo-Swift
//
//  Created by Chen JmoVxia on 2024/2/26.
//

import UIKit

// MARK: - JmoVxia---CLCameraViewControllerDelegate

protocol CLCameraControllerDelegate: AnyObject {
    func captureViewController(_ viewController: CLCameraController, didFinishTakingPhoto photo: UIImage)

    func captureViewController(_ viewController: CLCameraController, didFinishTakingVideo videoUrl: URL)
}

// MARK: - JmoVxia---类-属性

class CLCameraController: UIViewController {
    init(config: CLCameraConfig) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
        self.config = config
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
    }

    private lazy var controlView: CLCameraControlView = {
        let view = CLCameraControlView(captureConfig: config)
        view.delegate = self
        return view
    }()

    private lazy var manager: CLCaptureHelper = {
        let helper = CLCaptureHelper(captureConfig: config)
        helper.delegate = self
        return helper
    }()

    private var config: CLCameraConfig!

    weak var delegate: CLCameraControllerDelegate?
}

// MARK: - JmoVxia---生命周期

extension CLCameraController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        makeConstraints()
        configData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

// MARK: - JmoVxia---布局

private extension CLCameraController {
    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(controlView)
    }

    func makeConstraints() {
        controlView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---数据

private extension CLCameraController {
    func configData() {
        CLPermissions.request([.camera, .microphone]) { state in
            guard CLPermissions.isAllowed(.camera) else { return self.showError(.cameraPermissionDenied) }
            guard CLPermissions.isAllowed(.microphone) else { return self.showError(.microphonePermissionDenied) }
            DispatchQueue.main.async {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.setupManager()
                self.startRunning()
                self.controlView.showRunningAnimation()
            }
        }
    }
}

// MARK: - JmoVxia---override

extension CLCameraController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLCameraController {}

// MARK: - JmoVxia---私有方法

private extension CLCameraController {
    func setupManager() {
        manager.setupPreviewLayer(to: controlView.previewContentView)
    }

    func startRunning() {
        controlView.showFocusAnimationAt(point: controlView.previewContentView.center)
        manager.starRunning()
    }

    func stopRunning() {
        manager.stopRunning()
    }

    func showError(_ error: CLCarmeraError) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - JmoVxia---公共方法

extension CLCameraController {}

// MARK: - JmoVxia---CLCaptureHelperDelegate

extension CLCameraController: CLCaptureHelperDelegate {
    func captureHelper(_ helper: CLCaptureHelper, didOccurredError error: CLCarmeraError) {
        showError(error)
    }

    func captureHelper(_ helper: CLCaptureHelper, finishTakingPhoto photo: UIImage) {
        let controller = CLCameraImagePreviewController(image: photo)
        controller.delegate = self
        present(controller, animated: false, completion: nil)
    }

    func captureHelper(_ helper: CLCaptureHelper, finishTakingVideo url: URL) {
        let controller = CLCameraVideoPreviewController(url: url)
        controller.delegate = self
        present(controller, animated: false, completion: nil)
    }
}

// MARK: - JmoVxia---CLCameraControlDelegate

extension CLCameraController: CLCameraControlDelegate {
    func cameraControlDidClickExit(_ controlView: CLCameraControlView) {
        dismiss(animated: true, completion: nil)
    }

    func cameraControlDidClickChangeCamera(_ controlView: CLCameraControlView) {
        manager.switchCamera()
    }

    func cameraControl(_ controlView: CLCameraControlView, didFocusAt point: CGPoint) {
        manager.focusAt(point)
    }

    func controlViewDidTakePhoto(_ controlView: CLCameraControlView) {
        manager.capturePhoto()
    }

    func controlViewDidBeginTakingVideo(_ controlView: CLCameraControlView) {
        manager.startRecordingVideo()
    }

    func controlViewDidEndTakingVideo(_ controlView: CLCameraControlView) {
        manager.stopRecordingVideo()
    }

    func cameraControlDidPrepareForZoom(_ controlView: CLCameraControlView) {
        manager.prepareForZoom()
    }

    func controlView(_ controlView: CLCameraControlView, didChangeVideoZoom zoomScale: Double) {
        manager.zoom(zoomScale)
    }
}

// MARK: - JmoVxia---CLCaptureImagePreviewControllerDelegate

extension CLCameraController: CLCameraImagePreviewControllerDelegate {
    func previewViewController(_ controller: CLCameraImagePreviewController, didClickDoneButtonWithPhoto: UIImage) {
        controller.presentingViewController?.dismiss(animated: true)
    }
}

// MARK: - JmoVxia---CLCameraControlDelegate

extension CLCameraController: CLCameraVideoPreviewControllerDelegate {
    func previewViewController(_ controller: CLCameraVideoPreviewController, didClickDoneButtonWithVideoUrl: URL) {
        controller.presentingViewController?.dismiss(animated: true)
    }
}
