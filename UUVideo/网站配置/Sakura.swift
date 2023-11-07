//
//  Sakura.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/9.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji

class Sakura: WebsiteBaseModel {
    required override init() {
        super.init()
        webUrlStr = "http://www.yinghuavideo.com/"
        websiteName = "樱花动漫"
        valueArr = ["japan", "china", "american", "movie"]
    }
    override func getIndexData() -> [ListModel] {
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
                videoModel.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
                let picUrl: String = imgNodeArr![i].content!
                videoModel.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
                videoModel.type = 3
                listModel.list.append(videoModel)
            }
            resultArr.append(listModel)
        }
        return resultArr
    }
    override func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        var pageInfo = ""
        if pageNum > 1 {
            pageInfo = "\(pageNum).html"
        }
        var videoType = valueArr[videoTypeIndex]
        if !category.area.isEmpty {
            videoType = category.area
        }
        if !category.year.isEmpty {
            videoType = category.year
        }
        if !category.videoCategory.isEmpty {
            videoType = category.videoCategory
        }
        let urlStr = webUrlStr + "\(videoType)/" + pageInfo
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let listModel = ListModel.init()
        listModel.title = ""
        listModel.more = false
        listModel.list = []
        var contentXpathStr = "/div[2]"
        if videoTypeIndex < 3 {
            contentXpathStr = "/div[3]/div[1]"
        }
        let titleXpath = "/html/body/div[4]\(contentXpathStr)/ul/li/a/img/@alt"
        let urlXpath = "/html/body/div[4]\(contentXpathStr)/ul/li/a/@href"
        let imgXpath = "/html/body/div[4]\(contentXpathStr)/ul/li/a/img/@src"
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
    override func getVideoCategory(videoTypeIndex: Int) -> [CategoryListModel] {
        let titleArr = ["年代","地区","类型"]
        let valueArr = [
            ["2021","2020","2019","2018","2017","2016","2015","2014","2013","2012"],
            ["japan","china","american","england","korea"],
            ["66","64","91","70","67","111","83","81","75","74","84","73","72","102","61","69","62","103","85","99","80","119"]
        ]
        let nameArr = [
            ["2021","2020","2019","2018","2017","2016","2015","2014","2013","2012"],
            ["日本","大陆","美国","英国","韩国"],
            ["热血","格斗","恋爱","校园","搞笑","萝莉","神魔","机战","科幻","真人","青春","魔法","美少女","神话","冒险","运动","竞技","童话","励志","后宫","战争","吸血鬼"]
        ]
        var resultArr:[CategoryListModel] = []
        for (i,item) in nameArr.enumerated() {
            let listModel = CategoryListModel.init()
            for (index,_) in item.enumerated() {
                let model = CategoryModel.init()
                model.name = nameArr[i][index]
                model.value = valueArr[i][index]
                listModel.list.append(model)
            }
            listModel.name = titleArr[i]
            resultArr.append(listModel)
        }
        return resultArr
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
    override func getVideoPlayerDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
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
    override func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        let urlStr = webUrlStr + "search/\(keyword)/?page=\(pageNum)"
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
