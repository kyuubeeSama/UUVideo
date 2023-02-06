//
//  Yklunli.swift
//  UUVideo
//
//  Created by Galaxy on 2023/2/6.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji
class Yklunli: WebsiteBaseModel,WebsiteProtocol {
    override init() {
        super.init()
        websiteName = "要看伦理"
        webUrlStr = "https://www.yklunli.com/"
    }
    
    func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [7, 9, 11, 13]
        let titleArr = ["韩国伦理", "日本伦理", "欧美伦理", "香港伦理"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div[\(item)]/ul/li/h2/a"
            let urlXpath = "/html/body/div[\(item)]/ul/li/h2/a/@href"
            let imgXpath = "/html/body/div[\(item)]/ul/li/p/a/img/@data-original"
            let updateXpath = "/html/body/div[\(item)]/ul/li/p/a/span"
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
                videoModel.webType = websiteType.Yklunli.rawValue
                let detailUrl: String = urlNodeArr![i].content!
                if detailUrl.contains("http") {
                    videoModel.detailUrl = detailUrl
                } else {
                    videoModel.detailUrl = webUrlStr + detailUrl
                }
                var picUrl: String = imgNodeArr![i].content!
                if picUrl.contains("http") {
                    videoModel.picUrl = picUrl
                } else {
                    picUrl.removeFirst()
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
        let titleXpath = "/html/body/div[6]/ul/li/h2/a"
        let urlXpath = "/html/body/div[6]/ul/li/h2/a/@href"
        let imgXpath = "/html/body/div[6]/ul/li/p/a/img/@data-original"
        let updateXpath = "/html/body/div[6]/ul/li/p/a/span"
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
            var picUrl: String = imgNodeArr![i].content!
            if picUrl.contains("http") {
                videoModel.picUrl = picUrl
            } else {
                picUrl.removeFirst()
                videoModel.picUrl = webUrlStr + picUrl
            }
//            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.Yklunli.rawValue
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
        let videoPicXpath = "/html/body/div[6]/div[1]/div[1]/a/img/@data-original"
        let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
        if videoPicNodeArr!.count > 0 {
            var picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
        }
        //        剧集
        // 获取线路
//        let circuitNameXpath = "/html/body/div[1]/ul[1]/li/a"
//        let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
        var circuitArr:[CircuitModel] = []
//        if circuitNodeArr!.count > 0 {
//            for item in 0...circuitNodeArr!.count-1 {
                let model = CircuitModel.init()
                model.name = "默认线路"
//                let strArr = ["\r","\n","\t"]
//                for str in strArr {
//                    model.name = model.name.replacingOccurrences(of: str, with: "")
//                }
                let serialPathXpath = "/html/body/div[8]/div/div[1]/ul/li/a/@href"
                let serialNameXpath = "/html/body/div[8]/div/div[1]/ul/li/a"
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
//            }
//        }
        videoModel.circuitArr = circuitArr
        videoModel.serialNum = videoModel.serialArr.count
        //        推荐视频
        let titleXPath = "//*[@class=\"list-unstyled vod-item-img ff-img-140\"]/li/h2/a"
        let urlXPath = "//*[@class=\"list-unstyled vod-item-img ff-img-140\"]/li/h2/a/@href"
        let imgXPath = "//*[@class=\"list-unstyled vod-item-img ff-img-140\"]/li/p/a/img/@data-original"
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
                model.webType = websiteType.Yklunli.rawValue
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
            // 获取视频详情
            let playerUrlNodeArr = jiDoc?.xPath("//*[@id=\"cms_player\"]/script[1]")
            if playerUrlNodeArr!.count > 0 {
                var playerUrl = playerUrlNodeArr![0].content
                playerUrl = playerUrl?.replacingOccurrences(of: "var cms_player = ", with: "")
                playerUrl = playerUrl?.replacingOccurrences(of: ";", with: "")
                let dic = Dictionary<String, String>.init().stringValueDic(playerUrl!)
                let urlStr:String = dic!["url"] as! String
                videoModel.videoUrl = urlStr
                //获取剧集信息
                //        标题
                let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[10]/div[2]/ul/li/a")
                //        详情
                let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[10]/div[2]/ul/li/a/@href")
                let circuitModel = CircuitModel.init()
                for (index, _) in serialTitleNodeArr!.enumerated() {
                    let serialModel = SerialModel.init()
                    serialModel.name = serialTitleNodeArr![index].content!
                    serialModel.detailUrl = Tool.checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
                    circuitModel.serialArr.append(serialModel)
                }
                videoModel.circuitArr = [circuitModel]
            }
            let recommendTitleXpath = "//*[@class=\"list-unstyled vod-item-img ff-img-140\"]/li/h2/a"
            let recommendUrlXpath = "//*[@class=\"list-unstyled vod-item-img ff-img-140\"]/li/h2/a/@href"
            let recommendImgXpath = "//*[@class=\"list-unstyled vod-item-img ff-img-140\"]/li/p/a/img/@data-original"
            let recommendUpdateXpath = "//*[@class=\"list-unstyled vod-item-img ff-img-140\"]/li/p/a/span"
            // 获取推荐视频
            let recommendTitleNodeArr = jiDoc?.xPath(recommendTitleXpath)
            let recommendUrlNodeArr = jiDoc?.xPath(recommendUrlXpath)
            let recommendImgNodeArr = jiDoc?.xPath(recommendImgXpath)
            let recommendUPdateNodeArr = jiDoc?.xPath(recommendUpdateXpath)
            if recommendTitleNodeArr!.count > 0 {
                for (index, item) in recommendTitleNodeArr!.enumerated() {
                    var model = VideoModel.init()
                    model.name = item.content!
                    let imgPic: String = recommendImgNodeArr![index].content!
                    model.picUrl = Tool.checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                    let recommandUrlStr: String = recommendUrlNodeArr![index].content!
                    model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                    model.num = recommendUPdateNodeArr![index].content!
                    model.num = ""
                    model.type = 3
                    model.webType = websiteType.Yklunli.rawValue
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
        let titleXpath = "/html/body/div[6]/ul/li/h2/a"
        let detailXpath = "/html/body/div[6]/ul/li/h2/a/@href"
        let imgXpath = "/html/body/div[6]/ul/li/p/a/img/@data-original"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![index].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.picUrl = Tool.checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.Yklunli.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
