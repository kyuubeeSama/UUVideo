//
//  VideoModel.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import Photos
class VideoModel: NSObject {
    //1.本地视频 2.相册视频 3.在线视频 4.番剧
    var type:Int?
//    视频名
    var name:String?
    // 本地地址
    var filePath:String?
    // 时长
    var time:Int?
    // 封面图片
    var pic:UIImage?
    // 本地相册文件
    var asset:PHAsset?
    // 视频线上地址
    var videoUrl:String?
    // 线上详情地址
    var detailUrl:String?
    //线上封面地址
    var picUrl:String?
    // 最新一集
    var num:String?
}
