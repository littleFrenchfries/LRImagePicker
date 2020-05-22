//
//  ArrowView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/31.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class ArrowView: UIView {
    enum ResizingBehavior {
        case aspectFit  /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch    /// The content is stretched to match the entire target rectangle.
        case center     /// The content is centered in the target rectangle, but it is NOT resized.

        func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }

    var resizing: ResizingBehavior = .aspectFit
    var strokeColor: UIColor = .black

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 8, height: 8)
    }

    var asImage: UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.bounds.size)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
    }

    override func draw(_ rect: CGRect) {
        // Get graphics context
        let context = UIGraphicsGetCurrentContext()!

        // Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 8, height: 8), target: rect)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 8, y: resizedFrame.height / 8)

        // Draw shape
        let path = chevronPath()
        strokeColor.setStroke()
        UIColor.white.setFill()
        path.lineWidth = 2
        path.stroke()

        context.restoreGState()
    }

    func chevronPath() -> UIBezierPath {
        let chevronPath = UIBezierPath()
        chevronPath.move(to: CGPoint(x: 0, y: 2))
        chevronPath.addLine(to: CGPoint(x: 4, y: 6))
        chevronPath.addLine(to: CGPoint(x: 8, y: 2))

        return chevronPath
    }
}

