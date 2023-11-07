//
// Created by kyuubee on 2023/8/13.
// Copyright (c) 2023 qykj. All rights reserved.
//

import Foundation
import Ji

class AvMenu: WebsiteBaseModel {
    override init() {
        super.init()
        websiteName = "AVMenu"
        webUrlStr = "https://javmenu.com/zh/"
        valueArr = ["fc2", "censored", "uncensored", "western"]
    }

    override func getIndexData() -> [ListModel] {
        let idArr = [5, 1, 3, 4]
        let titleArr = ["最新FC", "今日更新", "最新无码", "最新欧美"]
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
                let titleXPath = "//*[@id=\"data\(item)_card\"]/div/div/a/div/img/@alt"
                let urlXPath = "//*[@id=\"data\(item)_card\"]/div/div/a/@href"
                let imgXPath = "//*[@id=\"data\(item)_card\"]/div/div/a/div/img/@data-src"
                let titleNodeArr = jiDoc?.xPath(titleXPath)
                let urlNodeArr = jiDoc?.xPath(urlXPath)
                let imgNodeArr = jiDoc?.xPath(imgXPath)
                for (i, _) in titleNodeArr!.enumerated() {
                    var videoModel = VideoModel.init()
                    videoModel.name = titleNodeArr![i].content!
                    videoModel.webType = websiteType.avmenu.rawValue
                    let detailUrl: String = urlNodeArr![i].content!
                    if detailUrl.contains("http") {
                        videoModel.detailUrl = detailUrl
                    } else {
                        videoModel.detailUrl = webUrlStr + detailUrl
                    }
                    let picUrl: String = imgNodeArr![i].content!
                    videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
                    videoModel.num = "HD"
                    videoModel.type = 3
                    listModel.list.append(videoModel)
                }
            }
            resultArr.append(listModel)
        }
        return resultArr
    }
    override func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        let videoType = valueArr[videoTypeIndex]
        let urlStr = webUrlStr + "\(videoType)?sort=online&page=\(pageNum)"
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        let titleXpath = "//*[@id=\"app\"]/div/div[2]/div[2]/div/div/div/div/div/a/div/img/@alt"
        let urlXpath = "//*[@id=\"app\"]/div/div[2]/div[2]/div/div/div/div[position()>1]/div/a/@href"
        let imgXpath = "//*[@id=\"app\"]/div/div[2]/div[2]/div/div/div/div/div/a/div/img/@data-src"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let urlNodeArr = jiDoc?.xPath(urlXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (i, _) in titleNodeArr!.enumerated() {
            if i == 0{
                continue
            }
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![i].content!
            videoModel.num = "HD"
            let detailUrl: String = urlNodeArr![i].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            let picUrl: String = imgNodeArr![i].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.avmenu.rawValue
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
        let titleXPath = "//*[@id=\"app\"]/div[1]/div[2]/div[2]/div/div[2]/div[3]/ul/li/a/img/@alt"
        let urlXPath = "//*[@id=\"app\"]/div[1]/div[2]/div[2]/div/div[2]/div[3]/ul/li/a/@href"
        let imgXPath = "//*[@id=\"app\"]/div[1]/div[2]/div[2]/div/div[2]/div[3]/ul/li/a/img/@data-src"
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
                model.webType = websiteType.avmenu.rawValue
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
        } else {
            let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
            var videoModel = VideoModel.init()
            videoModel.videoArr = []
            videoModel.serialArr = []
            // 播放地址
            let jsXpath = "//*[@id=\"pills-0\"]/script/text()"
            let jxNodeArr = jiDoc?.xPath(jsXpath)
            if jxNodeArr!.count > 0 {
                var jsItem = jxNodeArr![0].content!
                jsItem = jsItem.replacingOccurrences(of: "m3u8.push(\"", with: "")
                jsItem = jsItem.replacingOccurrences(of: "\")", with: "")
                jsItem = jsItem.replacingOccurrences(of: " ", with: "")
                jsItem = jsItem.replacingOccurrences(of: "\n", with: "")
                videoModel.videoUrl = jsItem
            } else {
                return (result: false, model: videoModel)
            }
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
            let titleXPath = "//*[@id=\"app\"]/div[1]/div[2]/div[2]/div/div[2]/div[3]/ul/li/a/img/@alt"
            let urlXPath = "//*[@id=\"app\"]/div[1]/div[2]/div[2]/div/div[2]/div[3]/ul/li/a/@href"
            let imgXPath = "//*[@id=\"app\"]/div[1]/div[2]/div[2]/div/div[2]/div[3]/ul/li/a/img/@data-src"
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
                    model.webType = websiteType.avmenu.rawValue
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
        let urlStr = webUrlStr + "search?wd=\(keyword)&page=\(pageNum)"
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
        let titleXpath = "//*[@id=\"app\"]/div/div[2]/div[3]/div/div/div/div/div/a/div/img/@alt"
        let detailXpath = "//*[@id=\"app\"]/div/div[2]/div[3]/div/div/div/div/div/a/@href"
        let imgXpath = "//*[@id=\"app\"]/div/div[2]/div[3]/div/div/div/div/div/a/div/img/@data-src"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            if index == 0 {
                continue
            }
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![index].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
            let picUrl: String = imgNodeArr![index].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.avmenu.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
