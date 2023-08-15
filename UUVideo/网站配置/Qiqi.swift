//
// Created by kyuubee on 2023/8/13.
// Copyright (c) 2023 qykj. All rights reserved.
//

import Foundation
import Ji

class Qiqi: WebsiteBaseModel, WebsiteProtocol {
    override init() {
        super.init()
        websiteName = "七七影视"
        webUrlStr = "https://www.qiqiyya1.com/"
    }

    func getIndexData() -> [ListModel] {
        let idArr = [1, 2, 3, 4]
        let titleArr = ["电影", "连续剧", "综艺", "动漫"]
        var resultArr: [ListModel] = []
        for (index, item) in idArr.enumerated() {
            let listModel = ListModel.init()
            listModel.title = titleArr[index]
            listModel.more = true
            listModel.list = []
            let jiDoc = Ji(htmlURL: URL.init(string: webUrlStr)!)
            if jiDoc == nil {
                listModel.list = []
            } else {
                let addXPath = item > 2 ? "" : "/div[1]"
                let titleXPath = "/html/body/div[1]/div[\(item)]\(addXPath)/div[2]/ul/li/div[1]/a/img/@alt"
                let urlXPath = "/html/body/div[1]/div[\(item)]\(addXPath)/div[2]/ul/li/div[1]/a/@href"
                let imgXPath = "/html/body/div[1]/div[\(item)]\(addXPath)/div[2]/ul/li/div[1]/a/img/@src"
                let updateXPath = "/html/body/div[1]/div[\(item)]\(addXPath)/div[2]/ul/li/div[1]/span"
                let titleNodeArr = jiDoc?.xPath(titleXPath)
                let urlNodeArr = jiDoc?.xPath(urlXPath)
                let imgNodeArr = jiDoc?.xPath(imgXPath)
                let updateNodeArr = jiDoc?.xPath(updateXPath)
                for (i, _) in titleNodeArr!.enumerated() {
                    var videoModel = VideoModel.init()
                    videoModel.name = titleNodeArr![i].content!
                    videoModel.webType = websiteType.qiqi.rawValue
                    let detailUrl: String = urlNodeArr![i].content!
                    videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
                    let picUrl: String = imgNodeArr![i].content!
                    videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
                    videoModel.num = updateNodeArr![i].content!
                    videoModel.type = 3
                    listModel.list.append(videoModel)
                }
            }
            resultArr.append(listModel)
        }
        return resultArr
    }

    func getVideoList(urlStr: String) -> [ListModel] {
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        let titleXpath = "/html/body/div[1]/div/div[2]/ul/li/div[1]/a/img/@alt"
        let urlXpath = "/html/body/div[1]/div/div[2]/ul/li/div[1]/a/@href"
        let imgXpath = "/html/body/div[1]/div/div[2]/ul/li/div[1]/a/img/@src"
        let updateXpath = "/html/body/div[1]/div/div[2]/ul/li/div[1]/span"
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
            videoModel.webType = websiteType.qiqi.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }

    func getVideoCategory(urlStr: String) -> [CategoryListModel] {
        [];
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
        //        剧集
        // 获取线路
        let circuitNameXpath = "/html/body/header/div/div[2]/div[3]/div[1]/span"
        let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
        var circuitArr:[CircuitModel] = []
        if circuitNodeArr!.count > 0 {
            for (i,item) in circuitNodeArr!.enumerated() {
                let model = CircuitModel.init()
                model.name = item.content!
                let serialPathXpath = "/html/body/header/div/div[2]/div[3]/div[2]/ul[\(i+1)]/li/a/@href"
                let serialNameXpath = "/html/body/header/div/div[2]/div[3]/div[2]/ul[\(i+1)]/li/a"
                let serialTitleNodeArr = jiDoc?.xPath(serialNameXpath)
                let serialUrlNodeArr = jiDoc?.xPath(serialPathXpath)
                if serialUrlNodeArr!.count > 0 {
                    for (index, item) in serialUrlNodeArr!.enumerated() {
                        let serial = SerialModel.init()
                        serial.name = serialTitleNodeArr![index].content!
                        let serialDetailUrl: String = item.content!
                        serial.detailUrl = Tool.checkUrl(urlStr: serialDetailUrl, domainUrlStr: baseUrl)
                        model.serialArr.append(serial)
                    }
                }
                circuitArr.append(model)
            }
        }
        videoModel.circuitArr = circuitArr
        videoModel.serialNum = videoModel.serialArr.count
        //        推荐视频
        let titleXPath = "//*[@class=\"show\"]/ul/li/div[1]/a/img/@alt"
        let urlXPath = "//*[@class=\"show\"]/ul/li/div[1]/a/@href"
        let imgXPath = "//*[@class=\"show\"]/ul/li/div[1]/a/img/@src"
        let titleNodeArr = jiDoc?.xPath(titleXPath)
        let urlNodeArr = jiDoc?.xPath(urlXPath)
        let imgNodeArr = jiDoc?.xPath(imgXPath)
        if titleNodeArr!.count > 0 {
            for (index, titleNode) in titleNodeArr!.enumerated() {
                var model = VideoModel.init()
                model.name = titleNode.content!
                let imgPic: String = imgNodeArr![index].content!
                model.picUrl = Tool.checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                let recommandUrlStr: String = urlNodeArr![index].content!
                model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                model.webType = websiteType.qiqi.rawValue
                model.num = ""
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
            let jsXpath = "/html/body/div[1]/div[2]/script[1]/text()"
            let jxNodeArr = jiDoc?.xPath(jsXpath)
            if jxNodeArr!.count>0{
                var jsItem = jxNodeArr![0].content!
                jsItem = jsItem.replacingOccurrences(of: "var player_aaaa=", with: "")
                let jsonData = jsItem.data(using: .utf8)!
                let js = try! JSONSerialization.jsonObject(with: jsonData)
                if let dic:Dictionary<String,Any> = js as? Dictionary<String, Any> {
                    let videoUrl = dic["url"] as! String
                    videoModel.videoUrl = videoUrl.removingPercentEncoding!
                }
            }else{
                return (result: true, model: videoModel)
            }
            // 获取剧集
            let circuitNameXpath = "/html/body/div[1]/div[4]/div[1]/span"
            let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
            var circuitArr:[CircuitModel] = []
            if circuitNodeArr!.count > 0 {
                for (i,item) in circuitNodeArr!.enumerated() {
                    let model = CircuitModel.init()
                    model.name = item.content!
                    let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[4]/div[2]/ul[\(i+1)]/li/a")
                    let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[1]/div[4]/div[2]/ul[\(i+1)]/li/a/@href")
                    for (index, _) in serialTitleNodeArr!.enumerated() {
                        let serialModel = SerialModel.init()
                        serialModel.name = serialTitleNodeArr![index].content!
                        serialModel.detailUrl = Tool.checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
                        model.serialArr.append(serialModel)
                    }
                    circuitArr.append(model)
                }
            }
            videoModel.circuitArr = circuitArr

            // 获取推荐视频
            let recommendTitleXpath = "//*[@class=\"show\"]/ul/li/div[1]/a/img/@alt"
            let recommendUrlXpath = "//*[@class=\"show\"]/ul/li/div[1]/a/@href"
            let recommendImgXpath = "//*[@class=\"show\"]/ul/li/div[1]/a/img/@src"
            let recommendTitleNodeArr = jiDoc?.xPath(recommendTitleXpath)
            let recommendUrlNodeArr = jiDoc?.xPath(recommendUrlXpath)
            let recommendImgNodeArr = jiDoc?.xPath(recommendImgXpath)
            if recommendTitleNodeArr!.count > 0 {
                for (index, item) in recommendTitleNodeArr!.enumerated() {
                    var model = VideoModel.init()
                    model.name = item.content!
                    let imgPic: String = recommendImgNodeArr![index].content!
                    model.picUrl = Tool.checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                    let recommandUrlStr: String = recommendUrlNodeArr![index].content!
                    model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                    model.num = ""
                    model.type = 3
                    model.webType = websiteType.qiqi.rawValue
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }

    func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
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
        let titleXpath = "/html/body/div[1]/div/div[2]/ul/li/div[1]/a/img/@alt"
        let detailXpath = "/html/body/div[1]/div/div[2]/ul/li/div[1]/a/@href"
        let imgXpath = "/html/body/div[1]/div/div[2]/ul/li/div[1]/a/img/@src"
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
            videoModel.webType = websiteType.qiqi.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
