//
//  config.swift
//  InsuranceDemo
//
//  Created by liuqingyuan on 2019/11/28.
//  Copyright © 2019 qykj. All rights reserved.
//

import Foundation
import UIKit

let screenW = UIScreen.main.bounds.size.width
let screenH = UIScreen.main.bounds.size.height
var top_height = UIApplication.shared.statusBarFrame.size.height+44
// 站点标题
let indexArr = [(title:"站点",list:["本地视频", "新番时间表", "哈哩哈哩","来快播","樱花动漫","剧知晓","免费电影","七号楼"]),(title:"个人中心",list:["历史记录","我的收藏"])]
// 站点地址
let urlArr = [Halihali.init().webUrlStr, Laikuaibo.init().webUrlStr,Sakura.init().webUrlStr,Juzhixiao.init().webUrlStr,Mianfei.init().webUrlStr,Qihaolou.init().webUrlStr]
enum XPathError: Error {
    case getContentFail
}

enum websiteType: Int {
    case halihali = 0
    case laikuaibo = 1
    case sakura = 2
    case juzhixiao = 3
    case mianfei = 4
    case qihaolou = 5
}
