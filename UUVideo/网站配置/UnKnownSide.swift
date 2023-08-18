//
//  UnKnownSide.swift
//  UUVideo
//
//  Created by Galaxy on 2023/8/18.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji
class UnKnownSide: WebsiteBaseModel,WebsiteProtocol {
    override init() {
        super.init()
        websiteName = "unknownSide"
        webUrlStr = "https://unknownside.com/"
        valueArr = ["巨乳","乱伦中文av","制服中文av","调教中文av","人妻中文av","出轨中文av","无码中文av","强奸中文av"]
    }
    
    func getIndexData() -> [ListModel] {
        var resultArr: [ListModel] = []
        for (index,item) in valueArr.enumerated() {
            let listModel = ListModel.init()
            listModel.title = valueArr[index]
            listModel.more = true
            listModel.list = []
            var value = "category/\(item)/"
            if index == 0 {
             value = "category/video/\(item)/"
            }
            var urlStr = webUrlStr+value
            urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL.init(string: urlStr)!
            let jiDoc = Ji(htmlURL: url)
            if jiDoc == nil{
                listModel.list = []
            }else{
                let titleXPath = "//*[@class=\"king-post-item\"]/article/div[3]/div[1]/header/h2/a"
                let urlXPath = "//*[@class=\"king-post-item\"]/article/a/@href"
                let imgXPath = "//*[@class=\"king-post-item\"]/article/a/img/@data-src"
                let titleNodeArr = jiDoc?.xPath(titleXPath)
                let urlNodeArr = jiDoc?.xPath(urlXPath)
                let imgNodeArr = jiDoc?.xPath(imgXPath)
                for (i, _) in titleNodeArr!.enumerated() {
                    if i < 8{
                        var videoModel = VideoModel.init()
                        videoModel.name = titleNodeArr![i].content!
                        videoModel.webType = websiteType.unknownside.rawValue
                        videoModel.num = "HD"
                        let detailUrl: String = urlNodeArr![i].content!
                        videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
                        let picUrl: String = imgNodeArr![i].content!
                        videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
                        videoModel.num = ""
                        videoModel.type = 3
                        listModel.list.append(videoModel)
                    }
                }
            }
            resultArr.append(listModel)
        }
        return resultArr
    }
    func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        var videoType = valueArr[videoTypeIndex]
        if videoTypeIndex == 0 {
         videoType = "video/\(videoType)"
        }
        let urlStr = webUrlStr + "category/\(videoType)/page/\(pageNum)"
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        let titleXpath = "//*[@class=\"king-post-item\"]/article/div[3]/div[1]/header/h2/a"
        let urlXpath = "//*[@class=\"king-post-item\"]/article/a/@href"
        let imgXpath = "//*[@class=\"king-post-item\"]/article/a/img/@data-src"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let urlNodeArr = jiDoc?.xPath(urlXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (i, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![i].content!
            videoModel.num = "HD"
            let detailUrl: String = urlNodeArr![i].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            let picUrl: String = imgNodeArr![i].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.unknownside.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
    func getVideoCategory(videoTypeIndex: Int) -> [CategoryListModel] {
        []
    }
    
    func getVideoDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            return (result: false, model: VideoModel.init())
        }
        let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
        var videoModel = VideoModel.init()
        videoModel.detailUrl = urlStr
        videoModel.videoArr = []
        videoModel.tagArr = []
        videoModel.serialArr = []
        videoModel.picUrl = ""
        //        剧集
        // 获取线路
        let model = CircuitModel.init()
        model.name = "默认线路"
        let serialModel = SerialModel.init()
        serialModel.name = "默认"
        serialModel.detailUrl = urlStr
        model.serialArr.append(serialModel)
        let circuitArr:[CircuitModel] = [model]
        videoModel.circuitArr = circuitArr
        videoModel.serialNum = videoModel.serialArr.count
        //        推荐视频
        let titleXPath = "//*[@class=\"king-simple-post\"]/header/span/a"
        let urlXPath = "//*[@class=\"king-simple-post\"]/a/@href"
        let imgXPath = "//*[@class=\"king-simple-post\"]/a/img/@data-src"
        let titleNodeArr = jiDoc?.xPath(titleXPath)
        let urlNodeArr = jiDoc?.xPath(urlXPath)
        let imgNodeArr = jiDoc?.xPath(imgXPath)
        if titleNodeArr!.count > 0 {
            for (index, titleNode) in titleNodeArr!.enumerated() {
                var model = VideoModel.init()
                model.name = titleNode.content!
                let picUrl: String = imgNodeArr![index].content!
                model.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
                let recommandUrlStr: String = urlNodeArr![index].content!
                model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                model.webType = websiteType.unknownside.rawValue
                model.num = "HD"
                model.type = 3
                videoModel.videoArr.append(model)
            }
        }
        return (result: true, model: videoModel)
    }
    
    func getVideoPlayerDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            return (result: false, model: VideoModel.init())
        } else {
            let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
            var videoModel = VideoModel.init()
            videoModel.videoArr = []
            videoModel.serialArr = []
            // 播放地址
            let jsXpath = "//*[@id=\"main\"]/div[1]/script/text()"
            let jxNodeArr = jiDoc?.xPath(jsXpath)
            if jxNodeArr!.count>0{
                let str = jxNodeArr![0].content!
                let strArr = str.split(separator: "'")
                videoModel.videoUrl = String(strArr[1])
            }else{
                return (result: true, model: videoModel)
            }
            // 获取线路
            let model = CircuitModel.init()
            model.name = "默认线路"
            let serialModel = SerialModel.init()
            serialModel.name = "默认"
            serialModel.detailUrl = urlStr
            model.serialArr.append(serialModel)
            let circuitArr:[CircuitModel] = [model]
            videoModel.circuitArr = circuitArr
            videoModel.serialNum = videoModel.serialArr.count
            //        推荐视频
            let titleXPath = "//*[@class=\"king-simple-post\"]/header/span/a"
            let urlXPath = "//*[@class=\"king-simple-post\"]/a/@href"
            let imgXPath = "//*[@class=\"king-simple-post\"]/a/img/@data-src"
            let titleNodeArr = jiDoc?.xPath(titleXPath)
            let urlNodeArr = jiDoc?.xPath(urlXPath)
            let imgNodeArr = jiDoc?.xPath(imgXPath)
            if titleNodeArr!.count > 0 {
                for (index, titleNode) in titleNodeArr!.enumerated() {
                    var model = VideoModel.init()
                    model.name = titleNode.content!
                    let picUrl: String = imgNodeArr![index].content!
                    model.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
                    let recommandUrlStr: String = urlNodeArr![index].content!
                    model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                    model.webType = websiteType.unknownside.rawValue
                    model.num = ""
                    model.type = 3
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }
    
    func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        let urlStr = webUrlStr + "/page/\(pageNum)//?s=\(keyword)"
        let listModel = ListModel.init()
        listModel.title = "搜索关键字:" + keyword
        listModel.more = false
        listModel.list = []
        let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let titleXpath = "//*[@class=\"king-post-item\"]/article/div[3]/div[1]/header/h2/a"
        let detailXpath = "//*[@class=\"king-post-item\"]/article/a/@href"
        let imgXpath = "//*[@class=\"king-post-item\"]/article/a/img/@data-src"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![index].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
            let picUrl: String = imgNodeArr![index].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.unknownside.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
