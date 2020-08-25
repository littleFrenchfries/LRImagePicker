//
//  ClippingImageCollectionViewCell.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/8/20.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import PhotosUI
class ClippingImageCollectionViewCell: UICollectionViewCell {
    var asset: PHAsset? {
        didSet {
            previewView?.asset = asset
        }
    }
    
    var singleTapGestureBlock: (() -> ())?
    
    var imageProgressUpdateBlock: ((_ progress: Double) -> ())?
    
    var previewView: PhotoPreviewView?
    
    var cropRect: CGRect? {
        didSet {
            previewView?.cropRect = cropRect
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        previewView = PhotoPreviewView(frame: bounds)
        
        previewView?.singleTapGestureBlock = {[weak self] in
            if let block = self?.singleTapGestureBlock {
                block()
            }
        }
        previewView?.imageProgressUpdateBlock = {[weak self](progress) in
            if let block = self?.imageProgressUpdateBlock {
                block(progress)
            }
        }
        addSubview(previewView!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func recoverSubviews() -> Void {
        previewView?.recoverSubviews()
    }
}

class PhotoPreviewView: UIView {
    private let imageManager = PHCachingImageManager.default()
    var imageView:UIImageView = UIImageView()
    var scrollView: UIScrollView = UIScrollView()
    var imageContainerView = UIView()
    var progressView: ProgressView?
    var cropRect: CGRect?
    var asset: PHAsset? {
        didSet {
            PHImageManager.default().cancelImageRequest(imageRequestID)
            guard let newValue = asset else { return }
            let options = PHImageRequestOptions()
            // Mark: 允许从iCloud云中下载图片
            options.isNetworkAccessAllowed = true
            let aspectRatio = CGFloat(asset!.pixelWidth) / CGFloat(asset!.pixelHeight)
            if aspectRatio > 1.5 {
                scrollView.maximumZoomScale *= aspectRatio / 1.5
            }
            imageManager.requestImage(for: newValue, targetSize: UIScreen.main.bounds.size , contentMode: .aspectFill, options: options) { [weak self](image, _) in
                guard let image = image else { return }
                self?.imageView.image = image
            }
        }
    }
    var singleTapGestureBlock: (() -> ())?
       
    var imageProgressUpdateBlock: ((_ progress: Double) -> ())?
    
    var imageRequestID: __int32_t = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.frame = CGRect(x: 10, y: 0, width: frame.size.width - 20, height: frame.size.height)
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 2.5
        scrollView.minimumZoomScale = 1.0
        scrollView.isMultipleTouchEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.alwaysBounceVertical = false
        scrollView.setZoomScale(1.0, animated: false)
        scrollView.backgroundColor = .clear
        
        
        scrollView.maximumZoomScale = 4.0
        addSubview(scrollView)
        
        imageContainerView.clipsToBounds = true
        imageContainerView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageContainerView)
        
        imageView.backgroundColor = UIColor.init(white: 1.000, alpha: 0.500)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageContainerView.addSubview(imageView)
        
        let tap1 = UITapGestureRecognizer.init(target: self, action: #selector(singleTap(tap:)))
         
        addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap(tap:)))
        
        tap2.numberOfTapsRequired = 2
        tap1.require(toFail: tap2)
        addGestureRecognizer(tap2)
        
        configProgressView()
    }
    
    func recoverSubviews() -> Void {
        scrollView.setZoomScale(1.0, animated: true)
        resizeSubviews()
    }
    
    func resizeSubviews() -> Void {
        imageContainerView.frame.origin = .zero
        imageContainerView.frame.size.width = scrollView.frame.size.width
        guard let image = imageView.image else {
            return
        }
        if image.size.height / image.size.width > frame.size.height / scrollView.frame.size.width {
            imageContainerView.frame.size.height = floor(image.size.height / (image.size.width / scrollView.frame.size.width))
        } else {
            var height = image.size.height / image.size.width * scrollView.frame.size.width
            if height < 1 || height.isNaN {
                height = frame.size.height
            }
            height = floor(height)
            imageContainerView.frame.size.height = height
            imageContainerView.center.y = frame.size.height / 2
        }
        
        if imageContainerView.frame.size.height > frame.size.height && imageContainerView.frame.size.height - frame.size.height <= 1 {
            imageContainerView.frame.size.height = frame.size.height
        }
        
        let contentSizeH = max(imageContainerView.frame.size.height, frame.size.height)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: contentSizeH)
        scrollView.scrollRectToVisible(bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.frame.size.height <= frame.size.height ? false : true
        imageView.frame = imageContainerView.bounds
        refreshScrollViewContentSize()
    }
    
    func refreshScrollViewContentSize() -> Void {
        let contentWidthAdd = scrollView.frame.size.width - cropRect!.maxX
        let contentHeightAdd = (min(imageContainerView.frame.size.height, frame.size.height) - cropRect!.size.height) / 2
        let newSizeW = scrollView.contentSize.width + contentWidthAdd
        let newSizeH = max(scrollView.contentSize.height, frame.size.height) + contentHeightAdd
        scrollView.contentSize = CGSize(width: newSizeW, height: newSizeH)
        scrollView.alwaysBounceVertical = true
        if contentHeightAdd > 0 {
            scrollView.contentInset = UIEdgeInsets(top: contentHeightAdd, left: cropRect!.origin.x, bottom: 0, right: 0)
        }else {
            scrollView.contentInset = .zero
        }
    }
    
    func configProgressView() -> Void {
        progressView = ProgressView()
        let progressWH: CGFloat = 40
        let progressX = (frame.size.width - progressWH) / 2
        let progressY = (frame.size.height - progressWH) / 2
        progressView?.frame = CGRect(x: progressX, y: progressY, width: progressWH, height: progressWH)
        progressView?.isHidden = true
        addSubview(progressView!)
    }
    
    @objc func singleTap(tap: UITapGestureRecognizer) -> Void {
        if let block = singleTapGestureBlock {
            block()
        }
    }
    
    @objc func doubleTap(tap: UITapGestureRecognizer) -> Void {
        if scrollView.zoomScale > 1.0 {
            scrollView.contentInset = .zero
            scrollView.setZoomScale(1.0, animated: true)
        }else {
            let touchPoint = tap.location(in: imageView)
            let newZoomScale = scrollView.maximumZoomScale
            let xsize = frame.size.width / newZoomScale
            let ysize = frame.size.height / newZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoPreviewView: UIScrollViewDelegate {
    func refreshImageContainerViewCenter() {
        let offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? ((scrollView.frame.size.width - scrollView.contentSize.width) * 0.5) : 0.0
        let offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? ((scrollView.frame.size.height - scrollView.contentSize.height) * 0.5) : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        refreshImageContainerViewCenter()
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        refreshScrollViewContentSize()
    }
}

class ProgressView: UIView {
    var progress: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var progressLayer: CAShapeLayer
    override init(frame: CGRect) {
        progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.opacity = 1
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 5
        
        progressLayer.shadowColor = UIColor.black.cgColor
        progressLayer.shadowOffset = CGSize(width: 1, height: 1)
        progressLayer.shadowOpacity = 0.5
        progressLayer.shadowRadius = 2
        super.init(frame: frame)
        backgroundColor = .clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.size.width / 2, y: rect.size.height / 2)
        let raduis = rect.size.width / 2
        let startA = -Double.pi / 2
        let endA = -Double.pi / 2 + Double.pi * 2 * progress
        progressLayer.frame = bounds
        let path = UIBezierPath(arcCenter: center, radius: raduis, startAngle: CGFloat(startA), endAngle: CGFloat(endA), clockwise: true)
        progressLayer.path = path.cgPath
        progressLayer.removeFromSuperlayer()
        layer.addSublayer(progressLayer)
    }
}

