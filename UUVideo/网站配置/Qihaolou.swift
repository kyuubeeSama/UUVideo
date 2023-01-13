//
//  Qihaolou.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/13.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji

class Qihaolou: WebsiteBaseModel, WebsiteProtocol {
    override init() {
        super.init()
        webUrlStr = "https://qhlou.com/"
        websiteName = "七号楼"
    }
    func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [2, 3, 4, 5]
        let titleArr = ["电影", "电视剧", "综艺", "动漫"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div[1]/div/div[\(item)]/div/div[1]/div[2]/ul/li/div/a/@title"
            let urlXpath = "/html/body/div[1]/div/div[\(item)]/div/div[1]/div[2]/ul/li/div/a/@href"
            let imgXpath = "/html/body/div[1]/div/div[\(item)]/div/div[1]/div[2]/ul/li/div/a/@data-original"
            let updateXpath = "/html/body/div[1]/div/div[\(item)]/div/div[1]/div[2]/ul/li/div/a/span[2]"
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
                videoModel.webType = websiteType.qihaolou.rawValue
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
        let titleXpath = "/html/body/div/div[1]/div/div/div/div[3]/ul/li/div/a/@title"
        let urlXpath = "/html/body/div/div[1]/div/div/div/div[3]/ul/li/div/a/@href"
        let imgXpath = "/html/body/div/div[1]/div/div/div/div[3]/ul/li/div/a/@data-original"
        let updateXpath = "/html/body/div/div[1]/div/div/div/div[3]/ul/li/div/a/span[2]"
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
            videoModel.webType = websiteType.qihaolou.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
    func getVideoCategory(urlStr: String) -> [CategoryListModel] {
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            return []
        } else {
            var listArr: [CategoryListModel] = []
            let titleArr = ["按类型", "按地区", "按年份"]
            for item in 1...3 {
                let titleXpath = "/html/body/div/div[1]/div/div/div/ul[\(item)]/li/a"
                let titleNodeArr = jiDoc?.xPath(titleXpath)
                let listModel = CategoryListModel.init()
                listModel.name = titleArr[item - 1]
                listModel.list = []
                for item1 in titleNodeArr! {
                    let categoryModel = CategoryModel.init()
                    let name = item1.content!
                    categoryModel.name = name
                    if item == 1 {
                        categoryModel.value = name.transformToPinYin(yinbiao: false)
                    } else {
                        categoryModel.value = name
                    }
                    if name == "全部" {
                        categoryModel.value = ""
                        categoryModel.ischoose = true
                    }
                    listModel.list.append(categoryModel)
                }
                listArr.append(listModel)
            }
            return listArr
        }
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
        let videoPicXpath = "/html/body/div[1]/div/div[1]/div/div/div[1]/div/div[1]/a/img/@data-original"
        let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
        if videoPicNodeArr!.count > 0 {
            let picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
        }
        //        剧集
        // 获取线路
        let circuitNameXpath = "/html/body/div[1]/div/div/div/div[1]/div/h3"
        let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
        var circuitArr: [CircuitModel] = []
        if circuitNodeArr!.count > 0 {
            for item in 0...circuitNodeArr!.count - 2 {
                let model = CircuitModel.init()
                model.name = circuitNodeArr![item].content!
                let serialPathXpath = "/html/body/div[1]/div/div[\(item + 2)]/div/div[2]/ul/li/a/@href"
                let serialNameXpath = "/html/body/div[1]/div/div[\(item + 2)]/div/div[2]/ul/li/a"
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
        let titleXPath = "//*[@class=\"stui-vodlist__bd clearfix\"]/li/div/a/@title"
        let urlXPath = "//*[@class=\"stui-vodlist__bd clearfix\"]/li/div/a/@href"
        let imgXPath = "//*[@class=\"stui-vodlist__bd clearfix\"]/li/div/a/@data-original"
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
                model.webType = websiteType.qihaolou.rawValue
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
            let jsXpath = "/html/body/div[1]/div/div[1]/div/div/div/div[1]/script[1]/text()"
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
            let circuitNameXpath = "/html/body/div[1]/div/div/div/div[1]/div/h3"
            let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
            var circuitArr: [CircuitModel] = []
            if circuitNodeArr!.count > 0 {
                for (i, item) in circuitNodeArr!.enumerated() {
                    if i < circuitNodeArr!.count - 2 {
                        let model = CircuitModel.init()
                        model.name = item.content!
                        let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div/div[\(i + 2)]/div/div[2]/ul/li/a")
                        let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[1]/div/div[\(i + 2)]/div/div[2]/ul/li/a/@href")
                        for (index, _) in serialTitleNodeArr!.enumerated() {
                            let serialModel = SerialModel.init()
                            serialModel.name = serialTitleNodeArr![index].content!
                            serialModel.detailUrl = Tool.checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
                            model.serialArr.append(serialModel)
                        }
                        circuitArr.append(model)
                    }
                }
            }
            videoModel.circuitArr = circuitArr
            // 获取推荐视频
            let recommendTitleXpath = "//*[@class=\"stui-vodlist__bd clearfix\"]/li/div/a/@title"
            let recommendUrlXpath = "//*[@class=\"stui-vodlist__bd clearfix\"]/li/div/a/@href"
            let recommendImgXpath = "//*[@class=\"stui-vodlist__bd clearfix\"]/li/div/a/@data-original"
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
                    model.webType = websiteType.qihaolou.rawValue
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }
    func getSearchData(urlStr: String, keyword: String) -> [ListModel] {
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
        let titleXpath = "/html/body/div[1]/div/div[1]/div/div/div[2]/ul/li/div[1]/a/@title"
        let detailXpath = "/html/body/div[1]/div/div[1]/div/div/div[2]/ul/li/div[1]/a/@href"
        let imgXpath = "/html/body/div[1]/div/div[1]/div/div/div[2]/ul/li/div[1]/a/@data-original"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![index].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.picUrl = Tool.checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.qihaolou.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
