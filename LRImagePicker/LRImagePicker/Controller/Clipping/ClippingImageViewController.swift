//
//  ClippingImageViewController.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/8/20.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import PhotosUI

class ClippingImageViewController: UIViewController {
    
    var cropBgView = UIView()
    
    var cropView = UIView()
    
    var collectionView: UICollectionView?
//    var store:AssetStore
    var asset: PHAsset
    
    init(/*store: AssetStore*/ asset: PHAsset) {
//        self.store = store
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configCropView()
    }
    
    func configCollectionView() -> Void {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width + 20, height: view.frame.size.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: CGRect(x: -10, y: 0, width: view.frame.size.width, height: view.frame.size.height), collectionViewLayout: layout)
        collectionView?.backgroundColor = .black
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.isPagingEnabled = true
        collectionView?.scrollsToTop = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.contentOffset = CGPoint(x: 0, y: 0)
        collectionView?.contentSize = CGSize(width: CGFloat(view.frame.width + 20), height: 0)
        view.addSubview(collectionView!)
        collectionView?.register(ClippingImageCollectionViewCell.self, forCellWithReuseIdentifier: "ClippingImageCollectionViewCell")
        
    }
    
    func configCropView() -> Void {
        cropBgView.isUserInteractionEnabled = false
        cropBgView.backgroundColor = .clear
        cropBgView.frame = view.bounds
        view.addSubview(cropBgView)
        overlayClippingWithView(view: cropBgView, cropRect: cropRect, containerView: view, needCircleCrop: true)
        cropView.isUserInteractionEnabled = false
        cropView.backgroundColor = .clear
        cropView.layer.borderColor = UIColor.white.cgColor
        cropView.layer.borderWidth = 1
        cropView.layer.cornerRadius = cropRect.size.width / 2
        cropView.clipsToBounds = true
        view.addSubview(cropView)
    }
    
    var cropRect: CGRect {
        CGRect(x: 0, y: (view.frame.height - view.frame.size.width) / 2, width: view.frame.width, height: view.frame.width)
    }
    
    
    func overlayClippingWithView(view: UIView, cropRect: CGRect, containerView: UIView, needCircleCrop: Bool) -> Void {
        let path = UIBezierPath(rect: UIScreen.main.bounds)
        let layer = CAShapeLayer()
        if needCircleCrop {//圆形裁剪框
            path.append(UIBezierPath.init(arcCenter: containerView.center, radius: cropRect.size.width / 2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: false))
        } else {//矩形裁剪框
            path.append(UIBezierPath(rect: cropRect))
        }
        layer.path = path.cgPath
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0.5
        view.layer.addSublayer(layer)
    }
}

extension ClippingImageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClippingImageCollectionViewCell", for: indexPath) as? ClippingImageCollectionViewCell else { return UICollectionViewCell() }
        cell.asset = asset
        cell.singleTapGestureBlock = {[weak self] in
            
        }
        cell.imageProgressUpdateBlock = {[weak self](progress) in
            
        }
        return cell
    }
}
