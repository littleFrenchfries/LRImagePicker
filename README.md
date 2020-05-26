# LRImagePicker
LRImagePicker is a imagePicker
由于项目用swift重构，swift当前图片选择器框架没有特别适合我的，所以我自己搭建了这么一个[LRImagePicker](https://www.jianshu.com/p/992684e4f636)框架，纯swift封装，喜欢给个star。

### 具体使用说明如下：

1. 创建一个Settings实例，如下：
```  

 let setting =Settings()  
  
```  
2. Settings实例有许多自定义设置，可以仔细查看源码，源码中有详细注释，这里先介绍一些常用设置：

* 1) 提供给外部，让外部决定需要什么资源 （照片 视频 音频） 注：默认有照片视频
```  

setting.fetch.assets.supportedMediaTypes = [.image, .video]  

  
```  
* 2)  是否展示3dtouch图片
```  

setting.fetch.preview.showLivePreview = true  


  
```  
* 3) 相册cell的高度
```  

setting.list.albumsCellH = 58  
  
  
```  

* 4) cell之间的间隙大小
```  
  
setting.list.spacing=100  
  
```  

* 5) cell一行有多少个
```  
  
setting.list.cellsPerRow= {(verticalSize, horizontalSize)in

            switch(verticalSize, horizontalSize) {

            case(.compact, .regular):

                return4

            case(.compact, .compact):

                return5

            case(.regular, .regular):

                return7

            default:

                return4

            }

}  
  
```  


* 6) 主题背景颜色 默认白色
```  
  
setting.theme.backgroundColor = .white  
  
```  
* 7) 可以选择的最多张数 默认9张
```  
  
setting.selection.max = 9  
  
```  

* 8) 可以选择最少的张数 默认为1张
```  
  
setting.selection.min = 1  
  
```  

3. 调用相片选择器，调出相册及其返回的结果
```  
  
LRImagePicker.go(settings:setting ,finish: { (assets, isOriginal)in

            print("\(assets)\(isOriginal)")

})  
  
```  
### 其中assets的类型是[PHAsset]类型，isOriginal类型为Bool（true：代表是原图，false：代表是缩略图）。可以根据isOriginal判断是否是原图，用PHAsset来获取你想要的图片，本库这么做主要是为了方便自定义获取图片，可以根据自己实际需求来获取图片，不用再担心框架返回的图片太大或太小而烦恼。
