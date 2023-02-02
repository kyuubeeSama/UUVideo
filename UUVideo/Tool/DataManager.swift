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
            case .mianfei:
                array = Mianfei.init().getIndexData()
            case .qihaolou:
                array = Qihaolou.init().getIndexData()
            case .SakuraYingShi:
                array = SakuraYingShi.init().getIndexData()
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
        case .mianfei:
            array = Mianfei.init().getVideoList(urlStr: urlStr)
        case .qihaolou:
            array = Qihaolou.init().getVideoList(urlStr: urlStr)
        case .SakuraYingShi:
            array = SakuraYingShi.init().getVideoList(urlStr: urlStr)
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
        case .mianfei:
            array = Mianfei.init().getVideoCategory(urlStr: urlStr)
        case .qihaolou:
            array = Qihaolou.init().getVideoCategory(urlStr: urlStr)
        case .SakuraYingShi:
            array = SakuraYingShi.init().getVideoCategory(urlStr: urlStr)
        }
        if array.isEmpty {
            failure(XPathError.getContentFail)
        }else{
            success(array)
        }
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
        case .mianfei:
            result = Mianfei.init().getVideoDetail(urlStr: urlStr)
        case .qihaolou:
            result = Qihaolou.init().getVideoDetail(urlStr: urlStr)
        case .SakuraYingShi:
            result = SakuraYingShi.init().getVideoDetail(urlStr: urlStr)
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
        case .mianfei:
            array = Mianfei.init().getSearchData(urlStr: urlStr, keyword: keyword)
        case .qihaolou:
            array = Qihaolou.init().getSearchData(urlStr: urlStr, keyword: keyword)
        case .SakuraYingShi:
            array = SakuraYingShi.init().getSearchData(urlStr: urlStr, keyword: keyword)
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
        case .mianfei:
            result = Mianfei.init().getVideoPlayerDetail(urlStr: urlStr)
        case .qihaolou:
            result = Qihaolou.init().getVideoPlayerDetail(urlStr: urlStr)
        case .SakuraYingShi:
            result = SakuraYingShi.init().getVideoPlayerDetail(urlStr: urlStr)
        }
        if result.result == false {
            failure(XPathError.getContentFail)
        }else{
            success(result.model)
        }
    }
}
