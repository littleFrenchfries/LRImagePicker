//
//  GradientView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/30.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

// Mark: - 可以颜色渐变的UIView
class GradientView: UIView {
    // Mark: -重写类属性 layerClass 把图层直接替换为 CAGradientLayer
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    // Mark: 用于处理渐变颜色的layer
    override var layer: CAGradientLayer {
        super.layer as! CAGradientLayer
    }
    // Mark: - 渐变颜色都有哪些
    var colors: [UIColor]? {
        get {
            let layerColors = layer.colors as? [CGColor]
            return layerColors?.map { UIColor(cgColor: $0) }
        } set {
            layer.colors = newValue?.map { $0.cgColor }
        }
    }
    // Mark: - 表示的是颜色在Layer坐标系相对位置处要开始进行渐变颜色了.[0.25, 0.5, 0.75];
    open var locations: [NSNumber]? {
        get {
            layer.locations
        } set {
            layer.locations = newValue
        }
    }
    // Mark: -颜色渐变的起始点CGPoint(x: 0, y: 0)
    open var startPoint:CGPoint {
        get {
            layer.startPoint
        }
        set {
            layer.startPoint = newValue
        }
    }
    // Mark: - 颜色渐变的结束点CGPoint(x: 1, y: 0)
    open var endPoint:CGPoint {
        get {
            layer.endPoint
        }
        set {
            layer.endPoint = newValue
        }
    }
}

