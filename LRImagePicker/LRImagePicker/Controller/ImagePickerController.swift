//
//  ImagePickerControllerViewController.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/23.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos
// Mark: 获取com.apple.UIKit框架本地化中的Done 中英文
let localizedDone = Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "Done", value: "Done", table: "") ?? "Done"

// Mark: -
class ImagePickerController: UINavigationController {
    deinit {
        viewControllers = []
//        print("=====================\(self)未内存泄露")
    }
    weak var imagePickerDelegate: ImagePickerControllerDelegate?
    let zoomTransitionDelegate = ZoomTransitionDelegate()
    // Mark: 设置类实例
    var settings: Settings!
    // Mark: 取消按钮
    var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    // Mark: 选择相册按钮
    var albumButton: UIButton = UIButton(type: .custom)
    // Mark: - 本地相册 最近删除的中英文，暂时没找到系统中的获取方法
    var language: String {
        guard let localeLanguageCode = NSLocale.current.languageCode else { return "最近删除" }
        if localeLanguageCode == "zh"  {
            return "最近删除"
        } else {
            return "Recently Deleted"
        }
    }
    
    // Mark: -获取并筛选系统相册
    lazy var albums: [PHAssetCollection] = {
        let fetchOptions = settings.fetch.assets.options.copy() as! PHFetchOptions
        fetchOptions.fetchLimit = 1

        return settings.fetch.album.fetchResults.filter {
            $0.count > 0
        }.flatMap {
            $0.objects(at: IndexSet(integersIn: 0..<$0.count))
        }.filter {
            // Mark: 过滤掉不可用相册
            let assetsFetchResult = PHAsset.fetchAssets(in: $0, options: fetchOptions)
            return assetsFetchResult.count > 0 && $0.localizedTitle != language
        }
    }()
    
    public init(settings:Settings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            // Mark: - 下拉不可以 dismiss控制器。
            isModalInPresentation = true
        }
        
        navigationBar.barTintColor = settings.theme.navigationBarColor
        navigationBar.setBackgroundImage(imageWithColor(color: settings.theme.navigationBarColor), for: .default)
        navigationBar.shadowImage = UIImage()
        // Mark: 关闭导航条半透明状态
        navigationBar.isTranslucent = false
        navigationBar.isOpaque = true
        let rootVC = AssetsViewController()
        
        rootVC.settings = settings
        viewControllers = [rootVC]
        if let firstAlbum = albums.first {
            select(album: firstAlbum)
        }
        view.backgroundColor = settings.theme.backgroundColor
        
        
        
        // Mark:  设置导航栏
        let firstViewController = viewControllers.first
        // Mark: 设置相册按钮
        albumButton.setTitleColor(albumButton.tintColor, for: .normal)
        albumButton.titleLabel?.font = .systemFont(ofSize: 16)
        albumButton.titleLabel?.adjustsFontSizeToFitWidth = true

        let arrowView = ArrowView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        arrowView.backgroundColor = .clear
        arrowView.strokeColor = albumButton.tintColor
        let image = arrowView.asImage

        albumButton.setImage(image, for: .normal)
        albumButton.semanticContentAttribute = .forceRightToLeft
        albumButton.addTarget(self, action: #selector(albumsButtonClick(_:)), for: .touchUpInside)
        firstViewController?.navigationItem.titleView = albumButton
        
        // Mark: 设置取消按钮
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonClick(_:))
        firstViewController?.navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func albumsButtonClick(_ sender: UIButton) {
        albumsButtonPressed(sender)
    }
    
    @objc func cancelButtonClick(_ sender: UIButton) {
        cancelButtonPressed(sender)
    }
    func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setFillColor(color.cgColor);
        context.fill(rect);
        guard let theImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() };
        UIGraphicsEndImageContext();
        return theImage
    }
}
