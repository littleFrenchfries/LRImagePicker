//
//  SelectView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/5/6.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class SelectView: UIView {
    
    var settings: Settings!
    
    var selectionIndex: Int? {
        didSet {
            print("\(String(describing: selectionIndex))")
            guard let numberView = icon as? NumberView, let selectionIndex = selectionIndex else { return }
            // Add 1 since selections should be 1-indexed
//            numberView.text = (selectionIndex + 1).description
            numberView.text = "\(String(describing: selectionIndex + 1))"
//            setNeedsDisplay()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                backgroundColor = settings.theme.selectionFillColor
                normal.isHidden = true
            } else {
                if settings != nil {
                    guard let numberView = icon as? NumberView else { return }
                    numberView.text = ""
                }
                normal.isHidden = false
                backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
            }
        }
    }
    
    private lazy var icon: UIView = {
        return NumberView()
    }()
    
    private lazy var normal: UIView = {
        return CheckmarkView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 12.5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 12.5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    override func draw(_ rect: CGRect) {
        //// Frames
        let selectionFrame = bounds;
        
        //// Subframes
        let group = selectionFrame.insetBy(dx: 3, dy: 3)
        
        //// Selection icon
        let largestSquareInCircleInsetRatio: CGFloat = 0.5 - (0.25 * sqrt(2))
        let dx = group.size.width * largestSquareInCircleInsetRatio
        let dy = group.size.height * largestSquareInCircleInsetRatio
        icon.frame = group.insetBy(dx: dx, dy: dy)
        icon.tintColor = settings.theme.selectionStrokeColor
        icon.draw(icon.frame)
        normal.backgroundColor = .clear
        addSubview(normal)
    }
}
