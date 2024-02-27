//
//  CLCameraPreviewToolBar.swift
//  CLDemo-Swift
//
//  Created by Chen JmoVxia on 2024/2/19.
//

import UIKit

protocol CLCameraPreviewToolBarDelegate: AnyObject {
    func toolBarDidClickCancelButton(_ toolBar: CLCameraPreviewToolBar)
    func toolBarDidClickDoneButton(_ toolBar: CLCameraPreviewToolBar)
}

// MARK: - JmoVxia---枚举

extension CLCameraPreviewToolBar {}

// MARK: - JmoVxia---类-属性

class CLCameraPreviewToolBar: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.isUserInteractionEnabled = true
        view.axis = .horizontal
        view.distribution = .equalSpacing
        view.alignment = .center
        view.insetsLayoutMarginsFromSafeArea = true
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(top: 30, left: 16, bottom: 30, right: 16)
        view.spacing = 0
        return view
    }()

    private lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.setTitle("取消", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        return view
    }()

    private lazy var doneButton: UIButton = {
        let view = UIButton()
        view.setTitle("确定", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        return view
    }()

    weak var delegate: CLCameraPreviewToolBarDelegate?
}

// MARK: - JmoVxia---布局

private extension CLCameraPreviewToolBar {
    func setupUI() {
        backgroundColor = .black
        addSubview(mainStackView)
        mainStackView.addArrangedSubview(cancelButton)
        mainStackView.addArrangedSubview(doneButton)
    }

    func makeConstraints() {
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        doneButton.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---override

extension CLCameraPreviewToolBar {}

// MARK: - JmoVxia---objc

@objc private extension CLCameraPreviewToolBar {
    func cancelButtonClick() {
        delegate?.toolBarDidClickCancelButton(self)
    }

    func doneButtonClick() {
        delegate?.toolBarDidClickDoneButton(self)
    }
}

// MARK: - JmoVxia---私有方法

private extension CLCameraPreviewToolBar {}

// MARK: - JmoVxia---公共方法

extension CLCameraPreviewToolBar {}
