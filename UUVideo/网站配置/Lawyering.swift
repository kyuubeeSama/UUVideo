//
//  Lawyering.swift
//  UUVideo
//
//  Created by Galaxy on 2023/5/4.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji
class Lawyering: WebsiteBaseModel,WebsiteProtocol {
    override init() {
        super.init()
        websiteName = "老野人"
        webUrlStr = "http://china-lawyering.com/"
        valueArr = ["1", "2", "3", "4", "5", "6", "7", "8"]
    }
    
    func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [2, 3, 4, 5, 6, 0, 0, 0]
        let titleArr = ["中文", "欧美", "动漫", "主播","制服","人妻","美乳","伦理"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div/div/nav/div[2]/div[3]/div/div[\(item)]/div/ul/li/div/h5/a/@title"
            let urlXpath = "/html/body/div/div/nav/div[2]/div[3]/div/div[\(item)]/div/ul/li/div/h5/a/@href"
            let imgXpath = "/html/body/div/div/nav/div[2]/div[3]/div/div[\(item)]/div/ul/li/a/img/@data-original"
            let updateXpath = "/html/body/div/div/nav/div[2]/div[3]/div/div[\(item)]/div/ul/li/a/span"
            let titleNodeArr = jiDoc?.xPath(titleXpath)
            let urlNodeArr = jiDoc?.xPath(urlXpath)
            let imgNodeArr = jiDoc?.xPath(imgXpath)
            let updateNodeArr = jiDoc?.xPath(updateXpath)
            listModel.title = titleArr[index]
            listModel.more = true
            listModel.list = []
            var inc = 0
            if index == 0{
                inc = 2
            }
            for (i, _) in titleNodeArr!.enumerated() {
                var videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content!
                videoModel.webType = websiteType.lawyering.rawValue
                let detailUrl: String = urlNodeArr![i+inc].content!
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
                videoModel.num = updateNodeArr![i+inc].content!
                videoModel.type = 3
                listModel.list.append(videoModel)
            }
            resultArr.append(listModel)
        }
        return resultArr
    }
    func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        let videoType = valueArr[videoTypeIndex]
        let urlStr = webUrlStr + "index.php/vod/type/id/\(videoType)/page/\(pageNum).html"
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        let titleXpath = "/html/body/div[1]/div/nav/div[2]/div[4]/div[2]/ul/li/div/h5/a"
        let urlXpath = "/html/body/div[1]/div/nav/div[2]/div[4]/div[2]/ul/li/a/@href"
        let imgXpath = "/html/body/div[1]/div/nav/div[2]/div[4]/div[2]/ul/li/a/img/@data-original"
        let updateXpath = "/html/body/div[1]/div/nav/div[2]/div[4]/div[2]/ul/li/a/span"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let urlNodeArr = jiDoc?.xPath(urlXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        let updateNodeArr = jiDoc?.xPath(updateXpath)
        for item in 2...titleNodeArr!.count-1 {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![item].content!
            videoModel.num = updateNodeArr![item].content!
            let detailUrl: String = urlNodeArr![item].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            let picUrl: String = imgNodeArr![item-2].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.lawyering.rawValue
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
        let videoPicXpath = "/html/body/div/div/nav/div[2]/div[3]/div[2]/div[1]/a/img/@src"
        let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
        if videoPicNodeArr!.count > 0 {
            let picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
        }
        //        剧集
        // 获取线路
        let model = CircuitModel.init()
        model.name = "默认线路"
        let serialPathXpath = "/html/body/div/div/nav/div[2]/div[3]/div[2]/div[1]/a/@href"
        let serialUrlNodeArr = jiDoc?.xPath(serialPathXpath)
        if serialUrlNodeArr!.count > 0 {
            for (_, item) in serialUrlNodeArr!.enumerated() {
                let serial = SerialModel.init()
                serial.name = "播放"
                let serialDetailUrl: String = item.content!
                serial.detailUrl = Tool.checkUrl(urlStr: serialDetailUrl, domainUrlStr: baseUrl)
                model.serialArr.append(serial)
            }
        }
        videoModel.circuitArr = [model]
        videoModel.serialNum = 1
        //        推荐视频
        let titleXPath = "/html/body/div/div/nav/div[2]/div[3]/div[5]/div[2]/ul/li/div/h5/a"
        let urlXPath = "/html/body/div/div/nav/div[2]/div[3]/div[5]/div[2]/ul/li/a/@href"
        let imgXPath = "/html/body/div/div/nav/div[2]/div[3]/div[5]/div[2]/ul/li/a/img/@data-original"
        let titleNodeArr = jiDoc?.xPath(titleXPath)
        let urlNodeArr = jiDoc?.xPath(urlXPath)
        let imgNodeArr = jiDoc?.xPath(imgXPath)
        if titleNodeArr!.count > 0 {
            for index in 2...titleNodeArr!.count-1 {
                var model = VideoModel.init()
                model.name = titleNodeArr![index].content!
                let imgPic: String = imgNodeArr![index-2].content!
                model.picUrl = Tool.checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                let recommandUrlStr: String = urlNodeArr![index].content!
                model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                model.webType = websiteType.lawyering.rawValue
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
            let jsXpath = "/html/body/div[1]/div/nav/div[2]/div[4]/div[2]/div[2]/script/text()"
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
            // 获取线路
            let model = CircuitModel.init()
            model.name = "默认线路"
            let serialModel = SerialModel.init()
            model.serialArr = [serialModel]
//            let circuitNameXpath = "//*[@id=\"playlist\"]/div[2]/div[1]/div/a/@alt"
//            let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
//            var circuitArr:[CircuitModel] = []
//            if circuitNodeArr!.count > 0 {
//                for (i,item) in circuitNodeArr!.enumerated() {
//                    let model = CircuitModel.init()
//                    model.name = item.content!
//                    let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[2]/div[1]/div/div/div[3]/div/div[1]/div/div[1]/div[2]/div[\(i+2)]/div/div/ul/li/a")
//                    let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[2]/div[1]/div/div/div[3]/div/div[1]/div/div[1]/div[2]/div[\(i+2)]/div/div/ul/li/a/@href")
//                    for (index, _) in serialTitleNodeArr!.enumerated() {
//                        let serialModel = SerialModel.init()
//                        serialModel.name = serialTitleNodeArr![index].content!
//                        serialModel.detailUrl = Tool.checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
//                        model.serialArr.append(serialModel)
//                    }
//                    circuitArr.append(model)
//                }
//            }
            videoModel.circuitArr = [model]

            // 获取推荐视频
            let recommendTitleXpath = "/html/body/div[1]/div/nav/div[2]/div[5]/div[2]/ul/li/div/h5/a"
            let recommendUrlXpath = "/html/body/div[1]/div/nav/div[2]/div[5]/div[2]/ul/li/div/h5/a/@href"
            let recommendImgXpath = "/html/body/div[1]/div/nav/div[2]/div[5]/div[2]/ul/li/a/img/@data-original"
            let recommendTitleNodeArr = jiDoc?.xPath(recommendTitleXpath)
            let recommendUrlNodeArr = jiDoc?.xPath(recommendUrlXpath)
            let recommendImgNodeArr = jiDoc?.xPath(recommendImgXpath)
            if recommendTitleNodeArr!.count > 0 {
                for index in 2...recommendTitleNodeArr!.count-1 {
                    var model = VideoModel.init()
                    model.name = recommendTitleNodeArr![index].content!
                    let imgPic: String = recommendImgNodeArr![index-2].content!
                    model.picUrl = Tool.checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                    let recommandUrlStr: String = recommendUrlNodeArr![index].content!
                    model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                    model.num = ""
                    model.type = 3
                    model.webType = websiteType.lawyering.rawValue
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }
    
    func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        []
    }
}
