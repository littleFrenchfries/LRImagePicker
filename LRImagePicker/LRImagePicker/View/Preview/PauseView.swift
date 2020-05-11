//
//  PauseView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/8.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class PauseView: UIView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = frame.size.width / 2.0
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.size.width * 0.38, y: rect.size.height * 0.3))
        path.addLine(to: CGPoint(x: rect.size.width * 0.73, y: rect.size.height/2.0))
        path.addLine(to: CGPoint(x: rect.size.width * 0.38, y: rect.size.height * 0.7))
        path.close()
        UIColor.white.setStroke()
        UIColor.white.setFill()
        path.stroke()
        path.fill()
    }
}
