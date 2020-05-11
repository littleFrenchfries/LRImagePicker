//
//  ImagePickerController+Albums.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/1.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos
// Mark: 图片选择器 相册相关管理
extension ImagePickerController: AlbumsViewControllerDelegate {
    func albumsViewController(_ albumsViewController: AlbumsViewController, didSelectAlbum album: PHAssetCollection) {
        select(album: album)
        albumsViewController.dismiss(animated: true)
    }
    
    func didDismissAlbumsViewController(_ albumsViewController: AlbumsViewController) {
        rotateButtonArrow()
    }
    
    func select(album: PHAssetCollection) {
        if let assetsViewController = viewControllers.first as? AssetsViewController {
            assetsViewController.showAssets(in: album)
            albumButton.setTitle((album.localizedTitle ?? "") + " ", for: .normal)
            albumButton.sizeToFit()
        }
    }
}
