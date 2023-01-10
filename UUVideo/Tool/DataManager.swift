//
//  DataManager.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/18.
//  Copyright © 2020 qykj. All rights reserved.
//

import Foundation
import Ji
import Alamofire
import SwiftyJSON
import GRDB
import HandyJSON

class DataManager: NSObject {
    /// MARK: 获取新番数据
    /// - Parameters:
    ///   - dayIndex: 当前为第几天
    ///   - success: 返回视频列表
    ///   - failure: 返回错误
    /// - Returns: 空
    func getBangumiData(dayIndex: Int, success: @escaping (_ listArr: [VideoModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        let array = Halihali.init().getBanggumiData(dayIndex: dayIndex)
        if array.isEmpty {
            failure(XPathError.getContentFail)
        }else{
            success(array)
        }
    }

    /// MARK: 获取站点首页数据
    /// - Parameters:
    ///   - type: 站点
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: nil
    func getWebsiteIndexData(type: websiteType, success: @escaping (_ listData: [ListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
            var array:[ListModel] = []
            switch type{
            case .halihali:
                array = Halihali.init().getIndexData()
            case .sakura:
                array = Sakura.init().getIndexData()
            case .laikuaibo:
                array = Laikuaibo.init().getIndexData()
            case .juzhixiao:
                array = Juzhixiao.init().getIndexData()
            }
            if array.isEmpty {
                failure(XPathError.getContentFail)
            }else{
                success(array)
            }
    }

    /// MARK: 获取视频列表
    /// - Parameters:
    ///   - urlStr: 站点地址
    ///   - type: 站点
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: nil
    func getVideoListData(urlStr: String, type: websiteType, success: @escaping (_ listData: [ListModel],_ allPageNum:NSInteger) -> (), failure: @escaping (_ error: Error) -> ()) {
        var array:[ListModel] = []
        switch type{
        case .halihali:
            array = Halihali.init().getVideoList(urlStr: urlStr)
        case .laikuaibo:
            array = Laikuaibo.init().getVideoList(urlStr: urlStr)
        case .sakura:
            array = Sakura.init().getVideoList(urlStr: urlStr)
        case .juzhixiao:
            array = Juzhixiao.init().getVideoList(urlStr: urlStr)
        }
        if array.isEmpty {
            failure(XPathError.getContentFail)
        }else{
            success(array,0)
        }
    }

    /// MARK: 获取分类数据
    /// - Parameters:
    ///   - urlStr: 请求地址
    ///   - type: 站点
    ///   - success: 成功返回
    ///   - failure: 失败返回
    /// - Returns: 空
    func getWebsiteCategoryData(urlStr: String, type: websiteType, success: @escaping (_ listData: [CategoryListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        var array:[CategoryListModel] = []
        switch type{
        case .halihali:
            array = Halihali.init().getVideoCategory(urlStr: urlStr)
        case .laikuaibo:
            array = []
        case .sakura:
            array = Sakura.init().getVideoCategory(urlStr: urlStr)
        case .juzhixiao:
            array = Juzhixiao.init().getVideoCategory(urlStr: urlStr)
        }
        if array.isEmpty {
            failure(XPathError.getContentFail)
        }else{
            success(array)
        }
//        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
//        if jiDoc == nil {
//            failure(XPathError.getContentFail)
//        } else {
//            var listArr: [CategoryListModel] = []
//            let titleArr = [["按剧情", "按年代", "按地区"],[],[],["类型","地区","年代"]]
//            if type == .halihali {
//                for item in 1...3 {
//                    let chooseArr = ["", "", "js-tongjip "]
//                    let titleXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a"
//                    let urlXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a/@href"
//                    let chooseXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a[@class='\(chooseArr[item - 1])on']"
//                    let titleNodeArr = jiDoc?.xPath(titleXpath)
//                    let urlNodeArr = jiDoc?.xPath(urlXpath)
//                    let chooseNodeArr = jiDoc?.xPath(chooseXpath)
//                    let listModel = CategoryListModel.init()
//                    listModel.name = titleArr[type.rawValue][item - 1]
//                    listModel.list = []
//                    for (index, _) in titleNodeArr!.enumerated() {
//                        let categoryModel = CategoryModel.init()
//                        let name = titleNodeArr![index].content
//                        categoryModel.name = name
//                        let detailUrl = urlNodeArr![index].content
//                        let detailUrlArr = detailUrl?.components(separatedBy: "/")
//                        if chooseNodeArr!.count > 0 && name == chooseNodeArr![0].content {
//                            categoryModel.ischoose = true
//                        }
//                        if item == 1 {
//                            categoryModel.value = detailUrlArr![5]
//                        } else if item == 2 {
//                            categoryModel.value = detailUrlArr![4]
//                        } else {
//                            categoryModel.value = detailUrlArr![6]
//                        }
//                        listModel.list.append(categoryModel)
//                    }
//                    listArr.append(listModel)
//                }
//                success(listArr)
//            } else if type == .juzhixiao{
//                let nodeValue = ["mcid","area","year"]
//                // 地区，剧情，年代
//                for (index,item) in nodeValue.enumerated() {
//                    let dataNodeArr = jiDoc?.xPath("//*[@id=\"\(item)\"]/li[position()>1]/a/@data")
//                    let titleNodeArr = jiDoc?.xPath("//*[@id=\"\(item)\"]/li[position()>1]/a")
//                    let listModel = CategoryListModel.init()
//                    listModel.name = titleArr[type.rawValue][index]
//                    listModel.list = []
//                    for (index1,item1) in dataNodeArr!.enumerated() {
//                        let categoryModel = CategoryModel.init()
//                        let titleNode = titleNodeArr![index1]
//                        categoryModel.name = titleNode.content
//                        categoryModel.value = item1.content
//                        categoryModel.ischoose = index1 == 0
//                        listModel.list.append(categoryModel)
//                    }
//                    listArr.append(listModel)
//                }
//                success(listArr)
//            }else {
//                // 地区
//                let areaNodeArr = jiDoc?.xPath("/html/body/div[1]/dl/dd[2]/div/div/a")
//                let areaChooseNodeArr = jiDoc?.xPath("/html/body/div[1]/dl/dd[2]/div/div/a[@class='btn-success']")
//                let areaListModel = CategoryListModel.init()
//                areaListModel.name = "地区"
//                areaListModel.list = []
//                // 将具体的分类编入数组
//                for (index, _) in areaNodeArr!.enumerated() {
//                    let categoryModel = CategoryModel.init()
//                    let name = areaNodeArr![index].content
//                    categoryModel.name = name
//                    // 获取当前选中的分类
//                    for chooseNode in areaChooseNodeArr! {
//                        if name == chooseNode.content {
//                            categoryModel.ischoose = true
//                        }
//                    }
//                    areaListModel.list.append(categoryModel)
//                }
//                listArr.append(areaListModel)
//                // 排序
//                let orderNodeArr = jiDoc?.xPath("/html/body/div[1]/div[3]/div/a")
//                let orderChooseNodeArr = jiDoc?.xPath("/html/body/div[1]/div[3]/div/a[@class='btn-success']")
//                let orderListModel = CategoryListModel.init()
//                orderListModel.name = "排序"
//                orderListModel.list = []
//                // 将具体的分类编入数组
//                for (index, _) in orderNodeArr!.enumerated() {
//                    let categoryModel = CategoryModel.init()
//                    let name = orderNodeArr![index].content
//                    categoryModel.name = name
//                    // 获取当前选中的分类
//                    for chooseNode in orderChooseNodeArr! {
//                        if name == chooseNode.content {
//                            categoryModel.ischoose = true
//                        }
//                    }
//                    orderListModel.list.append(categoryModel)
//                }
//                listArr.append(orderListModel)
//                success(listArr)
//            }
//        }
    }

    /// MARK: 获取视频详情界面相关数据
    /// - Parameters:
    ///   - urlStr: 视频地址
    ///   - type:
    ///   - success: 成功返回
    ///   - failure:
    /// - Returns: listArr:[videoModel]
    func getVideoDetailData(urlStr: String, type: websiteType, success: @escaping (_ VideoModel: VideoModel) -> (), failure: @escaping (_ error: Error) -> ()) {
        var result:(result:Bool,model:VideoModel)
        switch type{
        case .halihali:
            result = Halihali.init().getVideoDetail(urlStr: urlStr)
        case .laikuaibo:
            result = Laikuaibo.init().getVideoDetail(urlStr: urlStr)
        case .sakura:
            result = Sakura.init().getVideoDetail(urlStr: urlStr)
        case .juzhixiao:
            result = Juzhixiao.init().getVideoDetail(urlStr: urlStr)
        }
        if result.result == false {
            failure(XPathError.getContentFail)
        }else{
            success(result.model)
        }
    }

    // MARK: 搜索数据
    func getSearchData(urlStr: String, keyword: String, website: websiteType, success: @escaping (_ searchData: [ListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        var array:[ListModel] = []
        switch website{
        case .halihali:
            array = Halihali.init().getSearchData(urlStr: urlStr, keyword: keyword)
        case .laikuaibo:
            array = Laikuaibo.init().getSearchData(urlStr: urlStr, keyword: keyword)
        case .sakura:
            array = Sakura.init().getSearchData(urlStr: urlStr, keyword: keyword)
        case .juzhixiao:
            array = Juzhixiao.init().getSearchData(urlStr: urlStr, keyword: keyword)
        }
        if array.isEmpty {
            failure(XPathError.getContentFail)
        }else{
            success(array)
        }
    }

    //MARK: 获取播放界面
    func getVideoPlayerData(urlStr: String, website: websiteType, success: @escaping (_ videoModel: VideoModel) -> (), failure: @escaping (_ error: Error) -> ()) {
        var result:(result:Bool,model:VideoModel)
        switch website{
        case .halihali:
            result = Halihali.init().getVideoPlayerDetail(urlStr: urlStr)
        case .laikuaibo:
            result = Laikuaibo.init().getVideoPlayerDetail(urlStr: urlStr)
        case .sakura:
            result = Sakura.init().getVideoPlayerDetail(urlStr: urlStr)
        case .juzhixiao:
            result = Juzhixiao.init().getVideoPlayerDetail(urlStr: urlStr)
        }
        if result.result == false {
            failure(XPathError.getContentFail)
        }else{
            success(result.model)
        }
    }
}
