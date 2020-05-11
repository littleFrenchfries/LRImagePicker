//
//  AlbumsCollectionViewCell.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/31.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    let albumImageView = UIImageView(frame: .zero)
    let albumLabel = UILabel(frame: .zero)
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        contentView.addSubview(albumImageView)
        albumLabel.translatesAutoresizingMaskIntoConstraints = false
        albumLabel.numberOfLines = 0
        contentView.addSubview(albumLabel)
        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            albumImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            albumImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.96),
            albumImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.96),
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            albumLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 8),
            albumLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            albumLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            albumLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
