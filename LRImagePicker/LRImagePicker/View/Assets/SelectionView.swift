//
//  SelectionView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/3.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class SelectionView: UIView {

    var settings: Settings!
    
    var selectionIndex: Int? {
        didSet {
            guard let numberView = icon as? NumberView, let selectionIndex = selectionIndex else { return }
            // Add 1 since selections should be 1-indexed
            numberView.text = (selectionIndex + 1).description
            setNeedsDisplay()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                backgroundColor = settings.theme.selectionFillColor
            } else {
                if settings != nil {
                    guard let numberView = icon as? NumberView else { return }
                    numberView.text = ""
                }
                backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
            }
        }
    }
    
    
    private lazy var icon: UIView = {
        switch settings.theme.selectionStyle {
        case .checked:
            return CheckmarkView()
        case .numbered:
            return NumberView()
        }
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
    }

}
