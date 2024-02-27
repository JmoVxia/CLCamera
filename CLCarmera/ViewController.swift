//
//  ViewController.swift
//  CLCarmera
//
//  Created by Chen JmoVxia on 2024/2/26.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {}

    private lazy var cameraButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = UIColor.purple.withAlphaComponent(0.35)
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 8
        view.setTitle("拍照", for: .normal)
        view.setTitleColor(.orange, for: .normal)
        view.contentEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)
        view.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
        return view
    }()
}

// MARK: - JmoVxia---生命周期

extension ViewController {
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

private extension ViewController {
    func setupUI() {
        view.backgroundColor = .lightGray
        view.addSubview(cameraButton)
    }

    func makeConstraints() {
        cameraButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---数据

private extension ViewController {
    func configData() {}
}

// MARK: - JmoVxia---override

extension ViewController {}

// MARK: - JmoVxia---objc

@objc private extension ViewController {
    func cameraAction() {
        let vc = CLCameraController(config: CLCameraConfig())
        vc.delegate = self
        present(vc, animated: true)
    }
}

extension ViewController: CLCameraControllerDelegate {
    func captureViewController(_ viewController: CLCameraController, didFinishTakingPhoto photo: UIImage) {
        viewController.presentingViewController?.dismiss(animated: true)
    }

    func captureViewController(_ viewController: CLCameraController, didFinishTakingVideo videoUrl: URL) {
        viewController.presentingViewController?.dismiss(animated: true)
    }
}

// MARK: - JmoVxia---私有方法

private extension ViewController {}

// MARK: - JmoVxia---公共方法

extension ViewController {}

