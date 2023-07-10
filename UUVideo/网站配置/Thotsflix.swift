//
//  Thotsflix.swift
//  UUVideo
//
//  Created by Galaxy on 2023/7/10.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji
class Thotsflix: WebsiteBaseModel,WebsiteProtocol {
    override init() {
        super.init()
        websiteName = "Thotsflix"
        webUrlStr = "https://thotsflix.com/"
    }
    
    func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let htmlStr = String.init(data: (jiDoc?.data!)! as Data, encoding: .utf8)
        print(htmlStr)
        var resultArr: [ListModel] = []
        let listModel = ListModel.init()
        let titleXpath = "//*[@id=\"preview_image\"]/@title"
        let urlXpath = "//*[@id=\"preview_image\"]/@href"
        let imgXpath = "//*[@id=\"preview_image\"]/img/@data-original | //*[@id=\"preview_image\"]/div/@data-thumbs"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let urlNodeArr = jiDoc?.xPath(urlXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        listModel.title = "默认"
        listModel.more = true
        listModel.list = []
        for (i, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![i].content!
            videoModel.webType = websiteType.thotsflix.rawValue
            let detailUrl: String = urlNodeArr![i].content!
            if detailUrl.contains("http") {
                videoModel.detailUrl = detailUrl
            } else {
                videoModel.detailUrl = webUrlStr + detailUrl
            }
            let picUrl: String = imgNodeArr![i].content!
            //                print(picUrl)
            if picUrl.contains("http") {
                videoModel.picUrl = picUrl
            } else {
                videoModel.picUrl = webUrlStr + picUrl
            }
            videoModel.num = "默认"
            videoModel.type = 3
            listModel.list.append(videoModel)
        }
        resultArr.append(listModel)
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
        let titleXpath = "//*[@id=\"preview_image\"]/@title"
        let urlXpath = "//*[@id=\"preview_image\"]/@href"
        let imgXpath = "//*[@id=\"preview_image\"]/img/@data-original | //*[@id=\"preview_image\"]/div/@data-thumbs"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let urlNodeArr = jiDoc?.xPath(urlXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (i, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![i].content!
            videoModel.num = "默认"
            let detailUrl: String = urlNodeArr![i].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            let picUrl: String = imgNodeArr![i].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.thotsflix.rawValue
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
        videoModel.picUrl = ""
        //        剧集
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
        let titleXPath = "//*[@id=\"preview_image\"]/@title"
        let urlXPath = "//*[@id=\"preview_image\"]/@href"
        let imgXPath = "//*[@id=\"preview_image\"]/img/@data-original | //*[@id=\"preview_image\"]/div/@data-thumbs"
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
                model.webType = websiteType.thotsflix.rawValue
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
            let playerXpath = "//*[@id=\"fp-video-0\"]/source[1]/@src"
            let playerNodeArr = jiDoc?.xPath(playerXpath)
            if playerNodeArr!.count>0 {
                videoModel.videoUrl = playerNodeArr![0].content!
            }else{
                return (result: true, model: videoModel)
            }
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
            
            // 获取推荐视频
            let recommendTitleXpath = "//*[@id=\"preview_image\"]/@title"
            let recommendUrlXpath = "//*[@id=\"preview_image\"]/@href"
            let recommendImgXpath = "//*[@id=\"preview_image\"]/img/@data-original | //*[@id=\"preview_image\"]/div/@data-thumbs"
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
                    model.webType = websiteType.thotsflix.rawValue
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
        let titleXpath = "//*[@id=\"preview_image\"]/@title"
        let detailXpath = "//*[@id=\"preview_image\"]/@href"
        let imgXpath = "//*[@id=\"preview_image\"]/img/@data-original | //*[@id=\"preview_image\"]/div/@data-thumbs"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![index].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.picUrl = Tool.checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.thotsflix.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
