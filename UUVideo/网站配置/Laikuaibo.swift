//
//  Laikuaibo.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/9.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji

class Laikuaibo: WebsiteBaseModel, WebsiteProtocol {
    required override init() {
        super.init()
        webUrlStr = "https://www.laikuaibo.top/"
        websiteName = "来快播"
        valueArr = ["2","1", "4", "3", "19"]
    }
    func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [3, 5, 7, 9, 0]
        let titleArr = ["电影", "剧集", "综艺", "动漫", "伦理"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div[\(item)]/div[2]/div[1]/ul/li/h2/a"
            let urlXpath = "/html/body/div[\(item)]/div[2]/div[1]/ul/li/p/a/@href"
            let imgXpath = "/html/body/div[\(item)]/div[2]/div[1]/ul/li/p/a/img/@data-original"
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
                videoModel.webType = websiteType.laikuaibo.rawValue
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
    func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        let videoType = valueArr[videoTypeIndex]
        let urlStr = webUrlStr + "list-select-id-\(videoType)-area--order-addtime-p-\(pageNum).html"
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        let titleXpath = "/html/body/div[1]/ul/li/h2/a"
        let urlXpath = "/html/body/div[1]/ul/li/p/a/@href"
        let imgXpath = "/html/body/div[1]/ul/li/p/a/img/@data-original"
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
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: baseUrl)
            let picUrl: String = imgNodeArr![i].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.laikuaibo.rawValue
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
        // 获取tag
        let tagIndexArr = [1, 2, 4, 6]
        for item in tagIndexArr {
            let tagNodeArr = jiDoc?.xPath("/html/body/div[1]/div[1]/div[1]/div/div[2]/dl/dd[\(item)]/a")
            var tagArr: [String] = []
            for tagNode in tagNodeArr! {
                let tag = tagNode.content
                tagArr.append(tag!)
            }
            videoModel.tagArr.append(tagArr)
        }
        //        视频封面
        let videoPicXpath = "/html/body/div[1]/div[1]/div[1]/div/div[1]/a/img/@data-original"
        let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
        //        视频标题
        let videoTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[1]/div[1]/div/div[2]/h4/a")
        videoModel.name = videoTitleNodeArr![0].content!
        if videoPicNodeArr!.count > 0 {
            let picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
        }
        //        剧集
        let serialPathXpath = "/html/body/div[1]/div[3]/ul/li/a/@href"
        let serialNameXpath = "/html/body/div[1]/div[3]/ul/li/a"
        let serialTitleNodeArr = jiDoc?.xPath(serialNameXpath)
        let serialUrlNodeArr = jiDoc?.xPath(serialPathXpath)
        let circuitModel = CircuitModel.init()
        if serialUrlNodeArr!.count > 0 {
            for (index, item) in serialUrlNodeArr!.enumerated() {
                let serial = SerialModel.init()
                serial.name = serialTitleNodeArr![index].content!
                let serialDetailUrl: String = item.content!
                serial.detailUrl = Tool.checkUrl(urlStr: serialDetailUrl, domainUrlStr: baseUrl)
                circuitModel.serialArr.append(serial)
            }
        }
        videoModel.circuitArr = [circuitModel]
//        videoModel.serialNum = videoModel.serialArr.count
        // 推荐视频
        let titleXPath = "/html/body/div[1]/ul[2]/li/h2/a"
        let urlXPath = "/html/body/div[1]/ul[2]/li/h2/a/@href"
        let imgXPath = "/html/body/div[1]/ul[2]/li/p/a/img/@data-original"
        let updateXpath = "/html/body/div[1]/ul[2]/li/p/a/span"
        let titleNodeArr = jiDoc?.xPath(titleXPath)
        let urlNodeArr = jiDoc?.xPath(urlXPath)
        let imgNodeArr = jiDoc?.xPath(imgXPath)
        let updateNodeArr = jiDoc?.xPath(updateXpath)
        if titleNodeArr!.count > 0 {
            for (index, titleNode) in titleNodeArr!.enumerated() {
                var model = VideoModel.init()
                model.name = titleNode.content!
                let imgPic: String = imgNodeArr![index].content!
                model.picUrl = Tool.checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                let recommandUrlStr: String = urlNodeArr![index].content!
                model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                model.webType = websiteType.laikuaibo.rawValue
                model.num = updateNodeArr![index].content!
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
                let urlStr: String = "https://www.bfq168.com/m3u8.php?url=" + (dic!["url"] as! String)
                videoModel.videoUrl = urlStr
                //获取剧集信息
                //        标题
                let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[6]/ul/li/a")
                //        详情
                let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[1]/div[6]/ul/li/a/@href")
                let circuitModel = CircuitModel.init()
                for (index, _) in serialTitleNodeArr!.enumerated() {
                    let serialModel = SerialModel.init()
                    serialModel.name = serialTitleNodeArr![index].content!
                    serialModel.detailUrl = Tool.checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
                    circuitModel.serialArr.append(serialModel)
                }
                videoModel.circuitArr = [circuitModel]
            }
            let recommendTitleXpath = "/html/body/div[1]/ul[1]/li/h2/a"
            let recommendUrlXpath = "/html/body/div[1]/ul[1]/li/p/a/@href"
            let recommendImgXpath = "/html/body/div[1]/ul[1]/li/p/a/img/@data-original"
            let recommendUpdateXpath = "/html/body/div[1]/ul[1]/li/p/a/span"
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
                    model.webType = websiteType.laikuaibo.rawValue
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }
    func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        let urlStr = webUrlStr + "vod-search-wd-" + keyword + "-p-\(pageNum).html"
        let listModel = ListModel.init()
        listModel.title = "搜索关键字:" + keyword
        listModel.more = false
        listModel.list = []
        let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        } else {
            let titleXpath = "/html/body/div[1]/ul/li/h2/a"
            let detailXpath = "/html/body/div[1]/ul/li/h2/a/@href"
            let imgXpath = "/html/body/div[1]/ul/li/p/a/img/@data-original"
            let updateXpath = "/html/body/div[1]/ul/li/p/a/span"
            let titleNodeArr = jiDoc?.xPath(titleXpath)
            let detailNodeArr = jiDoc?.xPath(detailXpath)
            let updateNodeArr = jiDoc?.xPath(updateXpath)
            let imgNodeArr = jiDoc?.xPath(imgXpath)
            for (index, _) in titleNodeArr!.enumerated() {
                var videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![index].content!
                videoModel.num = updateNodeArr![index].content!
                videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
                videoModel.picUrl = Tool.checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
                videoModel.type = 3
                videoModel.webType = websiteType.laikuaibo.rawValue
                listModel.list.append(videoModel)
            }
            return [listModel]
        }
    }
}
