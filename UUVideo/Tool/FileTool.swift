//
//  FileTool.swift
//  QYAudio
//
//  Created by liuqingyuan on 2020/5/12.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class FileTool: NSObject {
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
    // TODO:获取本地视频
    func getAudioFileList()->Array<VideoModel>{
        // TODO:获取本地音乐文件
        var array:[VideoModel] = []
        let path = self.getDocumentPath().appending("/video")
        print("路径是\(path)")
        //        let dirEnum = fileManager.enumerator(atPath: path)
        
        let enumerator = FileManager.default.enumerator(atPath: path)
        while let fileName = enumerator?.nextObject() as? String {
            print(fileName)
            
            if let fType = enumerator?.fileAttributes?[FileAttributeKey.type] as? FileAttributeType{
                switch fType{
                case .typeRegular:
                    print("文件")
                    if fileName.contains(".mp4") || fileName.contains(".avi"){
                        let model:VideoModel = VideoModel.init()
                        //                            model.fileName = fileName
                        //                            model.filePath = path+"/"+fileName
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
}
