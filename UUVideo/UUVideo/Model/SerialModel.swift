//
//  SerialModel.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/4.
//  Copyright © 2020 qykj. All rights reserved.
//  剧集

import UIKit

class SerialModel: NSObject {
    // 剧集名
    var name:String = ""
    // 剧集详情地址
    var detailUrl:String = ""
    // 视频播放地址
    var playerUrl:String = ""
    // 是否选中该剧集
    var ischoose:Bool? = false
}
