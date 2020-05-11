//
//  CGSize+Scale.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/31.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

extension CGSize {
    func resize(by scale: CGFloat) -> CGSize {
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}
