//
//  VideoModel.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import Photos
class videoModel: NSObject {
    var name:String?
    var filePath:String?
    var time:Int?
    var pic:UIImage?
    var asset:PHAsset?
    //1.本地视频 2.相册视频 3.在线视频
    var type:Int?
}
