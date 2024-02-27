//
//  LoadingHUDView.swift
//  CLDemo-Swift
//
//  Created by Chen JmoVxia on 2024/2/26.
//

import UIKit

// MARK: - JmoVxia---枚举

extension LoadingHUDView {}

// MARK: - JmoVxia---类-属性

class LoadingHUDView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        makeConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var contentVisualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.contentView.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).withAlphaComponent(0.6)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .white)
        view.hidesWhenStopped = true
        view.tintColor = .white
        view.style = .whiteLarge
        return view
    }()

    private lazy var progressView: LoadingProgressView = {
        let view = LoadingProgressView()
        view.isHidden = true
        return view
    }()

    private lazy var tipLabel: UILabel = {
        let view = UILabel()
        view.text = "正在处理中"
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
}

// MARK: - JmoVxia---布局

private extension LoadingHUDView {
    func setupUI() {
        addSubview(contentVisualEffectView)
        contentVisualEffectView.contentView.addSubview(progressView)
        contentVisualEffectView.contentView.addSubview(activityIndicator)
        contentVisualEffectView.contentView.addSubview(tipLabel)
    }

    func makeConstraints() {
        contentVisualEffectView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(108)
            make.width.equalTo(140)
        }

        progressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(20)
            make.height.width.equalTo(30)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(progressView.snp.center)
        }

        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
        }
    }
}

// MARK: - JmoVxia---override

extension LoadingHUDView {}

// MARK: - JmoVxia---objc

@objc private extension LoadingHUDView {}

// MARK: - JmoVxia---私有方法

private extension LoadingHUDView {}

// MARK: - JmoVxia---公共方法

extension LoadingHUDView {
    func showLoading() {
        progressView.isHidden = true
        activityIndicator.startAnimating()
    }

    func showProgress(_ progress: CGFloat) {
        progressView.progress = progress
        activityIndicator.stopAnimating()
    }
}
