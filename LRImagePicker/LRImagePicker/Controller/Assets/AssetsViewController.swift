//
//  AssetsViewController.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/30.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos


protocol AssetsViewControllerDelegate: class {
    func assetsViewController(_ assetsViewController: AssetsViewController, didSelectAsset asset: PHAsset)
    func assetsViewController(_ assetsViewController: AssetsViewController, didDeselectAsset asset: PHAsset)
    func assetsViewController(_ assetsViewController: AssetsViewController, didPressCell cell: AssetCollectionViewCell, displayingAsset asset: PHAsset, indexPath:IndexPath)
    func assetsViewController(_ assetsViewController: AssetsViewController, didLookUp asset: PHAsset)
    func assetsViewController(_ assetsViewController: AssetsViewController, toClipping asset: PHAsset)
    func assetsViewController(_ assetsViewController: AssetsViewController, didSend assets: [PHAsset])
}

class AssetsViewController: UIViewController {
    deinit {
//        print("=====================\(self)未内存泄露")
    }
    weak var delegate: AssetsViewControllerDelegate?
    // Mark: 计算时间差
    private let durationFormatter = DateComponentsFormatter()
    var settings: Settings! {
        didSet { dataSource?.settings = settings }
    }
    // Mark: 存储资源返回给
    let store = AssetStore()
    let toolFootView: ToolFootView = ToolFootView()
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    // Mark: 资源
    var fetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>() {
        didSet {
            dataSource = AssetsCollectionViewDataSource(fetchResult: fetchResult, store: store)
        }
    }
    // Mark: 设置dataSource代理
    private var dataSource: AssetsCollectionViewDataSource? {
        didSet {
            dataSource?.settings = settings
            collectionView.dataSource = dataSource
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCollectionViewLayout(for: traitCollection)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCollectionViewLayout(for: traitCollection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = navigationController as? AssetsViewControllerDelegate
        collectionView.backgroundColor = settings.theme.backgroundColor
        // Mark: 允许多选
        collectionView.allowsMultipleSelection = true
        // Mark: 是否有弹簧效果,默认是开启的
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - CGFloat(topHeight))
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        // Mark: 竖直方向总是可以弹性滑动,默认是No
        collectionView.alwaysBounceVertical = true
        // Mark: 注册cell
        AssetsCollectionViewDataSource.registerCellIdentifiersForCollectionView(collectionView)
        toolFootView.translatesAutoresizingMaskIntoConstraints = false
        toolFootView.settings = settings
        toolFootView.icon.isSelected = false
        toolFootView.backgroundColor = .black
        view.addSubview(toolFootView)
        NSLayoutConstraint.activate([
            toolFootView.heightAnchor.constraint(equalToConstant: CGFloat(topHeight)),
            toolFootView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            toolFootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolFootView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
        toolFootView.lookBlock = {[weak self] in
            if let delegate = self?.delegate {
                if self!.store.assets.count > 0 {
                    delegate.assetsViewController(self!, didLookUp: self!.store.assets.first!)
                }
            }
        }
        toolFootView.sendBlock = {[weak self] in
            if let delegate = self?.delegate {
                if self!.store.assets.count > 0 {
                    delegate.assetsViewController(self!, didSend: self!.store.assets)
                }
            }
        }
    }
    var topHeight: Int {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPhone10,3": fallthrough
        case "iPhone10,6": fallthrough
        case "iPhone11,8": fallthrough
        case "iPhone11,2": fallthrough
        case "iPhone11,4": fallthrough
        case "iPhone11,6": fallthrough
        case "iPhone12,1": fallthrough
        case "iPhone12,3": fallthrough
        case "iPhone12,5": return 84
        default: return 60
        }
    }
    /// 更新布局【概述】
    ///
    /// - Parameter traitCollection
    ///
    private func updateCollectionViewLayout(for traitCollection: UITraitCollection) {
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else  { return }
        let itemSpacing = settings.list.spacing
        let itemsPerRow = settings.list.cellsPerRow(traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass)
        let itemWidth = (collectionView.bounds.width - CGFloat(itemsPerRow - 1) * itemSpacing) / CGFloat(itemsPerRow)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        collectionViewFlowLayout.minimumLineSpacing = itemSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = itemSpacing
        collectionViewFlowLayout.itemSize = itemSize
    }
    
    /// 获取相册中的图片【概述】
    ///
    /// - Parameter album: 筛选出来的相册
    ///
    func showAssets(in album: PHAssetCollection) {
        fetchResult = PHAsset.fetchAssets(in: album, options: settings.fetch.assets.options)
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }
    // Mark: 更新cell的选中状态
    private func updateSelectionIndexForCell(at indexPath: IndexPath) {
        guard settings.theme.selectionStyle == .numbered else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell else { return }
        let asset = fetchResult.object(at: indexPath.row)
        cell.selectionIndex = store.index(of: asset)
    }
    func selectphotoCell(at indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        updateSelectionIndexForCell(at: indexPath)
    }
    func deletephotoCell(at indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        updateSelectionIndexForCell(at: indexPath)
        for indexPathx in collectionView.indexPathsForSelectedItems ?? [] {
            updateSelectionIndexForCell(at: indexPathx)
        }
    }}


extension AssetsViewController: UICollectionViewDelegate {
   
    func assetCollection(didSelectItemAt sender: UITapGestureRecognizer) {
        let location = sender.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell else { return }
        let asset = fetchResult.object(at: indexPath.row)
        durationFormatter.allowedUnits = [.second]
        let str = durationFormatter.string(from: asset.duration) ?? ""
        let int = Float(str) ?? 0
        if asset.mediaType == .video && settings.fetch.preview.videoLong < int  {
            return
        }
        if settings.fetch.preview.allowCrop {
            delegate?.assetsViewController(self, toClipping: asset)
        }else {
            delegate?.assetsViewController(self, didPressCell: cell, displayingAsset: asset, indexPath: indexPath)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let assetCell = cell as? AssetCollectionViewCell else {
            return
        }
        if settings.fetch.preview.allowCrop {
            assetCell.selectionView.isHidden = true
        }
        assetCell.didSelectItemAt = { [unowned self] (tap) in
            self.assetCollection(didSelectItemAt: tap)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if settings.fetch.preview.allowCrop {
            return
        }
        durationFormatter.allowedUnits = [.second]
        let asset = fetchResult.object(at: indexPath.row)
        let str = durationFormatter.string(from: asset.duration) ?? ""
        let int = Float(str) ?? 0
        if asset.mediaType == .video && settings.fetch.preview.videoLong < int  {
            return
        }
        store.append(asset)
        delegate?.assetsViewController(self, didSelectAsset: asset)
        updateSelectionIndexForCell(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if settings.fetch.preview.allowCrop {
            return
        }
        durationFormatter.allowedUnits = [.second]
        let asset = fetchResult.object(at: indexPath.row)
        let str = durationFormatter.string(from: asset.duration) ?? ""
        let int = Float(str) ?? 0
        if asset.mediaType == .video && settings.fetch.preview.videoLong < int  {
            return
        }
        store.remove(asset)
        delegate?.assetsViewController(self, didDeselectAsset: asset)
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            updateSelectionIndexForCell(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard store.count < settings.selection.max else {
            let alertController = UIAlertController(title: "提示", message: "您最多只能选择\(settings.selection.max)项", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "我知道了", style: UIAlertAction.Style.cancel, handler: nil )
            alertController.addAction(cancelAction);
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }
}
