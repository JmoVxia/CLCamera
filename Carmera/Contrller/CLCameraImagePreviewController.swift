//
//  CLCaptureImagePreviewController.swift
//  CLDemo-Swift
//
//  Created by Chen JmoVxia on 2024/2/20.
//

import UIKit

// MARK: - JmoVxia---CLCaptureVideoPreviewControllerDelegate

protocol CLCameraImagePreviewControllerDelegate: AnyObject {
    func previewViewController(_ controller: CLCameraImagePreviewController, didClickDoneButtonWithPhoto: UIImage)
}

// MARK: - JmoVxia---类-属性

class CLCameraImagePreviewController: UIViewController {
    init(image: UIImage) {
        photo = image
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        previewImageView.image = image
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.isUserInteractionEnabled = true
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.insetsLayoutMarginsFromSafeArea = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .zero
        view.spacing = 0
        return view
    }()

    private lazy var toolBar: CLCameraPreviewToolBar = {
        let view = CLCameraPreviewToolBar()
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.delegate = self
        return view
    }()

    private lazy var previewStackView: UIStackView = {
        let view = UIStackView()
        view.isUserInteractionEnabled = false
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.insetsLayoutMarginsFromSafeArea = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .zero
        view.spacing = 0
        return view
    }()

    private lazy var previewImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()

    private var photo: UIImage

    weak var delegate: CLCameraImagePreviewControllerDelegate?
}

// MARK: - JmoVxia---生命周期

extension CLCameraImagePreviewController {
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

private extension CLCameraImagePreviewController {
    func setupUI() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(previewStackView)
        mainStackView.addArrangedSubview(toolBar)
        previewStackView.addArrangedSubview(previewImageView)
    }

    func makeConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---数据

private extension CLCameraImagePreviewController {
    func configData() {}
}

// MARK: - JmoVxia---override

extension CLCameraImagePreviewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLCameraImagePreviewController {}

// MARK: - JmoVxia---私有方法

private extension CLCameraImagePreviewController {}

// MARK: - JmoVxia---公共方法

extension CLCameraImagePreviewController {}

// MARK: - JmoVxia---CLCapturePreviewToolBarDelegate

extension CLCameraImagePreviewController: CLCameraPreviewToolBarDelegate {
    func toolBarDidClickCancelButton(_ toolBar: CLCameraPreviewToolBar) {
        dismiss(animated: false, completion: nil)
    }

    func toolBarDidClickDoneButton(_ toolBar: CLCameraPreviewToolBar) {
        delegate?.previewViewController(self, didClickDoneButtonWithPhoto: photo)
    }
}
