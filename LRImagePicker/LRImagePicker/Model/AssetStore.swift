//
//  AssetStore.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/4/2.
//  Copyright © 2020 wangxu. All rights reserved.
//

import Foundation
import Photos

public class AssetStore {
    public private(set) var assets: [PHAsset]

    public init(assets: [PHAsset] = []) {
        self.assets = assets
    }

    public var count: Int {
        return assets.count
    }

    func contains(_ asset: PHAsset) -> Bool {
        return assets.contains(asset)
    }

    func append(_ asset: PHAsset) {
        guard contains(asset) == false else { return }
        assets.append(asset)
    }

    func remove(_ asset: PHAsset) {
        guard let index = assets.firstIndex(of: asset) else { return }
        assets.remove(at: index)
    }
    
    func removeFirst() -> PHAsset? {
        return assets.removeFirst()
    }

    func index(of asset: PHAsset) -> Int? {
        return assets.firstIndex(of: asset)
    }
}
