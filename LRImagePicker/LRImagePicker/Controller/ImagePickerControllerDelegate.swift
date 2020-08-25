//
//  ImagePickerControllerDelegate.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/2.
//  Copyright © 2020 wangxu. All rights reserved.
//

import Foundation
import UIKit
import Photos

// Mark:  Delegate of the image picker
public protocol ImagePickerControllerDelegate: class {
    /// 相片被选中
    /// - Parameter asset: 选中的相片
    func imagePicker(didSelectAsset asset: PHAsset)

    /// 相片被取消选中
    /// - Parameter asset: 取消选中的相片
    func imagePicker(didDeselectAsset asset: PHAsset)

    /// 用户点击完成之后的相片
    /// - Parameter assets: 选中的相片
    func imagePicker(didFinishWithAssets assets: [PHAsset], isOriginal:Bool)

    /// 用户点击取消按钮之后的相片
    /// - Parameter assets: 取消选中的相片
    func imagePicker(didCancelWithAssets assets: [PHAsset])
    /// 用户裁剪之后的相片
    /// - Parameter assets: 裁剪的相片
    func imagePicker(didClippingWithImage image: UIImage)
}
