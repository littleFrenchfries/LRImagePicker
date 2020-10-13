//
//  AssetCollectionViewCell.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/30.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
// Mark: 图片cell
class AssetCollectionViewCell: UICollectionViewCell {
    // Mark: 点击放大图的回掉通知
    var didSelectItemAt: ((UITapGestureRecognizer) -> Void)?
    // Mark: 展示的图片或视频截图
    let imageView: UIImageView = UIImageView(frame: .zero)
    // Mark: 展示的3d图片的标记
    let liveImageView: UIImageView = UIImageView(frame: .zero)
    // Mark:代码标记图片
    let selectionView: SelectionView = SelectionView(frame: .zero)
    // Mark: 被选中时的阴影
    private let selectionOverlayView: UIView = UIView(frame: .zero)
    var durationSecend = 0.0
    var settings: Settings! {
        didSet { selectionView.settings = settings }
    }
    // Mark: 被选中的排名
    var selectionIndex: Int? {
        didSet { selectionView.selectionIndex = selectionIndex }
    }
    // Mark: 更新被选中状态
    override var isSelected: Bool {
        didSet {
            if settings.fetch.preview.allowCrop {
                return
            }
            guard oldValue != isSelected else { return }
            if UIView.areAnimationsEnabled {
                UIView.animate(withDuration: TimeInterval(0.1), animations: { [weak weakSelf = self]() -> Void in
                    // Set alpha for views
                    weakSelf?.updateAlpha(self.isSelected)

                    // Scale all views down a little
                    weakSelf?.selectionView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }, completion: { [weak weakSelf = self](finished: Bool) -> Void in
                    UIView.animate(withDuration: TimeInterval(0.1), animations: { () -> Void in
                        // And then scale them back upp again to give a bounce effect
                        weakSelf?.selectionView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: nil)
                })
            } else {
                updateAlpha(isSelected)
            }
        }
    }
    // Mark: 重新初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Mark: 从代码层面开始使用Autolayout，需要对使用的View的translatesAutoresizingMaskIntoConstraints的属性设置为NO，即可开始通过代码添加Constraint，否则View还是会按照以往的autoresizingMask进行计算。
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Mark:  scaleToFill 图片以控件大小为准  填满  （以椭圆形为例，变形）
        // Mark:  scaleAspectFit  图片以自身宽高比为准填充 ，剩余空间透明（不变形）
        // Mark:  scaleAspectFill  图片显示不全，类似于放大并显示中间的一部分
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "")
        // Mark: 剪裁掉超出imageView的子视图
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        liveImageView.translatesAutoresizingMaskIntoConstraints = false
        // Mark:  scaleToFill 图片以控件大小为准  填满  （以椭圆形为例，变形）
        // Mark:  scaleAspectFit  图片以自身宽高比为准填充 ，剩余空间透明（不变形）
        // Mark:  scaleAspectFill  图片显示不全，类似于放大并显示中间的一部分
        liveImageView.contentMode = .scaleAspectFill
        liveImageView.image = UIImage(named: "")
        // Mark: 剪裁掉超出imageView的子视图
        liveImageView.clipsToBounds = true
        contentView.addSubview(liveImageView)
        // Mark: 选中时背景设置
        selectionOverlayView.backgroundColor = UIColor.lightGray
        selectionOverlayView.translatesAutoresizingMaskIntoConstraints = false
        // Mark: 标记代码图片设置
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionOverlayView)
        contentView.addSubview(selectionView)
        // Mark: 点击放大图的手势载体
        let tapView = UIView(frame: .zero)
        tapView.translatesAutoresizingMaskIntoConstraints = false
        tapView.backgroundColor = .clear
        tapView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClick(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tapView.addGestureRecognizer(tap)
        contentView.addSubview(tapView)
        let tapView1 = UIView(frame: .zero)
        tapView1.translatesAutoresizingMaskIntoConstraints = false
        tapView1.backgroundColor = .clear
        tapView1.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapClick(_:)))
        tap1.numberOfTapsRequired = 1
        tap1.numberOfTouchesRequired = 1
        tapView1.addGestureRecognizer(tap1)
        contentView.addSubview(tapView1)
        // Mark: 给图片添加Autolayout约束
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            liveImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            liveImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            liveImageView.heightAnchor.constraint(equalToConstant: 25),
            liveImageView.widthAnchor.constraint(equalToConstant: 25),
            selectionOverlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionOverlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionOverlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionOverlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionView.heightAnchor.constraint(equalToConstant: 25),
            selectionView.widthAnchor.constraint(equalToConstant: 25),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            selectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            tapView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            tapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            tapView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1),
            tapView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            tapView1.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            tapView1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            tapView1.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            tapView1.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5)
        ])
        updateAlpha(isSelected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// cell被重用提前知道【概述】
    ///当前已经被分配的cell如果被重用了(通常是滚动出屏幕外了),会调用cell的prepareForReuse通知cell.【更详细的描述】
    ///
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    /// 更新标记图标及背景的透明度【概述】
    ///
    /// - Parameter selected: 是否被选中
    ///
    func updateAlpha(_ selected: Bool) {
        self.selectionView.isSelected = selected
        if selected {
            self.selectionOverlayView.alpha = 0.3
        } else {
            self.selectionOverlayView.alpha = 0.0
        }
    }
    
    @objc func tapClick(_ tap:UITapGestureRecognizer) {
        if didSelectItemAt != nil {
            didSelectItemAt!(tap)
        }
    }
}
