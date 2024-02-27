//
//  LoadingHUD.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/29.
//

import UIKit

class LoadingHUD {
    static let shared = LoadingHUD()

    private var window: UIWindow?

    private weak var loadingView: LoadingHUDView?

    private init() {}
}

private extension LoadingHUD {
    static func createWindow() {
        shared.window = UIWindow(frame: UIScreen.main.bounds)
        shared.window?.backgroundColor = .clear
        shared.window?.isHidden = false

        let view = LoadingHUDView(frame: UIScreen.main.bounds)
        shared.window?.addSubview(view)
        shared.loadingView = view
    }
}

extension LoadingHUD {
    static func showLoading() {
        if shared.loadingView == nil { createWindow() }
        shared.loadingView?.showLoading()
    }

    static func showProgress(_ progress: CGFloat) {
        if shared.loadingView == nil { createWindow() }
        shared.loadingView?.showProgress(progress)
    }

    static func hideLoading() {
        shared.window = nil
    }
}
