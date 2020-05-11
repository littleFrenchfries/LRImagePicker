//
//  ToolHeadView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/24.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class ToolHeadView: UIView {
    
    var backBlock: (() -> ())?
    var selectBlock: (() -> ())?
    var settings: Settings! {
        didSet { selectionView.settings = settings }
    }
    // Mark:代码标记图片
    let selectionView: SelectView = SelectView(frame: .zero)
    private let backArrowView: BackArrowView = BackArrowView()
    init() {
        super.init(frame: .zero)
        // Mark: 标记代码图片设置
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(selectTap))
        selectionView.addGestureRecognizer(tap1)
        backArrowView.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(backTap))
        backArrowView.addGestureRecognizer(tap)
        addSubview(selectionView)
        addSubview(backArrowView)
        NSLayoutConstraint.activate([
            selectionView.heightAnchor.constraint(equalToConstant: 25),
            selectionView.widthAnchor.constraint(equalToConstant: 25),
            selectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            selectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            backArrowView.heightAnchor.constraint(equalToConstant: 60),
            backArrowView.widthAnchor.constraint(equalToConstant: 60),
            backArrowView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            backArrowView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
    }
    
    @objc func backTap() {
        if let block = backBlock {
            block()
        }
    }
    @objc func selectTap() {
        
        if let block = selectBlock {
            block()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
