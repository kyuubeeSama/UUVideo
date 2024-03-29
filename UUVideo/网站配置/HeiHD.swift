//
// Created by Galaxy on 2023/7/27.
// Copyright (c) 2023 qykj. All rights reserved.
//
import Foundation
import Ji
import SwiftyJSON
import Alamofire

class HeiHD: WebsiteBaseModel {
    required override init() {
        super.init()
        webUrlStr = "https://www.heihd.com/"
        websiteName = "HeiHD"
        valueArr = ["new", "hot", "like", "tags/100001"]
    }
    override func getIndexData() -> [ListModel] {
        let idArr = ["new", "hot", "like", "tags/100001"]
        let titleArr = ["最新", "热门", "推荐", "无码"]
        var resultArr: [ListModel] = []
        for (index, item) in idArr.enumerated() {
            let listModel = ListModel.init()
            listModel.title = titleArr[index]
            listModel.more = true
            listModel.list = []
            let urlStr = webUrlStr + "\(item).html"
            let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
            if jiDoc == nil {
                listModel.list = []
            } else {
                let titleXpath = "/html/body/div[2]/div[1]/ul/a/li[2]"
                let urlXpath = "/html/body/div[2]/div[1]/ul/a/@href"
                let imgXpath = "/html/body/div[2]/div[1]/ul/a/li[1]/img/@img"
                let updateXpath = "/html/body/div[2]/div[1]/ul/a/li[1]/span[2]"
                let titleNodeArr = jiDoc?.xPath(titleXpath)
                let urlNodeArr = jiDoc?.xPath(urlXpath)
                let imgNodeArr = jiDoc?.xPath(imgXpath)
                let updateNodeArr = jiDoc?.xPath(updateXpath)
                for (i, _) in titleNodeArr!.enumerated() {
                    if i < 8 {
                        var videoModel = VideoModel.init()
                        videoModel.name = titleNodeArr![i].content!
                        videoModel.webType = websiteType.HeiHD.rawValue
                        let detailUrl: String = urlNodeArr![i].content!
                        videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
                        let picUrl: String = imgNodeArr![i].content!
                        videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
                        videoModel.num = updateNodeArr![i].content!
                        videoModel.type = 3
                        listModel.list.append(videoModel)
                    }
                }
            }
            resultArr.append(listModel)
        }
        return resultArr
    }
    override func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        let videoType = valueArr[videoTypeIndex]
        let urlStr = webUrlStr + "\(videoType)-\(pageNum).html"
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        let titleXpath = "/html/body/div[2]/div[1]/ul/a/li[2]"
        let urlXpath = "/html/body/div[2]/div[1]/ul/a/@href"
        let imgXpath = "/html/body/div[2]/div[1]/ul/a/li[1]/img/@img"
        let updateXpath = "/html/body/div[2]/div[1]/ul/a/li[1]/span[2]"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let urlNodeArr = jiDoc?.xPath(urlXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        let updateNodeArr = jiDoc?.xPath(updateXpath)
        for (i, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![i].content!
            videoModel.num = updateNodeArr![i].content!
            let detailUrl: String = urlNodeArr![i].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            let picUrl: String = imgNodeArr![i].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.HeiHD.rawValue
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
        serialModel.detailUrl = urlStr
        model.serialArr.append(serialModel)
        let circuitArr: [CircuitModel] = [model]
        videoModel.circuitArr = circuitArr
        videoModel.serialNum = videoModel.serialArr.count
        //        推荐视频
        let titleXPath = "/html/body/div[2]/div/div[2]/div/ul/a/@title"
        let urlXPath = "/html/body/div[2]/div/div[2]/div/ul/a/@href"
        let imgXPath = "/html/body/div[2]/div/div[2]/div/ul/a/li[1]/img/@img"
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
                model.webType = websiteType.sese.rawValue
                model.num = ""
                model.type = 3
                videoModel.videoArr.append(model)
            }
        }
        return (result: true, model: videoModel)
    }
    override func getVideoPlayerDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            return (result: false, model: VideoModel.init())
        }
        let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
        let iframeXpath = "//*[@id=\"video\"]/@src"
        let iframeNodeArr = jiDoc?.xPath(iframeXpath)
        let iframeUrl = iframeNodeArr![0].content
        let newUrl = "\(webUrlStr)\(iframeUrl ?? "")"
        let jiDoc1 = Ji(htmlURL: URL.init(string: newUrl)!)
        if jiDoc1 == nil {
            return (result: false, model: VideoModel.init())
        }
        let jsXpath = "/html/body/script/text()"
        let jsNodeArr = jiDoc1?.xPath(jsXpath)
        var jsStr = jsNodeArr![0].content ?? ""
        jsStr = jsStr.replacingOccurrences(of: "\n", with: "")
        jsStr = jsStr.replacingOccurrences(of: "\r", with: "")
        jsStr = jsStr.replacingOccurrences(of: " ", with: "")
        let array = jsStr.split(separator: ",")
        var string = String(array[5])
        string = string.replacingOccurrences(of: "video:{url:\'", with: "")
        string = string.replacingOccurrences(of: "'", with: "")
        print(string)
        var videoModel = VideoModel.init()
        videoModel.videoArr = []
        videoModel.serialArr = []
        videoModel.videoUrl = string
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
        let titleXPath = "/html/body/div[2]/div/div[2]/div/ul/a/@title"
        let urlXPath = "/html/body/div[2]/div/div[2]/div/ul/a/@href"
        let imgXPath = "/html/body/div[2]/div/div[2]/div/ul/a/li[1]/img/@img"
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
                model.webType = websiteType.HeiHD.rawValue
                model.num = ""
                model.type = 3
                videoModel.videoArr.append(model)
            }
        }
        videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return (result: true, model: videoModel)
    }
    override func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        []
    }
}
