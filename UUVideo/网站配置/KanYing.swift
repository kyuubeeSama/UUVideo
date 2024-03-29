//
//  KanYing.swift
//  UUVideo
//
//  Created by Galaxy on 2023/8/17.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji
class KanYing: WebsiteBaseModel {
    required override init() {
        super.init()
        webUrlStr = "https://www.kanying.tv/"
        websiteName = "看影"
        valueArr = ["1", "2", "3", "4"]
    }
    override func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [1, 2, 3, 4]
        let titleArr = [ "电影", "电视剧","综艺", "动漫"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div[1]/div[2]/div[\(item)]/div/div/ul/li/div/a/@title"
            let urlXpath = "/html/body/div[1]/div[2]/div[\(item)]/div/div/ul/li/div/a/@href"
            let imgXpath = "/html/body/div[1]/div[2]/div[\(item)]/div/div/ul/li/div/a/@data-original"
            let updateXpath = "/html/body/div[1]/div[2]/div[\(item)]/div/div/ul/li/div/a/span[3]"
            let titleNodeArr = jiDoc?.xPath(titleXpath)
            let urlNodeArr = jiDoc?.xPath(urlXpath)
            let imgNodeArr = jiDoc?.xPath(imgXpath)
            let updateNodeArr = jiDoc?.xPath(updateXpath)
            listModel.title = titleArr[index]
            listModel.more = true
            listModel.list = []
            for (i, _) in titleNodeArr!.enumerated() {
                var videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content!
                videoModel.webType = websiteType.kanying.rawValue
                let detailUrl: String = urlNodeArr![i].content!
                videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
                let picUrl: String = imgNodeArr![i].content!
                videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
                videoModel.num = updateNodeArr![i].content!
                videoModel.type = 3
                listModel.list.append(videoModel)
            }
            resultArr.append(listModel)
        }
        return resultArr
    }
    override func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        var videoType = valueArr[videoTypeIndex]
        if !category.videoCategory.isEmpty {
            videoType = category.videoCategory
        }
        let urlStr = webUrlStr + "so/\(videoType)/\(category.area)-------\(pageNum)---\(category.year)/"
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        let titleXpath = "/html/body/div[1]/div/div[2]/div/div/ul[2]/li/div/a/@title"
        let urlXpath = "/html/body/div[1]/div/div[2]/div/div/ul[2]/li/div/a/@href"
        let imgXpath = "/html/body/div[1]/div/div[2]/div/div/ul[2]/li/div/a/@data-original"
        let updateXpath = "/html/body/div[1]/div/div[2]/div/div/ul[2]/li/div/a/span[3]"
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
            videoModel.webType = websiteType.kanying.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
    override func getVideoCategory(videoTypeIndex: Int) -> [CategoryListModel] {
        let videoType = valueArr[videoTypeIndex]
        let urlStr = webUrlStr + "so/\(videoType)/----------/"
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            return []
        } else {
            var listArr: [CategoryListModel] = []
            let titleArr = ["类型", "地区", "年代"]
            let nodeValue = [1, 2, 3]
            // 地区，剧情，年代
            for (index, item) in nodeValue.enumerated() {
                let dataNodeArr = jiDoc?.xPath("/html/body/div[1]/div/div[1]/div/div[3]/div/ul[\(item)]/li/a/@href")
                let titleNodeArr = jiDoc?.xPath("/html/body/div[1]/div/div[1]/div/div[3]/div/ul[\(item)]/li[position()>1]/a")
                let listModel = CategoryListModel.init()
                listModel.name = titleArr[index]
                listModel.list = []
                for (index1, item1) in dataNodeArr!.enumerated() {
                    let categoryModel = CategoryModel.init()
                    let titleNode = titleNodeArr![index1]
                    categoryModel.name = titleNode.content!
                    var urlStr = item1.content!
                    urlStr = urlStr.replacingOccurrences(of: "-", with: "")
                    let strArr = urlStr.split(separator: "/")
                    if index == 0 {
                        categoryModel.value = String(strArr[1])
                    }else{
                        if index1 == 0 {
                            categoryModel.value = ""
                        }else{
                            categoryModel.value = String(strArr[2])
                        }
                    }
                    categoryModel.ischoose = index1 == 0
                    listModel.list.append(categoryModel)
                }
                listArr.append(listModel)
            }
            return listArr
        }
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
        // 获取线路
        let circuitNameXpath = "/html/body/div[1]/div/div[1]/div[2]/div/div[1]/div/ul/li/a"
        let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
        var circuitArr:[CircuitModel] = []
        if circuitNodeArr!.count > 0 {
            for (i,item) in circuitNodeArr!.enumerated() {
                let model = CircuitModel.init()
                model.name = item.content!
                let serialPathXpath = "/html/body/div[1]/div/div[1]/div[2]/div/div[2]/div[\(i+1)]/ul/li/a/@href"
                let serialNameXpath = "/html/body/div[1]/div/div[1]/div[2]/div/div[2]/div[\(i+1)]/ul/li/a"
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
        let titleXPath = "//*[@id=\"type\"]/li/div/a/@title"
        let urlXPath = "//*[@id=\"type\"]/li/div/a/@href"
        let imgXPath = "//*[@id=\"type\"]/li/div/a/@data-original"
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
                model.webType = websiteType.kanying.rawValue
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
            let jsXpath = "//*[@id=\"player-left\"]/div/div[2]/div/script[1]/text()"
            let jxNodeArr = jiDoc?.xPath(jsXpath)
            if jxNodeArr!.count>0{
                var jsItem = jxNodeArr![0].content!
                jsItem = jsItem.replacingOccurrences(of: "var player_aaaa=", with: "")
                let jsonData = jsItem.data(using: .utf8)!
                let js = try! JSONSerialization.jsonObject(with: jsonData)
                if let dic:Dictionary<String,Any> = js as? Dictionary<String, Any> {
                    videoModel.videoUrl = dic["url"] as! String
                }
            }else{
                return (result: true, model: videoModel)
            }
            // 获取剧集
            let circuitNameXpath = "//*[@id=\"player-left\"]/div/div[4]/div/div[1]/div/ul/li/a"
            let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
            var circuitArr:[CircuitModel] = []
            if circuitNodeArr!.count > 0 {
                for (i,item) in circuitNodeArr!.enumerated() {
                    let model = CircuitModel.init()
                    model.name = item.content!
                    let serialTitleNodeArr = jiDoc?.xPath("//*[@id=\"player-left\"]/div/div[4]/div/div[2]/div[\(i+1)]/ul/li/a")
                    let serialUrlNodeArr = jiDoc?.xPath("//*[@id=\"player-left\"]/div/div[4]/div/div[2]/div[\(i+1)]/ul/li/a/@href")
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
            let recommendTitleXpath = "//*[@id=\"type\"]/li/div/a/@title"
            let recommendUrlXpath = "//*[@id=\"type\"]/li/div/a/@href"
            let recommendImgXpath = "//*[@id=\"type\"]/li/div/a/@data-original"
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
                    model.webType = websiteType.kanying.rawValue
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }
    override func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        let urlStr = webUrlStr + "search/\(keyword)----------\(pageNum)---/"
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
        let titleXpath = "//*[@id=\"searchList\"]/li/div[1]/a/@title"
        let detailXpath = "//*[@id=\"searchList\"]/li/div[1]/a/@href"
        let imgXpath = "//*[@id=\"searchList\"]/li/div[1]/a/@data-original"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        let titleCount = titleNodeArr?.count
        if detailNodeArr?.count == titleCount && imgNodeArr?.count == titleCount {
            for (index, _) in titleNodeArr!.enumerated() {
                var videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![index].content!
                videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
                videoModel.picUrl = Tool.checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
                videoModel.type = 3
                videoModel.webType = websiteType.kanying.rawValue
                listModel.list.append(videoModel)
            }
        }
        return [listModel]
    }
}
