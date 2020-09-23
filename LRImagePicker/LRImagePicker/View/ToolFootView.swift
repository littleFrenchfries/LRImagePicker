//
//  ToolFootView.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/24.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class ToolFootView: UIView {
    var lookBlock: (() -> ())?
    var sendBlock: (() -> ())?
    let lookBtn = UIButton(type: .custom)
    let originBtn = UIButton(type: .custom)
    let sendBtn = UIButton(type: .custom)
    var settings: Settings! {
        didSet { icon.settings = settings
            if settings.fetch.preview.allowCrop {
                lookBtn.isHidden = true
            }
        }
    }
    let icon: OriginalView = OriginalView(frame: .zero)
    var count = 0
    
    init() {
        super.init(frame: .zero)
        lookBtn.translatesAutoresizingMaskIntoConstraints = false
        lookBtn.setTitle("  预览  ", for: .normal)
        lookBtn.addTarget(self, action: #selector(lookLink), for: .touchUpInside)
        lookBtn.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6), for: .normal)
        addSubview(lookBtn)
        originBtn.translatesAutoresizingMaskIntoConstraints = false
        originBtn.setTitle("原图", for: .normal)
        originBtn.addTarget(self, action: #selector(originalLink), for: .touchUpInside)
        originBtn.setTitleColor(.white, for: .normal)
        addSubview(originBtn)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.setTitle("  发送  ", for: .normal)
        sendBtn.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6), for: .normal)
        sendBtn.backgroundColor = .darkGray
        sendBtn.layer.masksToBounds = true
        sendBtn.layer.cornerRadius = 4
        sendBtn.addTarget(self, action: #selector(sendLink), for: .touchUpInside)
        addSubview(sendBtn)
        let tap = UITapGestureRecognizer(target: self, action: #selector(originalLink))
        icon.addGestureRecognizer(tap)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        NSLayoutConstraint.activate([
            lookBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            lookBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            originBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 10),
            originBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            icon.trailingAnchor.constraint(equalTo: originBtn.leadingAnchor, constant: -4),
            icon.centerYAnchor.constraint(equalTo: originBtn.centerYAnchor),
            icon.heightAnchor.constraint(equalToConstant: 20),
            icon.widthAnchor.constraint(equalToConstant: 20),
            sendBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            sendBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            sendBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    var sendBtnIndex: Int {
        set {
            count = newValue
            if newValue>0 {
                sendBtn.setTitle("  发送 \(newValue)  ", for: .normal)
                sendBtn.setTitleColor(.white, for: .normal)
                sendBtn.isEnabled = true
                sendBtn.backgroundColor = settings.theme.selectionFillColor
                lookBtn.setTitleColor(.white, for: .normal)
                lookBtn.isEnabled = true
            }else {
                sendBtn.setTitle("  发送  ", for: .normal)
                sendBtn.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6), for: .normal)
                sendBtn.isEnabled = false
                sendBtn.backgroundColor = .darkGray
                lookBtn.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.6), for: .normal)
                lookBtn.isEnabled = false
            }
        }
        get {
            count
        }
    }
    
    
    @objc func originalLink() {
        icon.isSelected = !icon.isSelected
    }
    
    @objc func lookLink() {
        if let block = lookBlock {
            block()
        }
    }
    
    @objc func sendLink() {
        if let block = sendBlock {
            block()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
