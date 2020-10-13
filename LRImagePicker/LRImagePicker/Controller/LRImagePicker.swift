//
//  LRImagePicker.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/2.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos
// Mark: 开放类
public class LRImagePicker {
    private static let dropdownTransitionDelegate = DropdownTransitionDelegate()
    // MARK: Internal properties
    static var onSelection: ((_ asset: PHAsset) -> Void)?
    static var onDeselection: ((_ asset: PHAsset) -> Void)?
    static var onCancel: ((_ assets: [PHAsset]) -> Void)?
    static var onFinish: ((_ assets: [PHAsset], _ isOriginal: Bool) -> Void)?
    static var onClipping: ((_ image: UIImage) -> Void)?
    // Mark: - 跳转到照片选择器
    public static func go(settings: Settings? = nil, animated: Bool = true, select: ((_ asset: PHAsset) -> Void)? = nil, clipping: ((_ image: UIImage) -> Void)? = nil, deselect: ((_ asset: PHAsset) -> Void)? = nil, cancel: (([PHAsset]) -> Void)? = nil, finish: ((_ assets: [PHAsset], _ isOriginal: Bool) -> Void)? = nil, completion: (() -> Void)? = nil) {
        authorize {
            let set: Settings
            if settings == nil {
                set = Settings()
            }else {
                set = settings!
            }
            let imagePicker = ImagePickerController(settings: set)
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            imagePicker.imagePickerDelegate = imagePicker
            onSelection = select
            onDeselection = deselect
            onCancel = cancel
            onFinish = finish
            onClipping = clipping
            currentViewController?.present(imagePicker, animated: animated, completion: completion)
        }
    }
    
    // Mark: -请求用户授权
    private static func authorize(_ authorized: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.async(execute: authorized)
            default:
                break
            }
        }
    }
    // Mark: - 查询用户授权
    public static var currentAuthorization : PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    // Mark: -取出当前手机屏幕显示的界面
    static var currentViewController: UIViewController? {
        var resultVC: UIViewController?
        if #available(iOS 13.0, *) {
            let window = (UIApplication.shared.connectedScenes.first?.delegate as? UIWindowSceneDelegate)?.window
             resultVC = _topVC(window??.rootViewController)
        } else {
            let window = UIApplication.shared.windows.first
            resultVC = _topVC(window?.rootViewController)
            // Fallback on earlier versions
        }
        if resultVC == nil {
            resultVC = _topVC(UIApplication.shared.keyWindow?.rootViewController)
        }
        while resultVC?.presentedViewController != nil {
            resultVC = _topVC(resultVC?.presentedViewController)
        }
        return resultVC
    }
    private static func _topVC(_ vc: UIViewController?) -> UIViewController? {
        if vc is UINavigationController {
            return _topVC((vc as? UINavigationController)?.topViewController)
        } else if vc is UITabBarController {
            return _topVC((vc as? UITabBarController)?.selectedViewController)
        } else {
            return vc
        }
    }
    
    // Mark: - 跳转到相册控制器
    static func goAlbums(settings: Settings, albums:[PHAssetCollection], delegate: AlbumsViewControllerDelegate) {
        let albumsVC = AlbumsViewController()
        albumsVC.albums = albums
        albumsVC.delegate = delegate
        albumsVC.settings = settings
        albumsVC.transitioningDelegate = dropdownTransitionDelegate
        albumsVC.modalPresentationStyle = .custom
        currentViewController?.present(albumsVC, animated: true)
    }
}

extension ImagePickerController: ImagePickerControllerDelegate {
    public func imagePicker(didClippingWithImage image: UIImage) {
        LRImagePicker.onClipping?(image)
    }
    
    public func imagePicker(didSelectAsset asset: PHAsset) {
        LRImagePicker.onSelection?(asset)
    }
    
    public func imagePicker(didDeselectAsset asset: PHAsset) {
        LRImagePicker.onDeselection?(asset)
    }
    
    public func imagePicker(didFinishWithAssets assets: [PHAsset], isOriginal: Bool) {
        LRImagePicker.onFinish?(assets, isOriginal)
    }
    
    public func imagePicker(didCancelWithAssets assets: [PHAsset]) {
        LRImagePicker.onCancel?(assets)
    }
}
