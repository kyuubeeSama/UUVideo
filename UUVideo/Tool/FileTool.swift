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
    static func getDocumentPath()->String{
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
//    TODO:创建文件夹
//    TODO:创建文件
}
