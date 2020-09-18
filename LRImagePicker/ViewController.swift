//
//  ViewController.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/23.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var uiimageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func singalClick(_ sender: Any) {
        let setting = Settings()
        // Mark: 提供给外部，让外部决定需要什么资源 （照片 视频 音频） 注：默认有照片视频
        setting.fetch.assets.supportedMediaTypes = [.video]
        // Mark: 是否展示3dtouch图片
        setting.fetch.preview.showLivePreview = true
        // Mark: 相册cell的高度
        setting.list.albumsCellH = 58
        setting.fetch.preview.allowCrop = true
        // Mark: cell之间的间隙大小
        setting.list.spacing = 2
        // Mark:cell一行有多少个
        setting.list.cellsPerRow = {(verticalSize, horizontalSize) in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular):
                return 4
            case (.compact, .compact):
                return 5
            case (.regular, .regular):
                return 7
            default:
                return 4
            }
        }
        // Mark: 主题背景颜色 默认白色
        setting.theme.backgroundColor = .white
        // Mark: 主题导航栏颜色 默认白色
        setting.theme.navigationBarColor = .white
        // Mark:  可以选择的最多张数 默认9张
        setting.selection.max = 9
        // Mark:  可以选择最少的张数 默认为1张
        setting.selection.min = 1
        LRImagePicker.go(settings:setting, clipping:{[weak self] image in
            self?.uiimageView.image = image
        },finish: { (assets, isOriginal) in
                print("\(assets)\(isOriginal)")
        })
}
    
}

