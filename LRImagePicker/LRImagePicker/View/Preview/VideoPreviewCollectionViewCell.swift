//
//  VideoPreviewCollectionViewCell.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/7.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos


class VideoPreviewCollectionViewCell: PreviewCollectionViewCell {
    private let playerView = PlayerView()
    private let pauseView: PauseView = PauseView(frame: CGRect(x: UIScreen.main.bounds.width/2.0, y: UIScreen.main.bounds.height/2.0, width: 60, height: 60))
    enum State {
        case playing
        case paused
    }
    var player: AVPlayer? {
        didSet {
            guard let player = player else { return }
            playerView.player = player
            NotificationCenter.default.addObserver(self, selector: #selector(reachedEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    func updateState(_ state: State, animated: Bool = true) {
        switch state {
        case .playing:
            pauseView.removeFromSuperview()
            fullscreen = true
            player?.play()
        case .paused:
            playerView.addSubview(pauseView)
            fullscreen = false
            player?.pause()
        }
    }
    @objc func reachedEnd(notification: Notification) {
        player?.seek(to: .zero)
        updateState(.paused)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(_ :)))
        playerView.addGestureRecognizer(tap1)
        playerView.frame = bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(playerView)
        scrollView.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(pauseClick(_ :)))
        pauseView.addGestureRecognizer(tap)
        pauseView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = false
        doubleTapRecognizer.isEnabled = false
        playerView.addSubview(pauseView)
        pauseView.center = playerView.center
    }
    @objc func pauseClick(_ tap:UITapGestureRecognizer) {
        updateState(.playing)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc override func didSingleTap(_ recognizer: UIGestureRecognizer) {
        updateState(.paused)
    }
}
