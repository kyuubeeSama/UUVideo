//
//  Juzhixiao.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/9.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji

class Juzhixiao: WebsiteBaseModel, WebsiteProtocol {
    required override init() {
        super.init()
        webUrlStr = "https://www.xdwdn.com/"
        websiteName = "剧知晓"
    }
    func getIndexData() -> [ListModel] {
        var jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        var htmlStr = String.init(data: (jiDoc?.data)!, encoding: .utf8)
        htmlStr = htmlStr?.replacingOccurrences(of: "</header>", with: "</div></header>")
        jiDoc = Ji(htmlString: htmlStr!)
        let divArr = [1, 2, 3, 4]
        let titleArr = ["电视剧", "电影", "综艺", "动漫"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            var divindex = 1
            if index > 1 {
                divindex = 2
            }
            let titleXpath = "/html/body/div[3]/div[\(item)]/div[2]/div[\(divindex)]/ul[1]/li/div[1]/a"
            let urlXpath = "/html/body/div[3]/div[\(item)]/div[2]/div[\(divindex)]/ul[1]/li/div[1]/a/@href"
            let imgXpath = "/html/body/div[3]/div[\(item)]/div[2]/div[\(divindex)]/ul[1]/li/a/img/@data-original"
            var spanindex = 4
            if index == 1 || index == 3 {
                spanindex = 3
            } else if index == 2 {
                spanindex = 2
            }
            let updateXpath = "/html/body/div[3]/div[\(item)]/div[2]/div[\(divindex)]/ul[1]/li/a/span[\(spanindex)]"
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
                videoModel.webType = websiteType.juzhixiao.rawValue
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
        let titleXpath = "//*[@id=\"content\"]/li/div/a"
        let urlXpath = "//*[@id=\"content\"]/li/a/@href"
        let imgXpath = "//*[@id=\"content\"]/li/a/img/@data-original"
        let updateXpath = "//*[@id=\"content\"]/li/a/span[3]"
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
            videoModel.webType = websiteType.juzhixiao.rawValue
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
            let titleArr = ["类型", "地区", "年代"]
            let nodeValue = ["mcid", "area", "year"]
            // 地区，剧情，年代
            for (index, item) in nodeValue.enumerated() {
                let dataNodeArr = jiDoc?.xPath("//*[@id=\"\(item)\"]/li[position()>1]/a/@data")
                let titleNodeArr = jiDoc?.xPath("//*[@id=\"\(item)\"]/li[position()>1]/a")
                let listModel = CategoryListModel.init()
                listModel.name = titleArr[index]
                listModel.list = []
                for (index1, item1) in dataNodeArr!.enumerated() {
                    let categoryModel = CategoryModel.init()
                    let titleNode = titleNodeArr![index1]
                    categoryModel.name = titleNode.content!
                    categoryModel.value = item1.content!
                    categoryModel.ischoose = index1 == 0
                    listModel.list.append(categoryModel)
                }
                listArr.append(listModel)
            }
            return listArr
        }
    }
    func getVideoDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
        var jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            return (result: false, model: VideoModel.init())
        }
        var htmlStr = String.init(data: (jiDoc?.data)!, encoding: .utf8)
        htmlStr = htmlStr?.replacingOccurrences(of: "</header>", with: "</div></header>")
        jiDoc = Ji(htmlString: htmlStr!)
        let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
        var videoModel = VideoModel.init()
        videoModel.detailUrl = urlStr
        videoModel.videoArr = []
        videoModel.tagArr = []
        videoModel.serialArr = []
        let videoPicXpath = "/html/body/div[2]/div/div[1]/div[1]/a/img/@src"
        let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
        if videoPicNodeArr!.count > 0 {
            let picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
        }
        //        剧集
        // 获取线路
        let circuitNameXpath = "/html/body/div[5]/div/div[1]/div[1]/ul[1]/li/a"
        let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
        var circuitArr:[CircuitModel] = []
        if circuitNodeArr!.count > 0 {
            for (i,item) in circuitNodeArr!.enumerated() {
                let model = CircuitModel.init()
                model.name = item.content!
                let serialPathXpath = "//*[@id=\"con_playlist_\(i+1)\"]/li/a/@href"
                let serialNameXpath = "//*[@id=\"con_playlist_\(i+1)\"]/li/a"
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
        let titleXPath = "/html/body/div[5]/div/div[1]/div[last()]/ul/li/a/@title"
        let urlXPath = "/html/body/div[5]/div/div[1]/div[last()]/ul/li/a/@href"
        let imgXPath = "/html/body/div[5]/div/div[1]/div[last()]/ul/li/a/img/@data-original"
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
                model.webType = websiteType.juzhixiao.rawValue
                model.num = ""
                model.type = 3
                videoModel.videoArr.append(model)
            }
        }
        return (result: true, model: videoModel)
    }
    func getVideoPlayerDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
        var jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            return (result: false, model: VideoModel.init())
        } else {
            var htmlStr = String.init(data: (jiDoc?.data)!, encoding: .utf8)
            htmlStr = htmlStr?.replacingOccurrences(of: "</header>", with: "</div></header>")
            jiDoc = Ji(htmlString: htmlStr!)
            let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
            var videoModel = VideoModel.init()
            videoModel.videoArr = []
            videoModel.serialArr = []
            // 播放地址
            let jscontent: String = (jiDoc?.xPath("//*[@id=\"cms_play\"]/script[1]/text()")![0].content)!
            var htmlStr1 = jscontent.replacingOccurrences(of: "var zanpiancms_player =", with: "")
            htmlStr1 = htmlStr1.replacingOccurrences(of: "\\/", with: "/")
            let valueArr = htmlStr1.split(separator: ",")
            var urlStr1 = String(valueArr[1])
            urlStr1 = urlStr1.replacingOccurrences(of: "\"url\":\"", with: "")
            urlStr1 = urlStr1.replacingOccurrences(of: "\"", with: "")
            videoModel.videoUrl = urlStr1
            // 获取剧集
            let circuitNameXpath = "/html/body/div[2]/div[1]/div[2]/ul[2]/li[2]/ul/li/a"
            let circuitNodeArr = jiDoc?.xPath(circuitNameXpath)
            var circuitArr:[CircuitModel] = []
            if circuitNodeArr!.count > 0 {
                for (i,item) in circuitNodeArr!.enumerated() {
                    let model = CircuitModel.init()
                    model.name = item.content!
                    let serialTitleNodeArr = jiDoc?.xPath("//*[@id=\"con_playlist_\(i+1)\"]/li/a")
                    let serialUrlNodeArr = jiDoc?.xPath("//*[@id=\"con_playlist_\(i+1)\"]/li/a/@href")
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
            let recommendTitleXpath = "/html/body/div[2]/div[2]/div[1]/div/ul/li/div/a"
            let recommendUrlXpath = "/html/body/div[2]/div[2]/div[1]/div/ul/li/a/@href"
            let recommendImgXpath = "/html/body/div[2]/div[2]/div[1]/div/ul/li/a/img/@data-original"
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
                    model.webType = websiteType.juzhixiao.rawValue
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
        let titleXpath = "//*[@id=\"content\"]/ul/li/div[1]/a/span"
        let detailXpath = "//*[@id=\"content\"]/ul/li/div[2]/div[1]/h2/a/@href"
        let imgXpath = "//*[@id=\"content\"]/ul/li/div[1]/a/img/@data-original"
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
                videoModel.webType = websiteType.juzhixiao.rawValue
                listModel.list.append(videoModel)
            }
        }
        return [listModel]
    }
}
