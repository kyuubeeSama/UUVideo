//
// Created by kyuubee on 2023/8/8.
// Copyright (c) 2023 qykj. All rights reserved.
//

import Foundation
import Ji
import Alamofire

class AvBro: WebsiteBaseModel, WebsiteProtocol {
    required override init() {
        super.init()
        webUrlStr = "https://avbro.me/"
        websiteName = "兄弟"
    }

    func getIndexData() -> [ListModel] {
        let idArr = [1, 10, 12, 20, 5, 67]
        let titleArr = ["日本", "中文", "无码", "卡通", "欧美", "国产"]
        var resultArr: [ListModel] = []
        for (index, item) in idArr.enumerated() {
            let listModel = ListModel.init()
            listModel.title = titleArr[index]
            listModel.more = true
            listModel.list = []
            let urlStr = webUrlStr + "index.php/vod/show/id/\(item).html"
            let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
            if jiDoc == nil {
                listModel.list = []
            } else {
                let titleXPath = "//*[@id=\"show_page\"]/div[2]/div[2]/div[2]/ul[1]/li/a/@title"
                let urlXPath = "//*[@id=\"show_page\"]/div[2]/div[2]/div[2]/ul[1]/li/a/@href"
                let imgXPath = "//*[@id=\"show_page\"]/div[2]/div[2]/div[2]/ul[1]/li/a/@data-original"
                let updateXPath = "//*[@id=\"show_page\"]/div[2]/div[2]/div[2]/ul[1]/li/div/p[1]/a"
                let titleNodeArr = jiDoc?.xPath(titleXPath)
                let urlNodeArr = jiDoc?.xPath(urlXPath)
                let imgNodeArr = jiDoc?.xPath(imgXPath)
                let updateNodeArr = jiDoc?.xPath(updateXPath)
                for (i, _) in titleNodeArr!.enumerated() {
                    if i < 8 {
                        var videoModel = VideoModel.init()
                        videoModel.name = titleNodeArr![i].content!
                        videoModel.webType = websiteType.avbro.rawValue
                        let detailUrl: String = urlNodeArr![i].content!
                        if detailUrl.contains("http") {
                            videoModel.detailUrl = detailUrl
                        } else {
                            videoModel.detailUrl = webUrlStr + detailUrl
                        }
                        let picUrl: String = imgNodeArr![i].content!
                        if picUrl.contains("http") {
                            videoModel.picUrl = picUrl
                        } else {
                            videoModel.picUrl = webUrlStr + picUrl
                        }
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
        let titleXPath = "//*[@id=\"show_page\"]/div[2]/div[2]/div[2]/ul[1]/li/a/@title"
        let urlXPath = "//*[@id=\"show_page\"]/div[2]/div[2]/div[2]/ul[1]/li/a/@href"
        let imgXPath = "//*[@id=\"show_page\"]/div[2]/div[2]/div[2]/ul[1]/li/a/@data-original"
        let updateXPath = "//*[@id=\"show_page\"]/div[2]/div[2]/div[2]/ul[1]/li/div/p[1]/a"
        let titleNodeArr = jiDoc?.xPath(titleXPath)
        let urlNodeArr = jiDoc?.xPath(urlXPath)
        let imgNodeArr = jiDoc?.xPath(imgXPath)
        let updateNodeArr = jiDoc?.xPath(updateXPath)
        for (i, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![i].content!
            videoModel.num = updateNodeArr![i].content!
            let detailUrl: String = urlNodeArr![i].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            let picUrl: String = imgNodeArr![i].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.avbro.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }

    func getVideoCategory(urlStr: String) -> [CategoryListModel] {
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
        // 获取线路
        let model = CircuitModel.init()
        model.name = "默认线路"
        var circuitArr: [CircuitModel] = []
        let serialPathXpath = "//*[@id=\"bofy\"]/div[2]/div[2]/div[3]/ul/li/a/@href"
        let serialNameXpath = "//*[@id=\"bofy\"]/div[2]/div[2]/div[3]/ul/li/a"
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
        videoModel.circuitArr = circuitArr
        videoModel.serialNum = videoModel.serialArr.count
        //        推荐视频
        let titleXPath = "/html/body/div[3]/div[2]/div[6]/ul/li/div/p[1]/a"
        let urlXPath = "/html/body/div[3]/div[2]/div[6]/ul/li/a/@href"
        let imgXPath = "/html/body/div[3]/div[2]/div[6]/ul/li/a/@data-original"
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
                model.webType = websiteType.avbro.rawValue
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
            let jsXpath = "//*[@id=\"play_page\"]/div[2]/div/div[1]/div[1]/div[1]/script[1]/text()"
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
            var circuitArr: [CircuitModel] = []
            let model = CircuitModel.init()
            model.name = "默认线路"
            let serialTitleNodeArr = jiDoc?.xPath("//*[@id=\"bofy\"]/div[2]/div[2]/div[3]/ul/li/a")
            let serialUrlNodeArr = jiDoc?.xPath("//*[@id=\"bofy\"]/div[2]/div[2]/div[3]/ul/li/a/@href")
            for (index, _) in serialTitleNodeArr!.enumerated() {
                let serialModel = SerialModel.init()
                serialModel.name = serialTitleNodeArr![index].content!
                serialModel.detailUrl = Tool.checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
                model.serialArr.append(serialModel)
            }
            circuitArr.append(model)
            videoModel.circuitArr = circuitArr
            // 获取推荐视频
            let recommendTitleXpath = "//*[@id=\"play_page\"]/div[3]/div[1]/div[4]/ul/li/a/@title"
            let recommendUrlXpath = "//*[@id=\"play_page\"]/div[3]/div[1]/div[4]/ul/li/a/@href"
            let recommendImgXpath = "//*[@id=\"play_page\"]/div[3]/div[1]/div[4]/ul/li/a/@data-original"
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
                    model.webType = websiteType.avbro.rawValue
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }

    func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        let urlStr = webUrlStr + "index.php/vod/search/page/\(pageNum)/wd/\(keyword).html"
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
        let titleXpath = "/html/body/div[2]/div[2]/div[1]/ul[1]/li/div[1]/a/@title"
        let detailXpath = "/html/body/div[2]/div[2]/div[1]/ul[1]/li/div[1]/a/@href"
        let imgXpath = "/html/body/div[2]/div[2]/div[1]/ul[1]/li/div[1]/a/@data-original"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            if index > 0 {
                var videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![index].content!
                videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
                videoModel.picUrl = Tool.checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
                videoModel.type = 3
                videoModel.webType = websiteType.avbro.rawValue
                listModel.list.append(videoModel)
            }
        }
        return [listModel]
    }

}
