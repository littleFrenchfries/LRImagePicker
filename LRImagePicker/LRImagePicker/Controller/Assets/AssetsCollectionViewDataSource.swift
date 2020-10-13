//
//  AssetsCollectionViewDataSource.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/30.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class AssetsCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var settings: Settings!
    // Mark: 相册里的资源
    private let fetchResult: PHFetchResult<PHAsset>
    // Mark: 图片加载工具
    private let imageManager = PHCachingImageManager.default()
    // Mark: 图片的尺寸
    private var targetSize: CGSize = .zero
    // Mark: 计算时间差
    private let durationFormatter = DateComponentsFormatter()
    // Mark:  1 320 x *  2 640 x *  3 1242 x * 屏幕分辨率
    private let scale: CGFloat
    /// 初始化【概述】
    /// - Parameter fetchResult: 相册资源
    /// - Parameter scale: 第2个整数
    private let store: AssetStore
    init(fetchResult: PHFetchResult<PHAsset>, store: AssetStore, scale: CGFloat = UIScreen.main.scale) {
        self.fetchResult = fetchResult
        self.scale = scale
        // Mark: 例如，1小时10分钟在美国英语地区显示为“1:10:00”。
        durationFormatter.unitsStyle = .positional
        // Mark: 设置时间为01:00:10格式 不够两位的用0占位
        durationFormatter.zeroFormattingBehavior = [.pad]
        // Mark: 只要分和秒
        durationFormatter.allowedUnits = [.minute, .second]
        self.store = store
        super.init()
    }
    /// UICollectionViewDataSource代理方法【概述】
    ///
    /// - Parameter collectionView
    /// - Returns: 列数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    /// UICollectionViewDataSource代理方法【概述】
    ///
    /// - Parameter collectionView
    /// - Parameter section 列数
    /// - Returns: 行数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    /// UICollectionViewDataSource代理方法【概述】
    ///
    /// - Parameter collectionView
    /// - Parameter indexPath 列数行数
    /// - Returns: cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult[indexPath.row]
        let cell: AssetCollectionViewCell
        if asset.mediaType == .video {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(VideoCollectionViewCell.self), for: indexPath) as! VideoCollectionViewCell
            let videoCell = cell as! VideoCollectionViewCell
            // Mark: 只要分和秒
            durationFormatter.allowedUnits = [.minute, .second]
            videoCell.durationLabel.text = durationFormatter.string(from: asset.duration)
            // Mark: 只要分和秒
            durationFormatter.allowedUnits = [.second]
            let str = durationFormatter.string(from: asset.duration) ?? ""
            let int = Float(str) ?? 0
            videoCell.durationSecend = Double(int)
            if settings.fetch.preview.videoLong < int {
                videoCell.isUserInteractionEnabled = false
            }else {
                videoCell.isUserInteractionEnabled = true
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(AssetCollectionViewCell.self), for: indexPath) as! AssetCollectionViewCell
        }
        loadImage(for: asset, in: cell)
        cell.selectionIndex = store.index(of: asset)
        return cell
    }
    /// 注册cell【概述】
    ///
    /// - Parameter collectionView
    ///
    static func registerCellIdentifiersForCollectionView(_ collectionView: UICollectionView?) {
        collectionView?.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(AssetCollectionViewCell.self))
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(VideoCollectionViewCell.self))
    }
    /// 加载图片【概述】
    ///
    /// - Parameter asset
    /// - Parameter cell
    ///
    private func loadImage(for asset: PHAsset, in cell: AssetCollectionViewCell?) {
        // Mark:  取消滑出屏幕外的图片请求
        if let cell = cell, cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        // Mark:  计算图片大小
        if let cell = cell {
            targetSize = cell.bounds.size.resize(by: scale)
            cell.settings = settings
        }
        // 给 Live Photo 添加一个标记
        if #available(iOS 9.1, *) {
            if (asset.mediaSubtypes == .photoLive) {
                cell?.liveImageView.image = PHLivePhotoView.livePhotoBadgeImage(options: PHLivePhotoBadgeOptions.overContent)
            }else {
                cell?.liveImageView.image = nil
            }
        } else {
            // Fallback on earlier versions
        }
        // Mark: 根据图片大小请求图片
        cell?.tag = Int(imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: settings.fetch.preview.photoOptions) { (image, _) in
            guard let image = image else { return }
            cell?.imageView.image = image
        })
    }
}
