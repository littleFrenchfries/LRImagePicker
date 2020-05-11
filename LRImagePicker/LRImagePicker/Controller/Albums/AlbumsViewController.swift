//
//  AlbumsViewController.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/31.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos

// Mark: 相册回掉协议
protocol AlbumsViewControllerDelegate: class {
    // Mark: 选择相册之后回掉传值
    func albumsViewController(_ albumsViewController: AlbumsViewController, didSelectAlbum album: PHAssetCollection)
    // Mark:相册消失之后需要通知导航控制器刷新相册按钮
    func didDismissAlbumsViewController(_ albumsViewController: AlbumsViewController)
}
// Mark: 相册控制器
class AlbumsViewController: UIViewController {
    deinit {
//        print("=====================\(self)未内存泄露")
    }
    // Mark: 设置代理方法
    weak var delegate: AlbumsViewControllerDelegate?
    var settings: Settings!
    // Mark: 相册数组
    var albums: [PHAssetCollection] = []
    // Mark: 设置dataSource
    var dataSource: AlbumsTableViewDataSource?
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        view = tableView
        tableView.frame = view.bounds
        // Mark: 解决动画显示问题，让tableView根据控制器动画显示自适应
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.backgroundColor = settings.theme.backgroundColor
        // Mark: 是否有弹簧效果,默认是开启的
        tableView.bounces = true
        // Mark: 竖直方向总是可以弹性滑动,默认是No
        tableView.alwaysBounceVertical = true
        // Mark: 需要设置这两个属性 不然界面会下坠
        tableView.sectionHeaderHeight = .leastNormalMagnitude
        tableView.sectionFooterHeight = .leastNormalMagnitude
        dataSource = AlbumsTableViewDataSource(albums: albums)
        dataSource?.settings = settings
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        AlbumsTableViewDataSource.registerCellIdentifiersForTableView(tableView)
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
    }
    // Mark:相册消失之后需要通知导航控制器刷新相册按钮
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            delegate?.didDismissAlbumsViewController(self)
        }
    }
}

// Mark: UITableViewDelegate设置
extension AlbumsViewController: UITableViewDelegate {
    // Mark: 选择相册之后回掉传值
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.albumsViewController(self, didSelectAlbum: albums[indexPath.row])
    }
    // Mark:设置相册cell大小
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        settings.list.albumsCellH
    }
    // Mark:需要设置tableView头为空 不然界面会下坠
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    // Mark:需要设置tableView脚为空 不然界面会下坠
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
