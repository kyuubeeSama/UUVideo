//
//  SeSe.swift
//  UUVideo
//
//  Created by Galaxy on 2023/6/16.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji
class SeSe: WebsiteBaseModel,WebsiteProtocol {
    override init() {
        super.init()
        websiteName = "未命名"
        webUrlStr = "https://sex108.com/"
    }
    
    func getIndexData() -> [ListModel] {
        let idArr = [4,5,6,7,8,9,16,17,18,19,20,21,22]
        let titleArr = ["精品推荐","主播秀色","日本有码","日本无码","中文字幕","强奸乱伦","三级伦理","卡通动漫","丝袜OL","自拍偷拍","传媒系列","女同人妖","国产精品"]
        var resultArr: [ListModel] = []
        for (index,item) in idArr.enumerated() {
            let listModel = ListModel.init()
            listModel.title = titleArr[index]
            listModel.more = true
            listModel.list = []
            let urlStr = webUrlStr+"vodtype/\(item).html"
            let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
            if jiDoc == nil{
                listModel.list = []
            }else{
                let titleXPath = "//*[@class=\"video-elem\"]/a[2]"
                let urlXPath = "//*[@class=\"video-elem\"]/a[2]/@href"
                let imgXPath = "//*[@class=\"video-elem\"]/a/div/@style"
                let updateXPath = "//*[@class=\"video-elem\"]/a[1]/small"
                let titleNodeArr = jiDoc?.xPath(titleXPath)
                let urlNodeArr = jiDoc?.xPath(urlXPath)
                let imgNodeArr = jiDoc?.xPath(imgXPath)
                let updateNodeArr = jiDoc?.xPath(updateXPath)
                for (i, _) in titleNodeArr!.enumerated() {
                    if i < 8{
                        var videoModel = VideoModel.init()
                        videoModel.name = titleNodeArr![i].content!
                        videoModel.webType = websiteType.sese.rawValue
                        let detailUrl: String = urlNodeArr![i].content!
                        if detailUrl.contains("http") {
                            videoModel.detailUrl = detailUrl
                        } else {
                            videoModel.detailUrl = webUrlStr + detailUrl
                        }
                        var picUrl: String = imgNodeArr![i].content!
                        picUrl = picUrl.replacingOccurrences(of: "background-image: url(", with: "")
                        picUrl = picUrl.replacingOccurrences(of: "'", with: "")
                        picUrl = picUrl.replacingOccurrences(of: ")", with: "")
                        if picUrl.contains("http") {
                            videoModel.picUrl = picUrl
                        } else {
                            videoModel.picUrl = webUrlStr + picUrl
                        }
                        videoModel.num = updateNodeArr![i].content!
                        videoModel.type = 3
                        listModel.list.append(videoModel)
                    }
                }
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
        let titleXpath = "//*[@class=\"video-elem\"]/a[2]"
        let urlXpath = "//*[@class=\"video-elem\"]/a[2]/@href"
        let imgXpath = "//*[@class=\"video-elem\"]/a/div/@style"
        let updateXpath = "//*[@class=\"video-elem\"]/a[1]/small"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let urlNodeArr = jiDoc?.xPath(urlXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        let updateNodeArr = jiDoc?.xPath(updateXpath)
//        if imgNodeArr?.count != titleNodeArr?.count{
//            // 两边长度不一致，表明中间有广告
//            let cha = (imgNodeArr!.count - titleNodeArr!.count)/2
//            imgNodeArr?.removeSubrange(0..<cha)
//            updateNodeArr?.removeSubrange(0..<cha)
//        }
        for (i, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![i].content!
            videoModel.num = updateNodeArr![i].content!
            let detailUrl: String = urlNodeArr![i].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            var picUrl: String = imgNodeArr![i].content!
            picUrl = picUrl.replacingOccurrences(of: "background-image: url(", with: "")
            picUrl = picUrl.replacingOccurrences(of: "'", with: "")
            picUrl = picUrl.replacingOccurrences(of: ")", with: "")
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            videoModel.type = 3
            videoModel.webType = websiteType.sese.rawValue
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
        let titleXPath = "//*[@class=\"video-elem\"]/a[2]"
        let urlXPath = "//*[@class=\"video-elem\"]/a[2]/@href"
        let imgXPath = "//*[@class=\"video-elem\"]/a/div/@style"
        let titleNodeArr = jiDoc?.xPath(titleXPath)
        let urlNodeArr = jiDoc?.xPath(urlXPath)
        let imgNodeArr = jiDoc?.xPath(imgXPath)
        if titleNodeArr!.count > 0 {
            for (index, titleNode) in titleNodeArr!.enumerated() {
                var model = VideoModel.init()
                model.name = titleNode.content!
                var picUrl: String = imgNodeArr![index].content!
                picUrl = picUrl.replacingOccurrences(of: "background-image: url(", with: "")
                picUrl = picUrl.replacingOccurrences(of: "'", with: "")
                picUrl = picUrl.replacingOccurrences(of: ")", with: "")
                model.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
                let recommandUrlStr: String = urlNodeArr![index].content!
                model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                model.webType = websiteType.sese.rawValue
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
            let jsXpath = "//*[@id=\"videoShowPage\"]/div[1]/div/div[1]/div/script[1]/text()"
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
            serialModel.name = "默认"
            serialModel.detailUrl = urlStr
            model.serialArr.append(serialModel)
            let circuitArr:[CircuitModel] = [model]
            videoModel.circuitArr = circuitArr
            videoModel.serialNum = videoModel.serialArr.count
            //        推荐视频
            let titleXPath = "//*[@class=\"video-elem\"]/a[2]"
            let urlXPath = "//*[@class=\"video-elem\"]/a[2]/@href"
            let imgXPath = "//*[@class=\"video-elem\"]/a/div/@style"
            let titleNodeArr = jiDoc?.xPath(titleXPath)
            let urlNodeArr = jiDoc?.xPath(urlXPath)
            let imgNodeArr = jiDoc?.xPath(imgXPath)
            if titleNodeArr!.count > 0 {
                for (index, titleNode) in titleNodeArr!.enumerated() {
                    var model = VideoModel.init()
                    model.name = titleNode.content!
                    var picUrl: String = imgNodeArr![index].content!
                    picUrl = picUrl.replacingOccurrences(of: "background-image: url(", with: "")
                    picUrl = picUrl.replacingOccurrences(of: "'", with: "")
                    picUrl = picUrl.replacingOccurrences(of: ")", with: "")
                    model.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
                    let recommandUrlStr: String = urlNodeArr![index].content!
                    model.detailUrl = Tool.checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                    model.webType = websiteType.sese.rawValue
                    model.num = ""
                    model.type = 3
                    videoModel.videoArr.append(model)
                }
            }
            videoModel.videoUrl = videoModel.videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return (result: true, model: videoModel)
        }
    }
    
    func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        let urlStr = webUrlStr + "vodsearch/\(keyword)----------\(pageNum)---.html"
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
        let titleXpath = "//*[@class=\"video-elem\"]/a[2]"
        let detailXpath = "//*[@class=\"video-elem\"]/a[2]/@href"
        let imgXpath = "//*[@class=\"video-elem\"]/a/div/@style"
        let titleNodeArr = jiDoc?.xPath(titleXpath)
        let detailNodeArr = jiDoc?.xPath(detailXpath)
        let imgNodeArr = jiDoc?.xPath(imgXpath)
        for (index, _) in titleNodeArr!.enumerated() {
            var videoModel = VideoModel.init()
            videoModel.name = titleNodeArr![index].content!
            videoModel.detailUrl = Tool.checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
            var picUrl: String = imgNodeArr![index].content!
            picUrl = picUrl.replacingOccurrences(of: "background-image: url(", with: "")
            picUrl = picUrl.replacingOccurrences(of: "'", with: "")
            picUrl = picUrl.replacingOccurrences(of: ")", with: "")
            videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
            videoModel.type = 3
            videoModel.webType = websiteType.sese.rawValue
            listModel.list.append(videoModel)
        }
        return [listModel]
    }
}
