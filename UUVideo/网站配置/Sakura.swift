//
//  Sakura.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/9.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji

class Sakura: WebsiteBaseModel, WebsiteProtocol {
    required override init() {
        super.init()
        webUrlStr = "http://www.yinghuacd.com/"
        websiteName = "樱花动漫"
    }
    func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [4, 6, 8, 10]
        let titleArr = ["日本动漫", "国产动漫", "欧美动漫", "动漫电影"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div[8]/div[1]/div[\(item)]/ul[1]/li/p[1]/a"
            let urlXpath = "/html/body/div[8]/div[1]/div[\(item)]/ul[1]/li/a/@href"
            let imgXpath = "/html/body/div[8]/div[1]/div[\(item)]/ul[1]/li/a/img/@src"
            let titleNodeArr = jiDoc?.xPath(titleXpath)
            let urlNodeArr = jiDoc?.xPath(urlXpath)
            let imgNodeArr = jiDoc?.xPath(imgXpath)
            listModel.title = titleArr[index]
            listModel.more = true
            listModel.list = []
            for (i, _) in titleNodeArr!.enumerated() {
                var videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content!
                videoModel.webType = websiteType.sakura.rawValue
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
        let titleXpath = "/html/body/div[4]/div[3]/div[1]/ul/li/h2/a/@title"
        let urlXpath = "/html/body/div[4]/div[3]/div[1]/ul/li/h2/a/@href"
        let imgXpath = "/html/body/div[4]/div[3]/div[1]/ul/li/a/img/@src"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let urlNodeArr = jiDoc?.xPath(urlXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (i, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![i].content!
            let detailUrl: String = urlNodeArr![i].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            let picUrl: String = imgNodeArr![i].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.sakura.rawValue
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
            // 地区
            let areaNodeArr = jiDoc?.xPath("/html/body/div[1]/dl/dd[2]/div/div/a")
            let areaChooseNodeArr = jiDoc?.xPath("/html/body/div[1]/dl/dd[2]/div/div/a[@class='btn-success']")
            let areaListModel = CategoryListModel.init()
            areaListModel.name = "地区"
            areaListModel.list = []
            // 将具体的分类编入数组
            for (index, _) in areaNodeArr!.enumerated() {
                let categoryModel = CategoryModel.init()
                let name = areaNodeArr![index].content
                categoryModel.name = name!
                // 获取当前选中的分类
                for chooseNode in areaChooseNodeArr! {
                    if name == chooseNode.content {
                        categoryModel.ischoose = true
                    }
                }
                areaListModel.list.append(categoryModel)
            }
            listArr.append(areaListModel)
            // 排序
            let orderNodeArr = jiDoc?.xPath("/html/body/div[1]/div[3]/div/a")
            let orderChooseNodeArr = jiDoc?.xPath("/html/body/div[1]/div[3]/div/a[@class='btn-success']")
            let orderListModel = CategoryListModel.init()
            orderListModel.name = "排序"
            orderListModel.list = []
            // 将具体的分类编入数组
            for (index, _) in orderNodeArr!.enumerated() {
                let categoryModel = CategoryModel.init()
                let name = orderNodeArr![index].content
                categoryModel.name = name!
                // 获取当前选中的分类
                for chooseNode in orderChooseNodeArr! {
                    if name == chooseNode.content {
                        categoryModel.ischoose = true
                    }
                }
                orderListModel.list.append(categoryModel)
            }
            listArr.append(orderListModel)
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
        let videoPicXpath = "/html/body/div[2]/div[2]/div[1]/img/@src"
        let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
        if videoPicNodeArr!.count > 0 {
            let picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
        }
        //        剧集
        let serialPathXpath = "//*[@id=\"main0\"]/div/ul/li/a/@href"
        let serialNameXpath = "//*[@id=\"main0\"]/div/ul/li/a"
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
        //        推荐视频
        let titleXPath = "/html/body/div[2]/div[3]/div[2]/ul/li/a/img/@alt"
        let urlXPath = "/html/body/div[2]/div[3]/div[2]/ul/li/h2/a/@href"
        let imgXPath = "/html/body/div[2]/div[3]/div[2]/ul/li/a/img/@src"
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
                model.webType = websiteType.sakura.rawValue
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
            var recommendTitleXpath = ""
            var recommendUrlXpath = ""
            var recommendImgXpath = ""
            let vidXpath = "//*[@id=\"playbox\"]/@data-vid"
            let gfXpath = "//*[@id=\"playbox\"]/@data-gf"
            let vidNodeArr = jiDoc?.xPath(vidXpath)
            let gfNodeArr = jiDoc?.xPath(gfXpath)
            var vid = vidNodeArr![0].content
            let gf = gfNodeArr![0].content
            if gf == "1" {
            } else {
                vid = vid?.replacingOccurrences(of: "$mp4", with: "")
                videoModel.videoUrl = vid!
            }
            // 获取剧集信息
            //        标题
            let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[7]/div[2]/ul/li/a")
            //        详情
            let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[7]/div[2]/ul/li/a/@href")
            let circuitModel = CircuitModel.init()
            for (index, _) in serialTitleNodeArr!.enumerated() {
                let serialModel = SerialModel.init()
                serialModel.name = serialTitleNodeArr![index].content!
                serialModel.detailUrl = Tool.checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
                circuitModel.serialArr.append(serialModel)
            }
            videoModel.circuitArr = [circuitModel]
            recommendTitleXpath = "/html/body/div[9]/div[2]/ul/li/a/img/@alt"
            recommendUrlXpath = "/html/body/div[9]/div[2]/ul/li/p[1]/a/@href"
            recommendImgXpath = "/html/body/div[9]/div[2]/ul/li/a/img/@src"
            // 获取推荐视频
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
                    model.webType = websiteType.sakura.rawValue
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
        let titleXpath = "/html/body/div[4]/div[2]/div/ul/li/h2/a/@title"
        let detailXpath = "/html/body/div[4]/div[2]/div/ul/li/h2/a/@href"
        let imgXpath = "/html/body/div[4]/div[2]/div/ul/li/a/img/@src"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![index].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.picUrl = Tool.checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.sakura.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
