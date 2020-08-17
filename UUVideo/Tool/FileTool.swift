//
//  FileTool.swift
//  QYAudio
//
//  Created by liuqingyuan on 2020/5/12.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
class FileTool: NSObject {
    var getPhoneVideoComplete:((_ videoArr:[videoModel])->())?
    
    /// 获取document文件夹
    func getDocumentPath()->String{
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    //    创建文件夹
    func createDirectory(path:String) throws ->Bool{
        let fileManger = FileManager.default
        var isDirectory:ObjCBool = false
        let isExist = fileManger.fileExists(atPath: path, isDirectory: &isDirectory)
        // 文件是否存在
        if !isExist {
            do{
                try fileManger.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                return true
            }catch let error{
                print(error)
                return false
            }
        }else{
            return true
        }
    }
    //    TODO:创建文件
    func createFile(document:String,fileData:Data) -> Bool {
        let path = self.getDocumentPath().appending(document)
        let fileManager = FileManager.default
        let isDirExist = fileManager.fileExists(atPath: path)
        if !isDirExist {
            let bCreateDir = fileManager.createFile(atPath: path, contents: fileData, attributes: nil)
            if bCreateDir {
                return true
            }else{
                return false
            }
        }else{
            return true
        }
    }
    //    TODO:删除文件
    func deleteFileWithPath(path:String) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
            return true
        }catch{
            return false
        }
    }
    // TODO:获取本地视频相关信息
    func getVideoFileList()->Array<videoModel>{
        var array:[videoModel] = []
        let path = self.getDocumentPath().appending("/video")
//        print("路径是\(path)")
        //        let dirEnum = fileManager.enumerator(atPath: path)

        let enumerator = FileManager.default.enumerator(atPath: path)
        while let fileName = enumerator?.nextObject() as? String {
            print(fileName)
            if let fType = enumerator?.fileAttributes?[FileAttributeKey.type] as? FileAttributeType{
                switch fType{
                case .typeRegular:
                    print("文件")
                    // 简化文件名截取功能
                    let fileType = fileName.split(separator: ".")[1]
                    print(fileType)
                    let typeArr:[String] = ["MP4","mp4","AVI","avi"]
                    if typeArr.contains(String(fileType)){
                        let model:videoModel = videoModel.init()
                        let filePath = path+"/"+fileName
                        model.type = 1
                        model.name = fileName
                        model.filePath = filePath
                        model.time = self.getVideoTime(path: filePath)
                        model.pic = self.getVideoImage(path: filePath)
                        array.append(model)
                    }
                case .typeDirectory:
                    print("文件夹")
                default:
                    print("未知类型")
                }
            }
        }
        return array
    }
    // 获取视频时长
    func getVideoTime(path:String) -> Int {
        let asset = AVURLAsset.init(url: URL.init(fileURLWithPath: path))
        let time:CMTime = asset.duration
        let second:Int = Int(Int(time.value)/Int(time.timescale))
        return second
    }
    // 获取视频缩略图
    func getVideoImage(path:String)->UIImage{
        let asset = AVURLAsset.init(url: URL.init(fileURLWithPath: path))
        let gen = AVAssetImageGenerator.init(asset: asset)
        gen.appliesPreferredTrackTransform = true
        gen.apertureMode = .encodedPixels
        let time:CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        var image:CGImage
        do {
            image = try gen.copyCGImage(at: time, actualTime: nil)
            let thumb = UIImage.init(cgImage: image)
            return thumb
        } catch let error {
            print(error)
            return UIImage.init(named: "默认图片")!
        }
    }
    // 获取相册图片
    func getPhoneVideo(){
        var result:[videoModel] = []
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized{
                // 通过请求
                // 获取相册中的视频
                let assets = self.getAllAssetInPhotoAblum(ascending: false)
                if assets.count>0 {
                    // 有视频资源
                    for item:PHAsset in assets {
                        let option = PHVideoRequestOptions.init()
                        option.deliveryMode = .highQualityFormat
                        let fileName:String = item.value(forKey: "filename") as! String
                        let fileType:String = String(fileName.split(separator: ".")[1])
                        let typeArr:[String] = ["MP4","mp4","AVI","avi"]
                        if typeArr.contains(fileType) {
                            let model = videoModel.init()
                            model.type = 2
                            model.name = fileName
                            model.asset = item
                            model.time = Int(item.duration)
                            PHImageManager.default().requestImage(for: item, targetSize: CGSize(width: 160, height: 90), contentMode: .default, options: PHImageRequestOptions.init()) { (image, info) in
                                model.pic = image
                            }
                            result.append(model)
                        }
                    }
                }
                if self.getPhoneVideoComplete != nil {
                    self.getPhoneVideoComplete!(result)
                }
            }else if status == .denied{
                // 拒绝请求
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "imageStatusDenied"), object: nil, userInfo: nil)
            }
        }
    }
//    获取相册中所有视频资源
    func getAllAssetInPhotoAblum(ascending:Bool)->[PHAsset]{
        var assets:[PHAsset] = []
        let option = PHFetchOptions.init()
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: ascending)]
        let result = PHAsset.fetchAssets(with: .video, options: option)
        result.enumerateObjects { (asset, idx, stop) in
            assets.append(asset)
        }
        return assets
    }
}
