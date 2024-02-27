//
//  AppDelegate.swift
//  CLCarmera
//
//  Created by Chen JmoVxia on 2024/2/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = ViewController()
        return true
    }


}

