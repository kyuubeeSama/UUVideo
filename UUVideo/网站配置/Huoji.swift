//
//  Huoji.swift
//  UUVideo
//
//  Created by kyuubee on 2023/11/5.
//  Copyright © 2023 qykj. All rights reserved.
//

import Foundation
import Ji
class Huoji:WebsiteBaseModel {
    override init() {
        super.init()
        websiteName = "火鸡影院"
        webUrlStr = "https://huoj.org/"
        valueArr = ["21","23","20","22","24","25"]
    }
    
    override func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [3, 4, 5, 6, 7, 8]
        let titleArr = ["剧情","中字","国产","动漫","无码","国外"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div[1]/div/div[\(item)]/ul/li/h4/a"
            let urlXpath = "/html/body/div[1]/div/div[\(item)]/ul/li/h4/a/@href"
            let imgXpath = "/html/body/div[1]/div/div[\(item)]/ul/li/a/@data-original"
            let titleNodeArr = jiDoc?.xPath(titleXpath)
            let urlNodeArr = jiDoc?.xPath(urlXpath)
            let imgNodeArr = jiDoc?.xPath(imgXpath)
            listModel.title = titleArr[index]
            listModel.more = true
            listModel.list = []
            for (i, _) in titleNodeArr!.enumerated() {
                var videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content!
                videoModel.webType = websiteType.huoji.rawValue
                let detailUrl: String = urlNodeArr![i].content!
                videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
                let picUrl: String = imgNodeArr![i].content!
                videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
                videoModel.num = ""
                videoModel.type = 3
                listModel.list.append(videoModel)
            }
            resultArr.append(listModel)
        }
        return resultArr
    }
    override func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        let videoType = valueArr[videoTypeIndex]
        let urlStr = webUrlStr + "vodtype/\(videoType)-\(pageNum).html"
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        let titleXpath = "/html/body/div[1]/div/div[3]/ul[1]/li/h4/a"
        let urlXpath = "/html/body/div[1]/div/div[3]/ul[1]/li/h4/a/@href"
        let imgXpath = "/html/body/div[1]/div/div[3]/ul[1]/li/a/@data-original"
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
            videoModel.webType = websiteType.huoji.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
    override func getVideoCategory(videoTypeIndex: Int) -> [CategoryListModel] {
        []
    }
    
    override func getVideoDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
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
        let videoXpath = "/html/body/div[1]/div/div[3]/div/div[2]/div[1]/a/@href"
        let videoNodeArr = jiDoc?.xPath(videoXpath)
        if videoNodeArr!.count > 0{
            serialModel.detailUrl = videoNodeArr![0].content!
        }else{
            serialModel.detailUrl = ""
        }
        model.serialArr.append(serialModel)
        let circuitArr:[CircuitModel] = [model]
        videoModel.circuitArr = circuitArr
        videoModel.serialNum = videoModel.serialArr.count
        //        推荐视频
        let titleXPath = "/html/body/div[1]/div/div[5]/ul/li/h4/a"
        let urlXPath = "/html/body/div[1]/div/div[5]/ul/li/h4/a/@href"
        let imgXPath = "/html/body/div[1]/div/div[5]/ul/li/a/@data-original"
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
                model.webType = websiteType.huoji.rawValue
                model.num = "HD"
                model.type = 3
                videoModel.videoArr.append(model)
            }
        }
        return (result: true, model: videoModel)
    }
    
    override func getVideoPlayerDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
        let jiDoc = Ji(htmlURL: URL.init(string: webUrlStr+urlStr)!)
        if jiDoc == nil {
            return (result: false, model: VideoModel.init())
        } else {
            let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: webUrlStr+urlStr)[0]
            var videoModel = VideoModel.init()
            videoModel.videoArr = []
            videoModel.serialArr = []
            // 播放地址
            let jsXpath = "/html/body/div[1]/div/div[3]/div[1]/div/script[1]/text()"
            let jxNodeArr = jiDoc?.xPath(jsXpath)
            if jxNodeArr!.count > 0 {
                var jsItem = jxNodeArr![0].content!
                jsItem = jsItem.replacingOccurrences(of: "var player_aaaa=", with: "")
                let jsonData = jsItem.data(using: .utf8)!
                let js = try! JSONSerialization.jsonObject(with: jsonData)
                if let dic: Dictionary<String, Any> = js as? Dictionary<String, Any> {
                    videoModel.videoUrl = dic["url"] as! String
                }
            } else {
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
            let titleXPath = "/html/body/div[1]/div/div[8]/ul/li/h4/a"
            let urlXPath = "/html/body/div[1]/div/div[8]/ul/li/h4/a/@href"
            let imgXPath = "/html/body/div[1]/div/div[8]/ul/li/a/@data-original"
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
                    model.webType = websiteType.huoji.rawValue
                    model.num = ""
                    model.type = 3
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }
    
    override func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        let urlStr = webUrlStr + "vodsearch/\(keyword)----------\(pageNum)---.html"
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
        let titleXpath = "/html/body/div[1]/div/div[3]/ul[1]/li/h4/a"
        let detailXpath = "/html/body/div[1]/div/div[3]/ul[1]/li/h4/a/@href"
        let imgXpath = "/html/body/div[1]/div/div[3]/ul[1]/li/a/@data-original"
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
            videoModel.webType = websiteType.huoji.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
