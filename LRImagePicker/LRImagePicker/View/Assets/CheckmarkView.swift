//
//  CheckmarkView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/3.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
// Mark: 对号代码图片
class CheckmarkView: UIView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!

        // Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 20, y: resizedFrame.height / 20)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 7/25.0*rect.size.width, y: 12.5/25.0*rect.size.width))
        path.addLine(to: CGPoint(x: 11/25.0*rect.size.width, y: 16/25.0*rect.size.width))
        path.addLine(to: CGPoint(x: 17.5/25.0*rect.size.width, y: 9.5/25.0*rect.size.width))
        UIColor.white.setStroke()
        UIColor.white.setFill()
        path.lineWidth = 2
        path.stroke()
        context.restoreGState()
    }
}

