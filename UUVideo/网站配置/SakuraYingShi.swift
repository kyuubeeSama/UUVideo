//
//  SakuraYingShi.swift
//  UUVideo
//
//  Created by Galaxy on 2023/2/2.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji
class SakuraYingShi: WebsiteBaseModel,WebsiteProtocol {
    override init() {
        super.init()
        websiteName = "樱花影视"
        webUrlStr = "https://www.yhvod.org/"
    }
    
    func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [6, 7, 8, 9]
        let titleArr = ["电视剧", "电影", "动漫", "综艺"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div[\(item)]/div[2]/div[1]/ul/li/h2/a"
            let urlXpath = "/html/body/div[\(item)]/div[2]/div[1]/ul/li/h2/a/@href"
            let imgXpath = "/html/body/div[\(item)]/div[2]/div[1]/ul/li/p/a/img/@src"
            let updateXpath = "/html/body/div[\(item)]/div[2]/div[1]/ul/li/p/a/span"
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
                videoModel.webType = websiteType.SakuraYingShi.rawValue
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
        let titleXpath = "/html/body/div[1]/ul/li/h2/a"
        let urlXpath = "/html/body/div[1]/ul/li/h2/a/@href"
        let imgXpath = "/html/body/div[1]/ul/li/p/a/img/@src"
        let updateXpath = "/html/body/div[1]/ul/li/p/a/span"
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
            videoModel.webType = websiteType.SakuraYingShi.rawValue
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
            let titleArr = ["地区", "年代", "类型"]
            let urlStr = "https://www.yhvod.org/dydysf/yh_js/labs_s.js"
            let data = NSData.init(contentsOf: URL.init(string: urlStr)!)
            let htmlStr = String.init(data: data! as Data, encoding: .utf8)
            var strArr:[Substring] = (htmlStr?.split(separator: ";"))!
            strArr.removeFirst()
            strArr.removeLast()
            for (index,item) in strArr.enumerated() {
                let listModel = CategoryListModel.init()
                listModel.name = titleArr[index]
                listModel.list = []
                let itemArr = item.split(separator: "=")
                if itemArr.count > 1{
                    var string = String(itemArr[1])
                    string = string.replacingOccurrences(of: "[", with: "")
                    string = string.replacingOccurrences(of: "]", with: "")
                    string = string.replacingOccurrences(of: "\"", with: "")
                    var strArr:[Substring] = string.split(separator: ",")
                    strArr.removeFirst()
                    strArr.removeFirst()
                    for (i,item1) in strArr.enumerated() {
                        let item1Str = String(item1)
                        let categoryModel = CategoryModel.init()
                        categoryModel.name = item1Str
                        if i == 0 {
                            categoryModel.ischoose = true
                        }else{
                            categoryModel.ischoose = false
                            categoryModel.value = item1Str
                        }
                        listModel.list.append(categoryModel)
                    }
                    listArr.append(listModel)
                }
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
        let videoPicXpath = "/html/body/div[1]/div[1]/div[1]/div/div[1]/a/img/@src"
        let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
        if videoPicNodeArr!.count > 0 {
            let picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
        }
        //        剧集
        // 获取线路
        let circuitNameXpath = "/html/body/div[1]/ul[1]/li/a"
        let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
        var circuitArr:[CircuitModel] = []
        if circuitNodeArr!.count > 0 {
            for item in 0...circuitNodeArr!.count-1 {
                let model = CircuitModel.init()
                model.name = circuitNodeArr![item].content!
                let strArr = ["\r","\n","\t"]
                for str in strArr {
                    model.name = model.name.replacingOccurrences(of: str, with: "")
                }
                let serialPathXpath = "/html/body/div[1]/div[3]/ul[\(item+1)]/li/a/@href"
                let serialNameXpath = "/html/body/div[1]/div[3]/ul[\(item+1)]/li/a"
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
        let titleXPath = "//*[@class=\"list-unstyled vod-item-img ff-img-215\"]/li/h2/a"
        let urlXPath = "//*[@class=\"list-unstyled vod-item-img ff-img-215\"]/li/h2/a/@href"
        let imgXPath = "//*[@class=\"list-unstyled vod-item-img ff-img-215\"]/li/p/a/img/@src"
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
                model.webType = websiteType.SakuraYingShi.rawValue
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
            let iframeStr = "//*[@id=\"re-playframe\"]/iframe/@src"
            let iframeNodeArr = jiDoc?.xPath(iframeStr)
            if iframeNodeArr!.count>0{
                var iframeItem = iframeNodeArr![0].content!
                let dic = Tool.getKeyValueFromUrl(urlStr: iframeItem)
                videoModel.videoUrl = dic["url"]!
            }else{
                return (result: true, model: videoModel)
            }
            // 获取线路
            let circuitNameXpath = "/html/body/div[1]/ul[1]/li/a"
            let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
            var circuitArr:[CircuitModel] = []
            if circuitNodeArr!.count > 0 {
                for (i,item) in circuitNodeArr!.enumerated() {
                    let model = CircuitModel.init()
                    model.name = item.content!
                    let strArr = ["\r","\n","\t"]
                    for str in strArr {
                        model.name = model.name.replacingOccurrences(of: str, with: "")
                    }
                    let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[5]/ul[\(i+1)]/li/a")
                    let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[1]/div[5]/ul[\(i+1)]/li/a/@href")
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
            let recommendTitleXpath = "//*[@class=\"list-unstyled vod-item-img ff-img-215\"]/li/h2/a"
            let recommendUrlXpath = "//*[@class=\"list-unstyled vod-item-img ff-img-215\"]/li/h2/a/@href"
            let recommendImgXpath = "//*[@class=\"list-unstyled vod-item-img ff-img-215\"]/li/p/a/img/@src"
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
                    model.webType = websiteType.SakuraYingShi.rawValue
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
        let titleXpath = "/html/body/div[1]/ul/li/h2/a"
        let detailXpath = "/html/body/div[1]/ul/li/h2/a/@href"
        let imgXpath = "/html/body/div[1]/ul/li/p/a/img"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![index].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.picUrl = Tool.checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.mianfei.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
    
}
