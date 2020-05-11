//
//  PreviewCollectionViewCell.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/7.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos


class PreviewCollectionViewCell: UICollectionViewCell {
    var fullBlock: ((_ fullscreen: Bool) -> ())?
    var settings: Settings! {
        willSet {
            backgroundColor = newValue.theme.backgroundColor
        }
    }
    let imageView: UIImageView = UIImageView(frame: .zero)
    let scrollView = UIScrollView(frame: .zero)
    let singleTapRecognizer = UITapGestureRecognizer()
    let doubleTapRecognizer = UITapGestureRecognizer()
    var fullscreen = false {
        didSet {
            guard oldValue != fullscreen else { return }
            UIView.animate(withDuration: 0.3) {
                self.updateNavigationBar()
                self.updateStatusBar()
                self.updateBackgroundColor()
            }
        }
    }
    private func updateNavigationBar() {
        if let block = fullBlock {
            block(fullscreen)
        }
//        LRImagePicker.currentViewController?.navigationController?.setNavigationBarHidden(fullscreen, animated: true)
    }
    private func updateStatusBar() {
//        LRImagePicker.currentViewController?.setNeedsStatusBarAppearanceUpdate()
    }
    private func updateBackgroundColor() {
        let aColor: UIColor
        
        if self.fullscreen && LRImagePicker.currentViewController?.modalPresentationStyle == .fullScreen {
            aColor = UIColor.black
        } else {
            aColor = UIColor.white
        }
        
        self.contentView.backgroundColor = aColor
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupImageView()
        setupSingleTapRecognizer()
        setupDoubleTapRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupScrollView() {
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.frame.size.width -= 10
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        if #available(iOS 11.0, *) {
            // Allows the imageview to be 'under' the navigation bar
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        contentView.addSubview(scrollView)
    }
    
    private func setupImageView() {
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
    }
    private func setupSingleTapRecognizer() {
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.addTarget(self, action: #selector(didSingleTap(_:)))
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        contentView.addGestureRecognizer(singleTapRecognizer)
    }

    private func setupDoubleTapRecognizer() {
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.addTarget(self, action: #selector(didDoubleTap(_:)))
        contentView.addGestureRecognizer(doubleTapRecognizer)
    }

    private func toggleFullscreen() {
        fullscreen = !fullscreen
    }
    
    @objc func didSingleTap(_ recognizer: UIGestureRecognizer) {
        toggleFullscreen()
    }
    
    @objc func didDoubleTap(_ recognizer: UIGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.zoom(to: zoomRect(scale: 2, center: recognizer.location(in: recognizer.view)), animated: true)
        }
    }
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        guard let zoomView = viewForZooming(in: scrollView) else { return .zero }
        let newCenter = scrollView.convert(center, from: zoomView)
        
        var zoomRect = CGRect.zero
        zoomRect.size.height = zoomView.frame.size.height / scale
        zoomRect.size.width = zoomView.frame.size.width / scale
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
}

extension PreviewCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            fullscreen = true
            guard let image = imageView.image else { return }
            guard let zoomView = viewForZooming(in: scrollView) else { return }
            
            let widthRatio = zoomView.frame.width / image.size.width
            let heightRatio = zoomView.frame.height / image.size.height
            
            let ratio = widthRatio < heightRatio ? widthRatio:heightRatio
            
            let newWidth = image.size.width * ratio
            let newHeight = image.size.height * ratio
            
            let left = 0.5 * (newWidth * scrollView.zoomScale > zoomView.frame.width ? (newWidth - zoomView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
            let top = 0.5 * (newHeight * scrollView.zoomScale > zoomView.frame.height ? (newHeight - zoomView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))
            
            scrollView.contentInset = UIEdgeInsets(top: top.rounded(), left: left.rounded(), bottom: top.rounded(), right: left.rounded())
        } else {
            scrollView.contentInset = .zero
        }
    }
}


