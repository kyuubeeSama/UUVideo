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
        let model:WebsiteBaseModel = websiteModelArr[type.rawValue]
        let array = model.getIndexData()
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
    func getVideoListData(videoTypeIndex:Int, category:(area:String, year:String, videoCategory:String), type: websiteType, pageNum:Int, success: @escaping (_ listData: [ListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        let model:WebsiteBaseModel = websiteModelArr[type.rawValue]
        let array:[ListModel] = model.getVideoList(videoTypeIndex: videoTypeIndex, category: category, pageNum: pageNum)
        if array.isEmpty {
            failure(XPathError.getContentFail)
        }else{
            success(array)
        }
    }

    /// MARK: 获取分类数据
    /// - Parameters:
    ///   - urlStr: 请求地址
    ///   - type: 站点
    ///   - success: 成功返回
    ///   - failure: 失败返回
    /// - Returns: 空
    func getWebsiteCategoryData(videoTypeIndex:Int, type: websiteType, success: @escaping (_ listData: [CategoryListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        let model:WebsiteBaseModel = websiteModelArr[type.rawValue]
        let array:[CategoryListModel] = model.getVideoCategory(videoTypeIndex: videoTypeIndex)
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
        let model:WebsiteBaseModel = websiteModelArr[type.rawValue]
        let result:(result:Bool,model:VideoModel) = model.getVideoDetail(urlStr: urlStr)
        if result.result == false {
            failure(XPathError.getContentFail)
        }else{
            success(result.model)
        }
    }

    // MARK: 搜索数据
    func getSearchData(pageNum: Int, keyword: String, website: websiteType, success: @escaping (_ searchData: [ListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        let model:WebsiteBaseModel = websiteModelArr[website.rawValue]
        var array:[ListModel] = model.getSearchData(pageNum: pageNum, keyword: keyword)
        if array.isEmpty {
            failure(XPathError.getContentFail)
        }else{
            success(array)
        }
    }

    //MARK: 获取播放界面
    func getVideoPlayerData(urlStr: String, website: websiteType, success: @escaping (_ videoModel: VideoModel) -> (), failure: @escaping (_ error: Error) -> ()) {
        let model:WebsiteBaseModel = websiteModelArr[website.rawValue]
        var result:(result:Bool,model:VideoModel) = model.getVideoPlayerDetail(urlStr: urlStr)
        if result.result == false {
            failure(XPathError.getContentFail)
        }else{
            success(result.model)
        }
    }
}
