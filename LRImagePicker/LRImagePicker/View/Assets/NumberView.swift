//
//  NumberView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/3.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
// Mark: 用来标记图片被选中的排名
class NumberView: UILabel {

     override var tintColor: UIColor! {
           didSet {
               textColor = tintColor
           }
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       init() {
           super.init(frame: .zero)

           font = UIFont.boldSystemFont(ofSize: 12)
           numberOfLines = 1
           adjustsFontSizeToFitWidth = true
           baselineAdjustment = .alignCenters
           textAlignment = .center
       }
       
       override func draw(_ rect: CGRect) {
           super.drawText(in: rect)
       }

}
