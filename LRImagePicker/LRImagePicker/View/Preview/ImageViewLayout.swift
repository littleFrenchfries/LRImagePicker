//
//  ImageViewLayout.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/8.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

struct ImageViewLayout {
    static func frameForImageWithSize(_ image: CGSize, previousFrame: CGRect, inContainerWithSize container: CGSize, usingContentMode contentMode: UIView.ContentMode) -> CGRect {
        let size = sizeForImage(image, previousSize: previousFrame.size, container: container, contentMode: contentMode)
        let position = positionForImage(size, previousPosition: previousFrame.origin, container: container, contentMode: contentMode)

        return CGRect(origin: position, size: size)
    }

    private static func sizeForImage(_ image: CGSize, previousSize: CGSize, container: CGSize, contentMode: UIView.ContentMode) -> CGSize {
        switch contentMode {
        case .scaleToFill:
            return container
        case .scaleAspectFit:
            let heightRatio = imageHeightRatio(image, container: container)
            let widthRatio = imageWidthRatio(image, container: container)
            return scaledImageSize(image, ratio: max(heightRatio, widthRatio))
        case .scaleAspectFill:
            let heightRatio = imageHeightRatio(image, container: container)
            let widthRatio = imageWidthRatio(image, container: container)
            return scaledImageSize(image, ratio: min(heightRatio, widthRatio))
        case .redraw:
            return previousSize
        default:
            return image
        }
    }

    private static func positionForImage(_ image: CGSize, previousPosition: CGPoint, container: CGSize, contentMode: UIView.ContentMode) -> CGPoint {
        switch contentMode {
        case .scaleToFill:
            return .zero
        case .scaleAspectFit:
            return CGPoint(x: (container.width - image.width) / 2, y: (container.height - image.height) / 2)
        case .scaleAspectFill:
            return CGPoint(x: (container.width - image.width) / 2, y: (container.height - image.height) / 2)
        case .redraw:
            return previousPosition
        case .center:
            return CGPoint(x: (container.width - image.width) / 2, y: (container.height - image.height) / 2)
        case .top:
            return CGPoint(x: (container.width - image.width) / 2, y: 0)
        case .bottom:
            return CGPoint(x: (container.width - image.width) / 2, y: container.height - image.height)
        case .left:
            return CGPoint(x: 0, y: (container.height - image.height) / 2)
        case .right:
            return CGPoint(x: container.width - image.width, y: (container.height - image.height) / 2)
        case .topLeft:
            return .zero
        case .topRight:
            return CGPoint(x: container.width - image.width, y: 0)
        case .bottomLeft:
            return CGPoint(x: 0, y: container.height - image.height)
        case .bottomRight:
            return CGPoint(x: container.width - image.width, y: container.height - image.height)
        @unknown default:
            return .zero
        }
    }

    private static func imageHeightRatio(_ image: CGSize, container: CGSize) -> CGFloat {
        return image.height / container.height
    }

    private static func imageWidthRatio(_ image: CGSize, container: CGSize) -> CGFloat {
        return image.width / container.width
    }

    private static func scaledImageSize(_ image: CGSize, ratio: CGFloat) -> CGSize {
        return CGSize(width: image.width / ratio, height: image.height / ratio)
    }
}
