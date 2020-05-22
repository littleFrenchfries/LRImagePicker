//
//  PreviewCollectionViewDataSource.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/7.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos

class PreviewCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    private let imageManager = PHCachingImageManager.default()
    private let fetchResult: PHFetchResult<PHAsset>
    private let scale: CGFloat
    var settings: Settings!
    init(fetchResult: PHFetchResult<PHAsset>, scale: CGFloat = UIScreen.main.scale) {
        self.fetchResult = fetchResult
        // Mark:  1 320 x *  2 640 x *  3 1242 x *
        self.scale = scale
        super.init()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult[indexPath.row]
        let cell: PreviewCollectionViewCell
        if #available(iOS 9.1, *) {
            switch (asset.mediaType, asset.mediaSubtypes) {
            case (.video, _):
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(VideoPreviewCollectionViewCell.self), for: indexPath) as! VideoPreviewCollectionViewCell
                if !settings.fastMode {
                    loadVieo(for: asset, in: cell as? VideoPreviewCollectionViewCell)
                }
            case (.image, .photoLive):
                if settings.fetch.preview.showLivePreview {
                    cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(LivePreviewCollectionViewCell.self), for: indexPath) as! LivePreviewCollectionViewCell
                    if !settings.fastMode {
                        load3dImage(for: asset, in: cell as? LivePreviewCollectionViewCell)
                    }
                }else {
                    cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PreviewCollectionViewCell.self), for: indexPath) as! PreviewCollectionViewCell
                    if !settings.fastMode {
                        loadImage(for: asset, in: cell)
                    }
                }
            default:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PreviewCollectionViewCell.self), for: indexPath) as! PreviewCollectionViewCell
                if !settings.fastMode {
                    loadImage(for: asset, in: cell)
                }
            }
        } else {
            switch (asset.mediaType, asset.mediaSubtypes) {
            case (.video, _):
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(VideoPreviewCollectionViewCell.self), for: indexPath) as! VideoPreviewCollectionViewCell
                if !settings.fastMode {
                    loadVieo(for: asset, in: cell as? VideoPreviewCollectionViewCell)
                }
            case (.image, _):
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PreviewCollectionViewCell.self), for: indexPath) as! PreviewCollectionViewCell
                if !settings.fastMode {
                    loadImage(for: asset, in: cell)
                }
            default:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PreviewCollectionViewCell.self), for: indexPath) as! PreviewCollectionViewCell
                if !settings.fastMode {
                    loadImage(for: asset, in: cell)
                }
            }
        }
        return cell
    }
    
    /// 加载图片【概述】
    ///
    /// - Parameter asset
    /// - Parameter cell
    ///
    func loadImage(for asset: PHAsset, in cell: PreviewCollectionViewCell?) {
        // Mark:  取消滑出屏幕外的图片请求
        if let cell = cell, cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        // Mark:  计算图片大小
        if let cell = cell {
            cell.settings = settings
            // Mark: 根据图片大小请求图片
            let targetSize = settings.fetch.preview.getPriviewSize(originSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight))
            cell.tag = Int(imageManager.requestImage(for: asset, targetSize: targetSize , contentMode: .aspectFill, options: settings.fetch.preview.photoOptions) { [weak cell](image, _) in
                guard let image = image else { return }
                cell?.imageView.image = image
            })
        }
    }
    
    /// 加载3dtouch图片【概述】
    ///
    /// - Parameter asset
    /// - Parameter cell
    ///
    @available(iOS 9.1, *)
    func load3dImage(for asset: PHAsset, in cell: LivePreviewCollectionViewCell?) {
        // Mark:  取消滑出屏幕外的图片请求
        if let cell = cell, cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        // Mark:  计算图片大小
        if let cell = cell {
            cell.settings = settings
            // Mark: 根据图片大小请求图片
            let targetSize = cell.livePhotoView.frame.size.resize(by: UIScreen.main.scale)
            cell.tag = Int(imageManager.requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: settings.fetch.preview.livePhotoOptions) {[weak cell](livePhoto, _)  in
                guard let livePhoto = livePhoto else { return }
                cell?.livePhotoView.livePhoto = livePhoto
                cell?.positionBadgeView(for: livePhoto)
            })
        }
    }
    
    func cancelImageRequest(id: Int) {
        imageManager.cancelImageRequest(PHImageRequestID(id))
    }
    
    /// 加载视频【概述】
    ///
    /// - Parameter asset
    /// - Parameter cell
    ///
    func loadVieo(for asset: PHAsset, in cell: VideoPreviewCollectionViewCell?) {
        // Mark:  取消滑出屏幕外的图片请求
        if let cell = cell, cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        // Mark:  计算图片大小
        if let cell = cell {
            cell.settings = settings
        }
        // Mark: 根据图片大小请求图片
        cell?.tag = Int(imageManager.requestAVAsset(forVideo: asset, options: settings.fetch.preview.videoOptions) { [weak cell](avasset, audioMix, arguments) in
            guard let avasset = avasset as? AVURLAsset else { return }
            DispatchQueue.main.async { [weak cell] in
                cell?.player = AVPlayer(url: avasset.url)
                cell?.updateState(.paused, animated: false)
            }
        })
    }
    
    static func registerCellIdentifiersForCollectionView(_ collectionView: UICollectionView?) {
        collectionView?.register(PreviewCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(PreviewCollectionViewCell.self))
        collectionView?.register(VideoPreviewCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(VideoPreviewCollectionViewCell.self))
        if #available(iOS 9.1, *) {
            collectionView?.register(LivePreviewCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(LivePreviewCollectionViewCell.self))
        }
    }
}

