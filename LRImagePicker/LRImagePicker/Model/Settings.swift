//
//  Settings.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/3/24.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import Photos

// Mark: - 照片选择设置类
public class Settings: NSObject {
    deinit {
//        print("=====================\(self)未内存泄露")
    }
    // Mark: 是否是高性能模式，减少占用内存选true
    public lazy var fastMode:Bool = false
    // Mark: Fetch 设置实例
    public lazy var fetch = Fetch()
    // Mark: 相册中资源列表的设置
    public lazy var list = List()
    // Mark: 主题设置实例
    public lazy var theme = Theme()
    // Mark: 选择张数实例
    public lazy var selection = Selection()
    // Mark: - 从系统中拿取
    public class Fetch {
        // Mark:  取出相册中资源实例
        public lazy var assets = Assets()
        // Mark:  相册实例
        public lazy var album = Album()
        // Mark:  资源显示实例
        public lazy var preview = Preview()
        // Mark: - 相册
        public class Album {
            public lazy var options: PHFetchOptions = {
                PHFetchOptions()
            }()
            // Mark: 相册结果数组
            public lazy var fetchResults: [PHFetchResult<PHAssetCollection>] = {
                [PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)] + [PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)]
            }()
        }
        // Mark: - 照片 视频 音频
        public class Assets {
            // Mark: 分类
            public enum MediaTypes {
                case image
                case video
                case audio
                // Mark: 系统分类
                fileprivate var assetMediaType: PHAssetMediaType {
                    switch self {
                    case .image:
                        return .image
                    case .video:
                        return .video
                    case .audio:
                        return .audio
                    }
                }
            }
            // Mark: 提供给外部，让外部决定需要什么资源 （照片 视频 音频） 注：默认只有照片
            public lazy var supportedMediaTypes: Set<MediaTypes> = [.image, .video]
            // Mark: 用PHFetchOptions中的谓词过滤获取
            public lazy var options: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let rawMediaTypes = supportedMediaTypes.map { $0.assetMediaType.rawValue }//筛选掉unknown
                let predicate = NSPredicate(format: "mediaType IN %@", rawMediaTypes)
                fetchOptions.predicate = predicate
                return fetchOptions
            }()
        }
        // Mark: 显示资源
        public class Preview {
            
            // Mark: 是否需要剪裁
            public lazy var allowCrop: Bool = false
            // Mark: 是否需要剪裁
            public lazy var videoLong: Float = 20
            // Mark: 是否展示3dtouch图片
            public lazy var showLivePreview: Bool = false
            // Mark: 图片
            public lazy var photoOptions: PHImageRequestOptions = {
                let options = PHImageRequestOptions()
                // Mark: 允许从iCloud云中下载图片
                options.isNetworkAccessAllowed = true
                return options
            }()
            // Mark: 3d图片
            @available(iOS 9.1, *)
            public lazy var livePhotoOptions: PHLivePhotoRequestOptions = {
                let options = PHLivePhotoRequestOptions()
                // Mark: 允许从iCloud云中下载sd图片
                options.isNetworkAccessAllowed = true
                return options
            }()
            // Mark: 视频
            public lazy var videoOptions: PHVideoRequestOptions = {
                let options = PHVideoRequestOptions()
                // Mark: 允许从iCloud云中下载视频
                options.isNetworkAccessAllowed = true
                return options
            }()
            // Mark: 图片压缩
            func getPriviewSize(originSize: CGSize) -> CGSize {
                let width = originSize.width
                let height = originSize.height
                let pixelScale = CGFloat(width)/CGFloat(height)
                var targetSize = CGSize()
                if width <= 1280 && height <= 1280 {
                    //a，图片宽或者高均小于或等于1280时图片尺寸保持不变，不改变图片大小
                    targetSize.width = CGFloat(width)
                    targetSize.height = CGFloat(height)
                } else if width > 1280 && height > 1280 {
                    //宽以及高均大于1280，但是图片宽高比例大于(小于)2时，则宽或者高取小(大)的等比压缩至1280
                    if pixelScale > 2 {
                        targetSize.width = 1280*pixelScale
                        targetSize.height = 1280
                    } else if pixelScale < 0.5 {
                        targetSize.width = 1280
                        targetSize.height = 1280/pixelScale
                    } else if pixelScale > 1 {
                        targetSize.width = 1280
                        targetSize.height = 1280/pixelScale
                    } else {
                        targetSize.width = 1280*pixelScale
                        targetSize.height = 1280
                    }
                } else {
                    //b,宽或者高大于1280，但是图片宽度高度比例小于或等于2，则将图片宽或者高取大的等比压缩至1280
                    if pixelScale <= 2 && pixelScale > 1 {
                        targetSize.width = 1280
                        targetSize.height = 1280/pixelScale
                    } else if pixelScale > 0.5 && pixelScale <= 1 {
                        targetSize.width = 1280*pixelScale
                        targetSize.height = 1280
                    } else {
                        targetSize.width = CGFloat(width)
                        targetSize.height = CGFloat(height)
                    }
                }
                return targetSize
            }
        }
    }
    // Mark: - 相册中资源的列表设置
    public class List {
        // Mark: cell之间的间隙大小
        public lazy var spacing: CGFloat = 2
        
        // Mark:一个返回cell一行有多少个的函数，可自定义
        public lazy var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 4
            case (.compact, .compact): // iPhone5-6 landscape
                return 5
            case (.regular, .regular): // iPad portrait/landscape
                return 7
            default:
                return 4
            }
        }
        
        // Mark: 相册cell的高度
        public lazy var albumsCellH: CGFloat = 58
    }
    // Mark: - 主题设置
    public class Theme {
        // Mark: 主题背景颜色 默认白色
        public lazy var backgroundColor: UIColor = .white
        // Mark: 主题导航栏颜色 默认白色
        public lazy var navigationBarColor: UIColor = .white
        // Mark: 相册名称字体设置
        public lazy var albumTitleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        // Mark: 相册数量字体设置
        public lazy var albumSubTitleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
        // Mark: 图片被选中时标记代码图片的填充颜色
        public lazy var selectionFillColor: UIColor = UIView().tintColor
        // Mark: 图片被选中时标记排名Label的颜色
        public lazy var selectionStrokeColor: UIColor = .white
        // Mark:标记代码图片的样式
        public enum SelectionStyle {
            // Mark: ✅
            case checked
            // Mark: 🔢
            case numbered
        }
        // Mark: 图片被选中时 标记代码图片的样式 例：✅ or 🔢
        public lazy var selectionStyle: SelectionStyle = .numbered
    }
    // Mark: 选择图片设置
    public class Selection {
        // Mark:  可以选择的最多张数 默认9张
        public lazy var max: Int = 9
        // Mark:  可以选择最少的张数 默认为1张
        public lazy var min: Int = 1
    }
}
