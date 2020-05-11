//
//  AlbumsCollectionViewDataSource.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/31.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos

class AlbumsTableViewDataSource: NSObject, UITableViewDataSource {
    var settings: Settings!
    private let albums: [PHAssetCollection]
    private let scale:CGFloat
    private let imageManager = PHCachingImageManager.default()
    
    init(albums: [PHAssetCollection], scale: CGFloat = UIScreen.main.scale) {
        self.albums = albums
        self.scale = scale
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        albums.count > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AlbumTableViewCell.self), for: indexPath) as! AlbumTableViewCell
        let album = albums[indexPath.row]
        cell.albumLabel.attributedText = titleForAlbum(album)
        
        let fetchOptions = settings.fetch.assets.options.copy() as! PHFetchOptions
        fetchOptions.fetchLimit = 1
        
        let imageSize = CGSize(width: settings.list.albumsCellH, height: settings.list.albumsCellH).resize(by: scale)
        let imageContentMode: PHImageContentMode = .aspectFill
        if let asset = PHAsset.fetchAssets(in: album, options: fetchOptions).firstObject {
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: imageContentMode, options: settings.fetch.preview.photoOptions) { (image, _) in
                guard let image = image else { return }
                cell.albumImageView.image = image
            }
        }
        
        return cell
    }
    
    
    
    /// 注册cell【概述】
    ///
    /// - Parameter collectionView
    ///
    static func registerCellIdentifiersForTableView(_ tableView: UITableView?) {
        tableView?.register(AlbumTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(AlbumTableViewCell.self))
    }
    
    private func titleForAlbum(_ album: PHAssetCollection) -> NSAttributedString {
        let text = NSMutableAttributedString()
        let fetchOptions = settings.fetch.assets.options.copy() as! PHFetchOptions
        let assetsFetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)
        text.append(NSAttributedString(string: (album.localizedTitle ?? ""), attributes: settings.theme.albumTitleAttributes))
        text.append(NSAttributedString(string: "（\(assetsFetchResult.count)）", attributes: settings.theme.albumSubTitleAttributes))
        return text
    }
}
