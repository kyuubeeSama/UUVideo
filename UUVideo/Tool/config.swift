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
var indexArr:[(title:String,list:[IndexModel])] {
    [(title:"其他",list:[
        IndexModel.init(title: "本地视频"),
        IndexModel.init(title: "新番时间表"),
        IndexModel.init(title: "聚合搜索")
    ]),
     (title:"站点",list:[
        IndexModel.init(title: "哈哩哈哩", type: 1, webType: .halihali),
        IndexModel.init(title: "来快播", type: 1, webType: .laikuaibo),
        IndexModel.init(title: "樱花动漫", type: 1, webType: .sakura),
//        IndexModel.init(title: "剧知晓", type: 1, webType: .juzhixiao),
        IndexModel.init(title: "免费电影", type: 1, webType: .mianfei),
//        IndexModel.init(title: "七号楼", type: 1, webType: .qihaolou),
//        IndexModel.init(title: "樱花影视",type: 1,webType: .SakuraYingShi),
        IndexModel.init(title: "要看伦理", type: 1, webType: .Yklunli),
//        IndexModel.init(title: "第六电影网",type: 1,webType: .sixMovie),
//        IndexModel.init(title: "老野人",type: 1,webType: .lawyering),
         IndexModel.init(title: "未命名", type: 1, webType: .sese),
        IndexModel.init(title: "Thotsflix",type: 1,webType: .thotsflix),
         IndexModel.init(title: "HeiHD",type: 1,webType: .HeiHD),
         IndexModel.init(title: "兄弟", type: 1, webType: .avbro),
         IndexModel.init(title: "七七影视",type: 1,webType: .qiqi),
         IndexModel.init(title: "AVMenu", type: 1, webType: .avmenu)
     ]),
     (title:"个人中心",list:[
        IndexModel.init(title: "历史记录"),
        IndexModel.init(title: "我的收藏")
     ])]
}
// 站点地址
let urlArr = [
    Halihali.init().webUrlStr,
    Laikuaibo.init().webUrlStr,
    Sakura.init().webUrlStr,
    Juzhixiao.init().webUrlStr,
    Mianfei.init().webUrlStr,
    Qihaolou.init().webUrlStr,
    SakuraYingShi.init().webUrlStr,
    Yklunli.init().webUrlStr,
    SixMovie.init().webUrlStr,
    Lawyering.init().webUrlStr,
    SeSe.init().webUrlStr,
    Thotsflix.init().webUrlStr,
    HeiHD.init().webUrlStr,
    AvBro.init().webUrlStr,
    Qiqi.init().webUrlStr,
    AvMenu.init().webUrlStr
]
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
    case SakuraYingShi = 6
    case Yklunli = 7
    case sixMovie = 8
    case lawyering = 9
    case sese = 10
    case thotsflix = 11
    case HeiHD = 12
    case avbro = 13
    case qiqi = 14
    case avmenu = 15
}
