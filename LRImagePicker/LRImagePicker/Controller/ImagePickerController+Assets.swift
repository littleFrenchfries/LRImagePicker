//
//  ImagePickerController+Assets.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/7.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos
// Mark: 图片选择器 相册相关管理
extension ImagePickerController: AssetsViewControllerDelegate, PreviewCollectionViewControllerDelegate, MCClipImageViewControllerDelegate {
    func MCClipImageDidCancel() {
        dismiss(animated: true)
    }
    
    func MCClipImageClipping(image: UIImage) {
        imagePickerDelegate?.imagePicker(didClippingWithImage: image)
        dismiss(animated: true)
    }
    
    func assetsViewController(_ assetsViewController: AssetsViewController, didSelectAsset asset: PHAsset) {
        imagePickerDelegate?.imagePicker(didSelectAsset: asset)
        assetsViewController.toolFootView.sendBtnIndex = assetsViewController.store.count
    }
    
    func assetsViewController(_ assetsViewController: AssetsViewController, didDeselectAsset asset: PHAsset) {
        imagePickerDelegate?.imagePicker(didDeselectAsset: asset)
        assetsViewController.toolFootView.sendBtnIndex = assetsViewController.store.count
    }
    
    func assetsViewController(_ assetsViewController: AssetsViewController, didLookUp asset: PHAsset) {
        let previewVC = PreviewCollectionViewController(store: assetsViewController.store)
        previewVC.store = assetsViewController.store
        previewVC.settings = settings
        previewVC.isSelected = true
        previewVC.selectedIndex = 0
        previewVC.indexPathsForSelectedItems = assetsViewController.collectionView.indexPathsForSelectedItems
        previewVC.isOriginal = assetsViewController.toolFootView.icon.isSelected
        previewVC.delegate = self
        previewVC.toolFootView.sendBtnIndex = assetsViewController.store.count
        //        zoomTransitionDelegate.zoomedOutView = cell.imageView
        //        zoomTransitionDelegate.zoomedInView = previewVC.imageView
        pushViewController(previewVC, animated: true)
    }
    
    func assetsViewController(_ assetsViewController: AssetsViewController, toClipping asset: PHAsset) {
        let vc = MCClipImageViewController(asset: asset)
        vc.delegate = self
        pushViewController(vc, animated: true)
    }
    
    func assetsViewController(_ assetsViewController: AssetsViewController, didSend assets: [PHAsset]) {
        imagePickerDelegate?.imagePicker(didFinishWithAssets: assets, isOriginal: assetsViewController.toolFootView.icon.isSelected)
        dismiss(animated: true)
    }
    
    func previewCollectionViewController(_ previewCollectionViewController: PreviewCollectionViewController, didSend assets: [PHAsset]) {
        imagePickerDelegate?.imagePicker(didFinishWithAssets: assets, isOriginal: previewCollectionViewController.toolFootView.icon.isSelected)
        dismiss(animated: true)
    }
    
    
    func assetsViewController(_ assetsViewController: AssetsViewController, didPressCell cell: AssetCollectionViewCell, displayingAsset asset: PHAsset, indexPath: IndexPath) {
        let previewVC = PreviewCollectionViewController(store: assetsViewController.store)
        previewVC.fetchResult = assetsViewController.fetchResult
        previewVC.store = assetsViewController.store
        previewVC.settings = settings
        previewVC.isSelected = cell.isSelected
        previewVC.selectedIndex = indexPath.row
        previewVC.indexPathsForSelectedItems = assetsViewController.collectionView.indexPathsForSelectedItems
        previewVC.isOriginal = assetsViewController.toolFootView.icon.isSelected
        previewVC.delegate = self
        previewVC.toolFootView.sendBtnIndex = assetsViewController.store.count
//        zoomTransitionDelegate.zoomedOutView = cell.imageView
//        zoomTransitionDelegate.zoomedInView = previewVC.imageView
        pushViewController(previewVC, animated: true)
    }
    func previewCollectionViewController(_ previewCollectionViewController: PreviewCollectionViewController, didSelectAsset asset: PHAsset, at indexPath: IndexPath) {
        if let assetsViewController = viewControllers.first as? AssetsViewController {
            assetsViewController.selectphotoCell(at: indexPath)
            assetsViewController.toolFootView.sendBtnIndex = assetsViewController.store.count
        }
        imagePickerDelegate?.imagePicker(didSelectAsset: asset)
    }
    
    func previewCollectionViewController(_ previewCollectionViewController: PreviewCollectionViewController, didDeselectAsset asset: PHAsset, at indexPath: IndexPath) {
        if let assetsViewController = viewControllers.first as? AssetsViewController {
            assetsViewController.deletephotoCell(at: indexPath)
            assetsViewController.toolFootView.sendBtnIndex = assetsViewController.store.count
        }
        imagePickerDelegate?.imagePicker(didDeselectAsset: asset)
    }
    func previewCollectionViewControllerDissmiss(_ previewCollectionViewController: PreviewCollectionViewController) {
        if let assetsViewController = viewControllers.first as? AssetsViewController {
            assetsViewController.toolFootView.icon.isSelected = previewCollectionViewController.toolFootView.icon.isSelected
        }
    }
}
