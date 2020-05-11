//
//  BackArrowView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/5/6.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class BackArrowView: UIView {
    var strokeColor: UIColor = .white
    override func draw(_ rect: CGRect) {
        // Get graphics context
        let context = UIGraphicsGetCurrentContext()!

        // Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 20, y: resizedFrame.height / 20)

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
        chevronPath.move(to: CGPoint(x: 30, y: 36))
        chevronPath.addLine(to: CGPoint(x: 20, y: 46))
        chevronPath.addLine(to: CGPoint(x: 30, y: 56))
        return chevronPath
    }
}
