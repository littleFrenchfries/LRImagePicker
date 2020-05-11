//
//  ImagePickerController+ButtonActions.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/31.
//  Copyright © 2020 wangxu. All rights reserved.
//
import UIKit
// Mark:  图片选择器按钮点击方法管理
extension ImagePickerController {
    func albumsButtonPressed(_ sender: UIButton) {
        rotateButtonArrow()
        LRImagePicker.goAlbums(settings: settings, albums: albums, delegate: self)
    }
    func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func rotateButtonArrow() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let imageView = self?.albumButton.imageView else { return }
            imageView.transform = imageView.transform.rotated(by: .pi)
        }
    }
}
