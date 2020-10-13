//
//  PreviewCollectionViewController.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/7.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos

protocol PreviewCollectionViewControllerDelegate: class {
    func previewCollectionViewController(_ previewCollectionViewController: PreviewCollectionViewController, didSelectAsset asset: PHAsset, at indexPath: IndexPath)
    
    func previewCollectionViewController(_ previewCollectionViewController: PreviewCollectionViewController, didDeselectAsset asset: PHAsset, at indexPath: IndexPath)
    
    func previewCollectionViewControllerDissmiss(_ previewCollectionViewController: PreviewCollectionViewController)
    
    func previewCollectionViewController(_ previewCollectionViewController: PreviewCollectionViewController, didSend assets: [PHAsset])
}

class PreviewCollectionViewController: UIViewController {
    var indexPathsForSelectedItems: [IndexPath]?
    deinit {
//        print("=====================\(self)未内存泄露")
    }
    weak var delegate: PreviewCollectionViewControllerDelegate?
    var selectedIndex = 0
    var currentIndex = 0
    
    var isSelected = false
    var isOriginal = false
    
    var isFristLoadCell = true
    private var scrollDistance: CGFloat = 0
    var store:AssetStore
    init(store: AssetStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var settings: Settings! {
        didSet { dataSource?.settings = settings
            toolFootView.settings = settings
        }
    }
    private var dataSource: PreviewCollectionViewDataSource? {
        didSet {
            dataSource?.settings = settings
        }
    }
    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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
    private let toolHeadView: ToolHeadView = ToolHeadView()
    let toolFootView: ToolFootView = ToolFootView()
    // Mark: 资源
    var fetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>() {
        didSet {
            dataSource = PreviewCollectionViewDataSource(fetchResult: fetchResult)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.selectedIndex>0 {
            collectionView.selectItem(at: IndexPath(item: self.selectedIndex, section: 0), animated: false, scrollPosition: .left)
            let asset = fetchResult[self.selectedIndex]
            toolHeadView.selectionView.selectionIndex = store.index(of: asset)
            toolHeadView.selectionView.isSelected = isSelected
            self.selectedIndex = 0
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        collectionView.backgroundColor = settings.theme.backgroundColor
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else  { return }
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        collectionViewFlowLayout.itemSize = CGSize(width: view.frame.size.width+10, height: view.frame.size.height)
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.delegate = self
        dataSource?.settings = settings
        PreviewCollectionViewDataSource.registerCellIdentifiersForCollectionView(collectionView)
        collectionView.dataSource = dataSource
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.frame.size.width += 10
        view.addSubview(collectionView)
        toolHeadView.translatesAutoresizingMaskIntoConstraints = false
        toolHeadView.backgroundColor = .black
        toolHeadView.settings = settings
        toolHeadView.backBlock = {[weak self] in
            self?.navigationController?.popViewController(animated: true)
            self?.navigationController?.setNavigationBarHidden(false, animated: false)
            if let delegate = self?.delegate, let vc = self {
                delegate.previewCollectionViewControllerDissmiss(vc)
            }
        }
        toolHeadView.selectBlock = {[weak self] in
            self?.selectLink()
        }
        view.addSubview(toolHeadView)
        toolFootView.translatesAutoresizingMaskIntoConstraints = false
        toolFootView.settings = settings
        toolFootView.icon.isSelected = isOriginal
        toolFootView.backgroundColor = .black
        toolFootView.lookBlock = {
            
        }
        toolFootView.sendBlock = {[weak self] in
            if let delegate = self?.delegate {
                delegate.previewCollectionViewController(self!, didSend: self!.store.assets)
            }
        }
        view.addSubview(toolFootView)
        NSLayoutConstraint.activate([
            toolHeadView.heightAnchor.constraint(equalToConstant: CGFloat(topHeight)),
            toolHeadView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            toolHeadView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolHeadView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            toolFootView.heightAnchor.constraint(equalToConstant: CGFloat(topHeight)),
            toolFootView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            toolFootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolFootView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
    func selectLink() {
        let asset = fetchResult.object(at: currentIndex)
        if store.index(of: asset) == nil {
            if store.count >= settings.selection.max {
                let alertController = UIAlertController(title: "提示", message: "您最多只能选择\(settings.selection.max)项", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "我知道了", style: UIAlertAction.Style.cancel, handler: nil )
                alertController.addAction(cancelAction);
                self.present(alertController, animated: true, completion: nil)
                return
            }
            store.append(asset)
            indexPathsForSelectedItems?.append(IndexPath(row: currentIndex, section: 0))
            toolHeadView.selectionView.selectionIndex = store.index(of: asset)
            toolHeadView.selectionView.isSelected = true
            if let delegate = delegate {
                delegate.previewCollectionViewController(self, didSelectAsset: asset, at: IndexPath(row: currentIndex, section: 0))
            }
            toolFootView.sendBtnIndex = toolFootView.sendBtnIndex + 1
        }else {
            store.remove(asset)
            indexPathsForSelectedItems = indexPathsForSelectedItems?.filter({ (index) -> Bool in
                if index.row == currentIndex {
                    return false
                }
                return true
            })
            toolHeadView.selectionView.selectionIndex = store.index(of: asset)
            toolHeadView.selectionView.isSelected = false
            if let delegate = delegate {
                delegate.previewCollectionViewController(self, didDeselectAsset: asset, at: IndexPath(row: currentIndex, section: 0))
            }
            toolFootView.sendBtnIndex = toolFootView.sendBtnIndex - 1
        }
        
    }
}




extension PreviewCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: view.frame.size.width+10, height: view.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PreviewCollectionViewCell {
            cell.fullBlock = { [weak self] fullscreen in
                self?.toolHeadView.isHidden = fullscreen
                self?.toolFootView.isHidden = fullscreen
            }
        }
        
        if !settings.fastMode {
            return
        }
        if isFristLoadCell {
            settings.fetch.preview.photoOptions.deliveryMode = .opportunistic
            if #available(iOS 9.1, *) {
                settings.fetch.preview.livePhotoOptions.deliveryMode = .opportunistic
            }
            settings.fetch.preview.videoOptions.deliveryMode = .automatic
        }else {
            settings.fetch.preview.photoOptions.deliveryMode = .fastFormat
            if #available(iOS 9.1, *) {
                settings.fetch.preview.livePhotoOptions.deliveryMode = .fastFormat
            }
            settings.fetch.preview.videoOptions.deliveryMode = .fastFormat
        }
        let asset = fetchResult[indexPath.row]
        if #available(iOS 9.1, *) {
            switch (asset.mediaType, asset.mediaSubtypes) {
            case (.video, _):
                dataSource?.loadVieo(for: asset, in: cell as? VideoPreviewCollectionViewCell)
            case (.image, .photoLive):
                if settings.fetch.preview.showLivePreview {
                    dataSource?.load3dImage(for: asset, in: cell as? LivePreviewCollectionViewCell)
                }else {
                    dataSource?.loadImage(for: asset, in: cell as? PreviewCollectionViewCell)
                }
            default:
                dataSource?.loadImage(for: asset, in: cell as? PreviewCollectionViewCell)
            }
        } else {
            switch (asset.mediaType, asset.mediaSubtypes) {
            case (.video, _):
                dataSource?.loadVieo(for: asset, in: cell as? VideoPreviewCollectionViewCell)
            case (.image, _):
                dataSource?.loadImage(for: asset, in: cell as? PreviewCollectionViewCell)
            default:
                dataSource?.loadImage(for: asset, in: cell as? PreviewCollectionViewCell)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        dataSource?.cancelImageRequest(id: cell.tag)
        if let cell = cell as? VideoPreviewCollectionViewCell {
            cell.updateState(.paused)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !settings.fastMode {
            return
        }
        self.scrollDistance = scrollView.contentOffset.x
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIndex = Int(round(scrollView.contentOffset.x/scrollView.bounds.width))
        if self.currentIndex >= fetchResult.count {
            currentIndex = fetchResult.count-1
        } else if self.currentIndex < 0 {
            currentIndex = 0
        }
        toolHeadView.selectionView.isSelected = false
        for indexPathx in indexPathsForSelectedItems ?? [] {
            if indexPathx == IndexPath(row: self.currentIndex, section: 0) {
                toolHeadView.selectionView.isSelected = true
                let asset = fetchResult[indexPathx.row]
                toolHeadView.selectionView.selectionIndex = store.index(of: asset)
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !settings.fastMode {
            return
        }
        if scrollView.contentOffset.x != self.scrollDistance {
            let cell: PreviewCollectionViewCell
            let asset = fetchResult[self.currentIndex]
            isFristLoadCell = false
            settings.fetch.preview.photoOptions.deliveryMode = .opportunistic
            if #available(iOS 9.1, *) {
                settings.fetch.preview.livePhotoOptions.deliveryMode = .opportunistic
            }
            settings.fetch.preview.videoOptions.deliveryMode = .automatic
            if #available(iOS 9.1, *) {
                switch (asset.mediaType, asset.mediaSubtypes) {
                case (.video, _): break
                case (.image, .photoLive):
                    if settings.fetch.preview.showLivePreview {
                        cell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as! LivePreviewCollectionViewCell
                        dataSource?.load3dImage(for: asset, in: cell as? LivePreviewCollectionViewCell)
                    }else {
                        cell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as! PreviewCollectionViewCell
                        dataSource?.loadImage(for: asset, in: cell)
                    }
                default:
                    cell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as! PreviewCollectionViewCell
                    dataSource?.loadImage(for: asset, in: cell)
                }
            } else {
                switch (asset.mediaType, asset.mediaSubtypes) {
                case (.video, _): break
                case (.image, _):
                    cell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as! PreviewCollectionViewCell
                    dataSource?.loadImage(for: asset, in: cell)
                default:
                    cell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as! PreviewCollectionViewCell
                    dataSource?.loadImage(for: asset, in: cell)
                }
            }
        }
    }
}
