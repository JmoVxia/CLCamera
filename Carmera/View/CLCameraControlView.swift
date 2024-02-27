//
//  CLCameraControlView.swift
//  CLDemo-Swift
//
//  Created by Chen JmoVxia on 2024/2/21.
//

import UIKit

protocol CLCameraControlDelegate: AnyObject {
    // exit
    func cameraControlDidClickExit(_ controlView: CLCameraControlView)

    // camera
    func cameraControlDidClickChangeCamera(_ controlView: CLCameraControlView)
    func cameraControlDidPrepareForZoom(_ controlView: CLCameraControlView)
    func cameraControl(_ controlView: CLCameraControlView, didFocusAt point: CGPoint)

    // photo
    func controlViewDidTakePhoto(_ controlView: CLCameraControlView)

    // video
    func controlViewDidBeginTakingVideo(_ controlView: CLCameraControlView)
    func controlViewDidEndTakingVideo(_ controlView: CLCameraControlView)
    func controlView(_ controlView: CLCameraControlView, didChangeVideoZoom zoomScale: Double)
}

class CLCameraControlView: UIView {
    init(captureConfig: CLCameraConfig) {
        self.captureConfig = captureConfig
        super.init(frame: .zero)
        setupUI()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) lazy var previewContentView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusTapGes(_:))))
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(zoomPinchGes(_:))))
        view.backgroundColor = .clear
        return view
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurEffect)
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var cameraButton: CLCameraButton = {
        let view = CLCameraButton()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        tapGesture.isEnabled = captureConfig.allowTakingPhoto
        view.addGestureRecognizer(tapGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        longPressGesture.isEnabled = captureConfig.allowTakingVideo
        longPressGesture.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPressGesture)
        return view
    }()

    private lazy var tipLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.font = UIFont.systemFont(ofSize: 13)
        view.textColor = .white
        view.text = {
            var text = captureConfig.allowTakingPhoto ? "轻触拍照" : ""
            text += captureConfig.allowTakingVideo ? (text.isEmpty ? "按住摄像" : ",按住摄像") : ""
            return text
        }()
        return view
    }()

    private lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.tintColor = .white
        view.setImage(UIImage(named: "capture_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        view.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        return view
    }()

    private lazy var changeCameraButton: UIButton = {
        let view = UIButton()
        view.tintColor = .white
        view.setImage(UIImage(named: "capture_rotate_camera")?.withRenderingMode(.alwaysTemplate), for: .normal)
        view.addTarget(self, action: #selector(changeCameraButtonClick), for: .touchUpInside)
        return view
    }()

    private lazy var focusImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        view.image = UIImage(named: "capture_focus")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .green
        return view
    }()

    private var isFocusing: Bool = false

    private var videoTimer: Timer?

    private var videoRecordTime: Double = 0

    private let captureConfig: CLCameraConfig

    weak var delegate: CLCameraControlDelegate?
}

// MARK: - JmoVxia---布局

private extension CLCameraControlView {
    func setupUI() {
        backgroundColor = .clear
        addSubview(previewContentView)
        addSubview(blurEffectView)
        addSubview(cameraButton)
        addSubview(tipLabel)
        addSubview(cancelButton)
        addSubview(changeCameraButton)
        addSubview(focusImageView)
    }

    func makeConstraints() {
        previewContentView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(cameraButton.snp.top).offset(-30)
        }

        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(previewContentView)
        }

        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(previewContentView.snp.bottom).offset(-30)
        }

        cameraButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }

        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.centerY.equalTo(cameraButton.snp.centerY)
            make.right.equalTo(cameraButton.snp.centerX).multipliedBy(0.5)
        }

        changeCameraButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.centerY.equalTo(cameraButton.snp.centerY)
            make.left.equalTo(cameraButton.snp.centerX).multipliedBy(1.5)
        }
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLCameraControlView {
    func zoomPinchGes(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.numberOfTouches == 2 else { return }
        if gesture.state == .began {
            delegate?.cameraControlDidPrepareForZoom(self)
        }
        delegate?.controlView(self, didChangeVideoZoom: gesture.scale)
    }

    func longPressGesture(_ res: UIGestureRecognizer) {
        switch res.state {
        case .began:
            longPressBegin()
            delegate?.cameraControlDidPrepareForZoom(self)
        case .changed:
            let pointY = res.location(in: cameraButton).y
            var zoom = -pointY / (Double(bounds.width) * 0.15) + 1
            if pointY > 0 {
                zoom = 1
            }
            delegate?.controlView(self, didChangeVideoZoom: zoom)
        default:
            longPressEnd()
        }
    }

    func focusTapGes(_ gesture: UIGestureRecognizer) {
        showFocusAnimationAt(point: gesture.location(in: previewContentView))
    }

    func cancelButtonClick() {
        delegate?.cameraControlDidClickExit(self)
    }

    func tapGesture() {
        delegate?.controlViewDidTakePhoto(self)
    }

    func timeRecord() {
        videoRecordTime += 0.1
        let progress = videoRecordTime / captureConfig.captureMaximumVideoDuration
        if progress > 1 {
            longPressEnd()
        } else {
            cameraButton.updateProgress(progress)
        }
    }

    func changeCameraButtonClick() {
        blurEffectView.effect = UIBlurEffect(style: .regular)
        UIView.transition(with: previewContentView, duration: 0.75, options: .transitionFlipFromLeft) {
            self.blurEffectView.effect = nil
            self.delegate?.cameraControlDidClickChangeCamera(self)
        }
    }

    func hideTipLabel() {
        UIView.animate(withDuration: 0.6) {
            self.tipLabel.alpha = 0
        } completion: { _ in
            self.tipLabel.isHidden = true
            self.tipLabel.alpha = 1
        }
    }
}

// MARK: - JmoVxia---私有方法

private extension CLCameraControlView {
    func longPressBegin() {
        cameraButton.showBeginAnimation()
        videoTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timeRecord), userInfo: nil, repeats: true)
        delegate?.controlViewDidBeginTakingVideo(self)
    }

    func longPressEnd() {
        guard videoRecordTime != .zero else { return }
        videoTimer?.invalidate()
        videoTimer = nil
        videoRecordTime = .zero
        cameraButton.showEndAnimation()
        delegate?.controlViewDidEndTakingVideo(self)
    }
}

// MARK: - JmoVxia---公共方法

extension CLCameraControlView {
    func showRunningAnimation() {
        blurEffectView.effect = UIBlurEffect(style: .regular)
        tipLabel.isHidden = false
        UIView.animate(withDuration: 1.25) {
            self.blurEffectView.effect = nil
        } completion: { _ in
            self.hideTipLabel()
        }
    }

    func showFocusAnimationAt(point: CGPoint) {
        if isFocusing {
            return
        }
        isFocusing = true
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = NSNumber(value: 1.0)
        animation.toValue = NSNumber(value: 0.1)
        animation.autoreverses = true
        animation.duration = 0.3
        animation.repeatCount = 2
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        animation.delegate = self
        focusImageView.layer.add(animation, forKey: nil)

        focusImageView.center = previewContentView.convert(point, to: focusImageView.superview)
        focusImageView.isHidden = false
        focusImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.2) {
            self.focusImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }

        delegate?.cameraControl(self, didFocusAt: point)
    }
}

// MARK: - JmoVxia---CAAnimationDelegate

extension CLCameraControlView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.focusImageView.alpha = 0
        }) { _ in
            self.isFocusing = false
            self.focusImageView.isHidden = true
        }
    }
}
