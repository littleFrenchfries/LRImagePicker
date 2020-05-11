//
//  PlayerView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/8.
//  Copyright © 2020 wangxu. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override var layer: AVPlayerLayer {
        return super.layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        set {
            layer.player = newValue
        }
        get {
            return layer.player
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.videoGravity = .resizeAspect
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.videoGravity = .resizeAspect
    }
}

