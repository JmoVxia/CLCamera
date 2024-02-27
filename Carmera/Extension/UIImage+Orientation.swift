//
//  UIImage+Orientation.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/10.
//

import UIKit

import UIKit

public extension UIImage {
    func rotate(orientation: UIImage.Orientation) -> UIImage {
        func swapWidthHeight(_ rect: inout CGRect) {
            (rect.size.width, rect.size.height) = (rect.size.height, rect.size.width)
        }

        let rect = CGRect(origin: .zero, size: size)
        var bounds = rect
        var transform = CGAffineTransform.identity

        switch orientation {
        case .up:
            return self
        case .upMirrored:
            transform = transform.translatedBy(x: rect.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .down:
            transform = transform.translatedBy(x: rect.width, y: rect.height)
            transform = transform.rotated(by: .pi)
        case .downMirrored:
            transform = transform.translatedBy(x: 0, y: rect.height)
            transform = transform.scaledBy(x: 1, y: -1)
        case .left:
            swapWidthHeight(&bounds)
            transform = transform.translatedBy(x: 0, y: rect.width)
            transform = transform.rotated(by: CGFloat.pi * 3 / 2)
        case .leftMirrored:
            swapWidthHeight(&bounds)
            transform = transform.translatedBy(x: rect.height, y: rect.width)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat.pi * 3 / 2)
        case .right:
            swapWidthHeight(&bounds)
            transform = transform.translatedBy(x: rect.height, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .rightMirrored:
            swapWidthHeight(&bounds)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat.pi / 2)
        @unknown default:
            return self
        }

        UIGraphicsBeginImageContext(bounds.size)
        defer {
            UIGraphicsEndImageContext()
        }

        guard let context = UIGraphicsGetCurrentContext() else { return self }
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.scaleBy(x: -1, y: 1)
            context.translateBy(x: -rect.height, y: 0)
        default:
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -rect.height)
        }
        context.concatenate(transform)
        if let cgImage {
            context.draw(cgImage, in: rect)
        }
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
