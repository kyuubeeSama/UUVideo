//
//  VideoModel.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import Photos
import HandyJSON
struct VideoModel:HandyJSON {
    //1.本地视频 2.相册视频 3.在线视频 4.番剧 5.普通视频
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
    var videoUrl:String = ""
    // 线上详情地址
    var detailUrl:String?
    //线上封面地址
    var picUrl:String = ""
    // 最新集或者评分等信息
    var num:String = ""
    // 推荐视频
    var videoArr:[VideoModel] = []
    // 剧集列表
    var serialArr:[SerialModel] = []
    // 剧集总个数
    var serialNum:Int = 0
    // 详情地址
    // MARK:哈哩哈哩时，此处地址只是保存一下详情地址，具体播放地址会根据serialindex重新定位。来快播时，保存当前剧集地址
    var serialDetailUrl:String = ""
    // 记录当前播放的视频的名字，在播放历史时，需要根据名字做对比
    var serialName:String = ""
    // 详情标签
    var tagArr:[[String]] = []
    // 数据库中存储的id
    var video_id:Int?
    // 站点
    var webType:Int?
    //当前播放的剧集
    var serialIndex:Int = 0
    // 当前剧集播放的进度,与播放的剧集搭配使用
    var progress:Int = 0
    
    // 获取单个tag字符串
    func getTag(tagArr:[String]) -> String {
        var string = ""
        for tag in tagArr {
            string = "\(string) \(tag)"
        }
        return string
    }
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            name <-- "title"
        mapper <<<
            num  <-- "lianzaijs"
        mapper <<<
            detailUrl <-- "url"
        mapper <<<
            picUrl <-- "thumb"
    }
}
