//
//  LivePreviewCollectionViewCell.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/7.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import PhotosUI
@available(iOS 9.1, *)
class LivePreviewCollectionViewCell: PreviewCollectionViewCell {
    let livePhotoView = PHLivePhotoView()
    let badgeView = UIImageView()
    func positionBadgeView(for livePhoto: PHLivePhoto?) {
        guard let livePhoto = livePhoto else {
            badgeView.frame.origin = .zero
            return
        }

        let imageFrame = ImageViewLayout.frameForImageWithSize(livePhoto.size, previousFrame: .zero, inContainerWithSize: livePhotoView.frame.size, usingContentMode: .scaleAspectFit)
        badgeView.frame.origin = imageFrame.origin
    }
    override var fullscreen: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.badgeView.alpha = self.fullscreen ? 0 : 1
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        livePhotoView.frame = scrollView.bounds
        livePhotoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        livePhotoView.contentMode = .scaleAspectFit
        scrollView.addSubview(livePhotoView)
        
        let badge = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        badgeView.image = badge
        badgeView.sizeToFit()
        livePhotoView.addSubview(badgeView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return livePhotoView
    }
}
@available(iOS 9.1, *)
extension LivePreviewCollectionViewCell: PHLivePhotoViewDelegate {
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        // Hide badge view if we aren't in fullscreen
        guard fullscreen == false else { return }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.badgeView.alpha = 0
        }
    }

    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        // Show badge view if we aren't in fullscreen
        guard fullscreen == false else { return }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.badgeView.alpha = 1
        }
    }
}
