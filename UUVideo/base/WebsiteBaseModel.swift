//
//  WebsiteBaseModel.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/9.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
// 站点基类
class WebsiteBaseModel: NSObject {
    // 站点网址
    public var webUrlStr = ""
    // 站点名字
    public var websiteName = ""
    // 首页类型
    public var categoryDic: [String: String] = [:]
}
// 站点需要实现的方法
protocol WebsiteProtocol {
    // 获取首页数据
    func getIndexData()->[ListModel]

    // 获取视频列表
    func getVideoList(urlStr:String)->[ListModel]

    // 获取视频分类
    func getVideoCategory(urlStr: String)->[CategoryListModel]

    // 获取视频详情
    func getVideoDetail(urlStr: String)->(result:Bool,model:VideoModel)
    // 获取视频播放界面
    func getVideoPlayerDetail(urlStr:String)->(result:Bool,model:VideoModel)
    // 搜索功能
    func getSearchData(pageNum:Int,keyword:String)->[ListModel]
}
