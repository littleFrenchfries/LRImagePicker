//
//  VideoCollectionViewCell.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/30.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: AssetCollectionViewCell {
    // Mark:底部灰色的图层
    let gradientView = GradientView(frame: .zero)
    // Mark: 视频时长
    let durationLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(gradientView)
        gradientView.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5), .clear]
        gradientView.startPoint = CGPoint(x: 0, y: 1)
        gradientView.endPoint = CGPoint(x: 0, y: 0)
        gradientView.locations = [0.0 , 0.7]
        
        NSLayoutConstraint.activate([
            gradientView.heightAnchor.constraint(equalToConstant: 30),
            gradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        durationLabel.textAlignment = .right
        durationLabel.text = "0:00"
        durationLabel.textColor = .white
        durationLabel.font = UIFont.boldSystemFont(ofSize: 12)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(greaterThanOrEqualTo: gradientView.topAnchor, constant: -4),
            durationLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -4),
            durationLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: -8),
            durationLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
