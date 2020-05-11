//
//  originalView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/5/8.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class OriginalView: UIView {
    
    var settings: Settings!
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                backgroundColor = settings.theme.selectionFillColor
                icon.isHidden = false
            } else {
                backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
                icon.isHidden = true
            }
        }
    }
    
    
    private lazy var icon: UIView = {
        return CheckmarkView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    override func draw(_ rect: CGRect) {
        icon.backgroundColor = .clear
        addSubview(icon)
    }

}
