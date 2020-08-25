//
//  ClippingImageViewController.swift
//  LRImagePicker
//
//  Created by wangxu on 2020/8/20.
//  Copyright © 2020 wangxu. All rights reserved.
//

import UIKit
import PhotosUI

protocol ClippingImageViewControllerDelegate {
    func clippingImageViewController(_ clippingImageViewController: ClippingImageViewController, didSend image: UIImage)
    func clippingImageViewController(_ clippingImageViewController: ClippingImageViewController, cancel image: UIImage)
}

class ClippingImageViewController: UIViewController {
    
    // Mark: - 本地相册 最近取消的中英文，暂时没找到系统中的获取方法
    var Cancel: String {
        guard let localeLanguageCode = NSLocale.current.languageCode else { return "取消" }
        if localeLanguageCode == "zh"  {
            return "取消"
        } else {
            return "Cancel"
        }
    }
    
    // Mark: - 本地相册 最近完成的中英文，暂时没找到系统中的获取方法
    var Done: String {
        guard let localeLanguageCode = NSLocale.current.languageCode else { return "取消" }
        if localeLanguageCode == "zh"  {
            return "完成"
        } else {
            return "Done"
        }
    }
    
    var bottomHeight: Int {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPhone10,3": fallthrough
        case "iPhone10,6": fallthrough
        case "iPhone11,8": fallthrough
        case "iPhone11,2": fallthrough
        case "iPhone11,4": fallthrough
        case "iPhone11,6": fallthrough
        case "iPhone12,1": fallthrough
        case "iPhone12,3": fallthrough
        case "iPhone12,5": return 34
        default: return 10
        }
    }
    
    var cropBgView = UIView()
    
    var cropView = UIView()
    
    var collectionView: UICollectionView?
//    var store:AssetStore
    var asset: PHAsset
    
    var delegate: ClippingImageViewControllerDelegate?
    
    
    init(/*store: AssetStore*/ asset: PHAsset) {
//        self.store = store
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configCollectionView()
        configCropView()
        let leftBtn = UIButton(type: .custom)
        leftBtn.setTitle(Cancel, for: .normal)
        leftBtn.setTitleColor(.blue, for: .normal)
        leftBtn.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        leftBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftBtn)
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setTitle(Done, for: .normal)
        rightBtn.setTitleColor(UIColor(red: 255, green: 180, blue: 0, alpha: 1), for: .normal)
        rightBtn.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        rightBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightBtn)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                leftBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                leftBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -CGFloat(bottomHeight)),
                rightBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                rightBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -CGFloat(bottomHeight)),
                
            ])
        } else {
            NSLayoutConstraint.activate([
                leftBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                leftBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
                rightBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                rightBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            ])
        }
    }
    
    func configCollectionView() -> Void {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width + 20, height: view.frame.size.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: CGRect(x: -10, y: 0, width: view.frame.size.width + 20, height: view.frame.size.height), collectionViewLayout: layout)
        collectionView?.backgroundColor = .black
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.isPagingEnabled = true
        collectionView?.scrollsToTop = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.contentOffset = CGPoint(x: 0, y: 0)
        collectionView?.contentSize = CGSize(width: CGFloat(view.frame.width + 20), height: 0)
        view.addSubview(collectionView!)
        collectionView?.register(ClippingImageCollectionViewCell.self, forCellWithReuseIdentifier: "ClippingImageCollectionViewCell")
        
    }
    
    func configCropView() -> Void {
        cropBgView.isUserInteractionEnabled = false
        cropBgView.backgroundColor = .clear
        cropBgView.frame = view.bounds
        view.addSubview(cropBgView)
        overlayClippingWithView(view: cropBgView, cropRect: cropRect, containerView: view, needCircleCrop: true)
        cropView.isUserInteractionEnabled = false
        cropView.frame = cropRect
        cropView.backgroundColor = .clear
        cropView.layer.borderColor = UIColor.white.cgColor
        cropView.layer.borderWidth = 1
        cropView.layer.cornerRadius = cropRect.size.width / 2
        cropView.clipsToBounds = true
        view.addSubview(cropView)
    }
    
    var cropRect: CGRect {
        CGRect(x: 0, y: (view.frame.height - view.frame.size.width) / 2, width: view.frame.width, height: view.frame.width)
    }
    
    
    func overlayClippingWithView(view: UIView, cropRect: CGRect, containerView: UIView, needCircleCrop: Bool) -> Void {
        let path = UIBezierPath(rect: UIScreen.main.bounds)
        let layer = CAShapeLayer()
        if needCircleCrop {//圆形裁剪框
            path.append(UIBezierPath.init(arcCenter: containerView.center, radius: cropRect.size.width / 2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: false))
        } else {//矩形裁剪框
            path.append(UIBezierPath(rect: cropRect))
        }
        layer.path = path.cgPath
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0.5
        view.layer.addSublayer(layer)
    }
    
    // MARK:获得剪裁后的图片
    func cropImageView(imageView: UIImageView, rect: CGRect, zoomScale: Double, containerView: UIView) -> UIImage {
        var transform = CGAffineTransform.identity
        //平移的处理
        let imageViewRect = imageView.convert(imageView.bounds, to: containerView)
        let point = CGPoint(x: imageViewRect.origin.x + imageViewRect.size.width / 2, y: imageViewRect.origin.y + imageViewRect.size.height / 2)
        let xMargin = containerView.frame.size.width - rect.maxX - rect.origin.x
        
        let zeroPoint = CGPoint(x: (containerView.frame.size.width - xMargin) / 2, y: containerView.center.y)
        
        let translation = CGPoint(x: point.x - zeroPoint.x, y: point.y - zeroPoint.y)
        transform = transform.translatedBy(x: translation.x, y: translation.y)
        //缩放处理
        transform = transform.scaledBy(x: CGFloat(zoomScale), y: CGFloat(zoomScale))
        let imageRef = newTransformedImage(transform: transform, sourceImage: imageView.image!.cgImage!, sourceSize: imageView.image!.size, outputWidth: rect.size.width * UIScreen.main.scale, cropSize: rect.size, imageViewSize: imageView.frame.size)!
        var cropedImage = UIImage.init(cgImage: imageRef)
        cropedImage = fixOrientation(aImage: cropedImage)
        return cropedImage
    }
    
    func newTransformedImage(transform: CGAffineTransform, sourceImage: CGImage, sourceSize: CGSize, outputWidth: CGFloat, cropSize: CGSize, imageViewSize: CGSize) -> CGImage? {
        guard let source = newScaledImage(source: sourceImage, size: sourceSize) else { return nil }
        let aspect = cropSize.height / cropSize.width
        let outputSize = CGSize(width: outputWidth, height: outputWidth * aspect)
        let context = CGContext.init(data: nil, width: Int(outputSize.width), height: Int(outputSize.height), bitsPerComponent: source.bitsPerComponent, bytesPerRow: 0, space: source.colorSpace!, bitmapInfo: source.bitmapInfo.rawValue)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height))
        var uiCoords = CGAffineTransform.init(scaleX: outputSize.width / cropSize.width, y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width / 2.0, y: cropSize.height / 2.0)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        context?.concatenate(uiCoords)
        context?.concatenate(transform)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(source, in: CGRect(x: -imageViewSize.width / 2, y: -imageViewSize.height / 2.0, width: imageViewSize.width, height: imageViewSize.height))
        let result = context?.makeImage()
        return result
    }
    
    func newScaledImage(source: CGImage, size: CGSize) -> CGImage? {
        let srcSize = size
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bmpInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue|CGBitmapInfo.byteOrder32Big.rawValue)
        guard let context = CGContext.init(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: rgbColorSpace, bitmapInfo: bmpInfo.rawValue) else { return  nil}
        context.interpolationQuality = .none
        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.draw(source, in: CGRect(x: -srcSize.width / 2, y: -srcSize.height / 2, width: srcSize.width, height: srcSize.height))
        let result = context.makeImage()
        return result
    }
    
    func fixOrientation(aImage: UIImage) -> UIImage {
        if aImage.imageOrientation == .up {
            return aImage
        }
        var transform = CGAffineTransform.identity
        switch aImage.imageOrientation {
        case .down: fallthrough
        case .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: aImage.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .left: fallthrough
        case .leftMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
        case .right: fallthrough
        case .rightMirrored:
            transform = transform.translatedBy(x: 0, y: aImage.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            break
        default:
            break
        }
        switch aImage.imageOrientation {
        case .upMirrored:
            fallthrough
        case .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored:
            fallthrough
        case .rightMirrored:
            transform = transform.translatedBy(x: aImage.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }
        let ctx = CGContext.init(data: nil, width: Int(aImage.size.width), height: Int(aImage.size.height), bitsPerComponent: aImage.cgImage?.bitsPerComponent ?? 0, bytesPerRow: 0, space: aImage.cgImage!.colorSpace!, bitmapInfo: aImage.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        switch aImage.imageOrientation {
        case .left: fallthrough
        case .leftMirrored: fallthrough
        case .right: fallthrough
        case .rightMirrored:
            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.height, height: aImage.size.width))
            break
        default:
            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height))
            break
        }
        let cgimag = ctx?.makeImage()
        let img = UIImage.init(cgImage: cgimag!)
        return img
    }
    
    func circularClipImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        ctx?.addEllipse(in: rect)
        ctx?.clip()
        image.draw(in: rect)
        let circleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return circleImage ?? UIImage()
    }
    
    @objc func doneButtonClick() -> Void {
        guard let cell = collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) as? ClippingImageCollectionViewCell else {
            return
        }
        guard let previewView = cell.previewView else { return }
        var cropedImage = cropImageView(imageView: previewView.imageView, rect: cropRect, zoomScale: Double(previewView.scrollView.zoomScale), containerView: view)
        cropedImage = circularClipImage(image: cropedImage)
        if let delegate = delegate {
            delegate.clippingImageViewController(self, didSend: cropedImage)
        }
    }
    
    @objc func cancelButtonClick() -> Void {
        guard let cell = collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) as? ClippingImageCollectionViewCell else {
            return
        }
        guard let previewView = cell.previewView else { return }
        var cropedImage = cropImageView(imageView: previewView.imageView, rect: cropRect, zoomScale: Double(previewView.scrollView.zoomScale), containerView: view)
        cropedImage = circularClipImage(image: cropedImage)
        if let delegate = delegate {
            delegate.clippingImageViewController(self, cancel: cropedImage)
        }
    }
    
}

extension ClippingImageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClippingImageCollectionViewCell", for: indexPath) as? ClippingImageCollectionViewCell else { return UICollectionViewCell() }
        cell.cropRect = cropRect
        cell.asset = asset
//        cell.singleTapGestureBlock = {[weak self] in
//
//        }
//        cell.imageProgressUpdateBlock = {[weak self](progress) in
//
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ClippingImageCollectionViewCell else { return }
        cell.recoverSubviews()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ClippingImageCollectionViewCell else { return }
        cell.recoverSubviews()
    }
}
