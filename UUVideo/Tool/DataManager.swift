//
//  DataManager.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/18.
//  Copyright © 2020 qykj. All rights reserved.
//

import Foundation
import Ji

enum XPathError:Error {
    case getContentFail
}

enum websiteType:Int {
    case halihali = 0
    case laikuaibo = 1
}

class DataManager: NSObject {
    /// 获取新番数据
    /// - Parameters:
    ///   - dayIndex: 当前为第几天
    ///   - success: 返回视频列表
    ///   - failure: 返回错误
    /// - Returns: 空
    func getBangumiData(dayIndex:Int,success:@escaping(_ listArr:[VideoModel])->(),failure:@escaping(_ error:Error)->()) {
        let jiDoc = Ji(htmlURL: URL.init(string: "http://halihali2.com/zhougen/")!)
        if (jiDoc == nil) {
            failure(XPathError.getContentFail)
        }else{
            //*[@id="con_dm_1"]/span[2]/a  获取标题
            //*[@id="con_dm_2"]/span[2]/a/@href 详情地址
            var listArr:[VideoModel] = []
            // 获取标题
            let titlePath = "//*[@id=\"con_dm_\(dayIndex+1)\"]/span/a"
            let titleNodeArr = jiDoc?.xPath(titlePath)
            // 获取详情地址
            let urlPath = "//*[@id=\"con_dm_\(dayIndex+1)\"]/span/a/@href"
            let urlNodeArr = jiDoc?.xPath(urlPath)
            for (index,_) in titleNodeArr!.enumerated() {
                if (index>0){
                    let titleNode = titleNodeArr![index]
                    let titleStr:NSString = titleNode.content! as NSString
                    // 从标题中提取出标题和更新信息
                    let beginRange = titleStr.range(of: "(")
                    let endRange = titleStr.range(of: ")")
                    let string = titleStr.substring(with: NSRange.init(location: beginRange.location+1, length: endRange.location-beginRange.location-1))
                    // 标题
                    let title = titleStr.substring(to: beginRange.location)
                    // 更新记录
                    let update = string.replacingOccurrences(of: "最新:", with: "")
                    let urlNode = urlNodeArr![index-1]
                    let model = VideoModel.init()
                    model.name = title
                    let detailUrl:String = urlNode.content!
                   model.detailUrl = checkUrl(urlStr: detailUrl, domainUrlStr: "http://halihali2.com")
                    model.num = update
                    model.type = 4
                    model.picUrl = ""
                    listArr.append(model)
                }
            }
            success(listArr)
        }
    }
    
    // 获取站点首页数据
    func getWebsiteIndexData(type:websiteType,success:@escaping(_ listData:[ListModel])->(),failure:@escaping(_ error:Error)->()){
        let urlArr = ["http://halihali2.com/","https://www.laikuaibo.com/"]
        let jiDoc = Ji(htmlURL: URL.init(string: urlArr[type.rawValue])!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        }else{
            let divArr = [[5,6,7,8],[3,5,7,9,0]]
            let titleArr = [["动漫","电视剧","电影","综艺"],["电影","剧集","综艺","动漫","伦理"]]
            var resultArr:[ListModel] = []
            for (index,value) in divArr[type.rawValue].enumerated() {
                let listModel = ListModel.init()
                var titleXpath = ""
                var urlXpath = ""
                var imgXpath = ""
                var updateXpath = ""
                if type == .halihali {
                    titleXpath = "/html/body/div[2]/div[\(value)]/div[1]/ul/li/a/@title"
                    urlXpath = "/html/body/div[2]/div[\(value)]/div[1]/ul/li/a/@href"
                    imgXpath = "/html/body/div[2]/div[\(value)]/div[1]/ul/li/a/div[1]/img/@data-original"
                    updateXpath = "/html/body/div[2]/div[\(value)]/div[1]/ul/li/a/div[1]/p"
                    
                }else{
                    titleXpath = "/html/body/div[\(value)]/div[2]/div[1]/ul/li/h2/a"
                    urlXpath = "/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/@href"
                    imgXpath = "/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/img/@data-original"
                    updateXpath = "/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/span"
                }
                let titleNodeArr = jiDoc?.xPath(titleXpath)
                let urlNodeArr = jiDoc?.xPath(urlXpath)
                let imgNodeArr = jiDoc?.xPath(imgXpath)
                let updateNodeArr = jiDoc?.xPath(updateXpath)
                listModel.title = titleArr[type.rawValue][index]
                listModel.more = true
                listModel.list = []
                for (i,_) in titleNodeArr!.enumerated() {
                    let videoModel = VideoModel.init()
                    videoModel.name = titleNodeArr![i].content
                    
                    let detailUrl:String = urlNodeArr![i].content!
                    if detailUrl.contains("http") {
                        videoModel.detailUrl = detailUrl
                    }else{
                        videoModel.detailUrl = urlArr[type.rawValue]+detailUrl
                    }
                    
                    let picUrl:String = imgNodeArr![i].content!
                    if picUrl.contains("http") {
                        videoModel.picUrl = picUrl
                    }else{
                        videoModel.picUrl = urlArr[type.rawValue]+picUrl
                    }
                    videoModel.num = updateNodeArr![i].content
                    videoModel.type = 3
                    listModel.list?.append(videoModel)
                }
                resultArr.append(listModel)
            }
            success(resultArr)
        }
    }
    
    // 获取视频列表
    func getVideoListData(urlStr:String,type:websiteType,success:@escaping(_ listData:[ListModel])->(),failure:@escaping(_ error:Error)->()){
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        }else{
            let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
            let listModel = ListModel.init()
            listModel.title = ""
            listModel.more = false
            listModel.list = []
            var titleXpath = ""
            var urlXpath = ""
            var imgXpath = ""
            var updateXpath = ""
            if type == .halihali {
                titleXpath = "/html/body/li/a/@title"
                urlXpath = "/html/body/li/a/@href"
                imgXpath = "/html/body/li/a/div[1]/img/@data-original"
                updateXpath = "/html/body/li/a/div[1]"
            }else{
                titleXpath = "/html/body/div[1]/ul/li/h2/a"
                urlXpath = "/html/body/div[1]/ul/li/p/a/@href"
                imgXpath = "/html/body/div[1]/ul/li/p/a/img/@data-original"
                updateXpath = "/html/body/div[1]/ul/li/p/a/span"
            }
            let titleNodeArr = jiDoc?.xPath(titleXpath)
            let urlNodeArr = jiDoc?.xPath(urlXpath)
            let imgNodeArr = jiDoc?.xPath(imgXpath)
            let updateNodeArr = jiDoc?.xPath(updateXpath)
            for (i,_) in titleNodeArr!.enumerated() {
                let videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content
                videoModel.num = updateNodeArr![i].content
                let detailUrl:String = urlNodeArr![i].content!
                videoModel.detailUrl = checkUrl(urlStr: detailUrl, domainUrlStr: baseUrl)
                let picUrl:String = imgNodeArr![i].content!
                videoModel.picUrl = checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
                videoModel.type = 3
                listModel.list?.append(videoModel)
            }
            success([listModel])
        }
    }
    
    /// 获取分类数据
    /// - Parameters:
    ///   - urlStr: 请求地址
    ///   - type: 站点
    ///   - success: 成功返回
    ///   - failure: 失败返回
    /// - Returns: 空
    func getWebsiteCategoryData(urlStr:String,type:websiteType,success:@escaping(_ listData:[CategoryListModel])->(),failure:@escaping(_ error:Error)->()){
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        }else{
            var listArr:[CategoryListModel]=[]
            let titleArr = [["按剧情","按年代","按地区"]]
            if type == .halihali {
                for item in 1...3 {
                    let chooseArr = ["","","js-tongjip "]
                    let titleXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a"
                    let urlXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a/@href"
                    let chooseXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a[@class='\(chooseArr[item-1])on']"
                    let titleNodeArr = jiDoc?.xPath(titleXpath)
                    let urlNodeArr = jiDoc?.xPath(urlXpath)
                    let chooseNodeArr = jiDoc?.xPath(chooseXpath)
                    let listModel = CategoryListModel.init()
                    listModel.name = titleArr[type.rawValue][item-1]
                    listModel.list = []
                    for (index,_) in titleNodeArr!.enumerated() {
                        let categoryModel = CategoryModel.init()
                        let name = titleNodeArr![index].content
                        categoryModel.name = name
                        let detailUrl = urlNodeArr![index].content
                        let detailUrlArr = detailUrl?.components(separatedBy: "/")
                        if chooseNodeArr!.count>0 && name == chooseNodeArr![0].content {
                            categoryModel.ischoose = true
                        }
                        if item == 1 {
                            categoryModel.value = detailUrlArr![5]
                        }else if item == 2{
                            categoryModel.value = detailUrlArr![4]
                        }else {
                            categoryModel.value = detailUrlArr![6]
                        }
                        listModel.list?.append(categoryModel)
                    }
                    listArr.append(listModel)
                }
                success(listArr)
            }else{
                // TODO:待完善
                // 地区
                let areaNodeArr = jiDoc?.xPath("/html/body/div[1]/dl/dd[2]/div/div/a")
                let areaChooseNodeArr = jiDoc?.xPath("/html/body/div[1]/dl/dd[2]/div/div/a[@class='btn-success']")
                let areaListModel = CategoryListModel.init()
                areaListModel.name = "地区"
                areaListModel.list = []
                // 将具体的分类编入数组
                for (index,_) in areaNodeArr!.enumerated() {
                    let categoryModel = CategoryModel.init()
                    let name = areaNodeArr![index].content
                    categoryModel.name = name
                    // 获取当前选中的分类
                    for chooseNode in areaChooseNodeArr! {
                        if name == chooseNode.content {
                            categoryModel.ischoose = true
                        }
                    }
                    areaListModel.list?.append(categoryModel)
                }
                listArr.append(areaListModel)
                // 排序
                let orderNodeArr = jiDoc?.xPath("/html/body/div[1]/div[3]/div/a")
                let orderChooseNodeArr = jiDoc?.xPath("/html/body/div[1]/div[3]/div/a[@class='btn-success']")
                let orderListModel = CategoryListModel.init()
                orderListModel.name = "排序"
                orderListModel.list = []
                // 将具体的分类编入数组
                for (index,_) in orderNodeArr!.enumerated() {
                    let categoryModel = CategoryModel.init()
                    let name = orderNodeArr![index].content
                    categoryModel.name = name
                    // 获取当前选中的分类
                    for chooseNode in orderChooseNodeArr! {
                        if name == chooseNode.content {
                            categoryModel.ischoose = true
                        }
                    }
                    orderListModel.list?.append(categoryModel)
                }
                listArr.append(orderListModel)
                success(listArr)
            }
        }
    }
    
    /// 获取视频详情界面相关数据
    /// - Parameters:
    ///   - urlStr: 视频地址
    ///   - success: 成功返回
    /// - Returns: listArr:[videoModel]
    func getVideoDetailData(urlStr:String,type:websiteType,success:@escaping(_ VideoModel:VideoModel)->(),failure:@escaping(_ error:Error)->()){
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        }else{
            let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
            let videoModel = VideoModel.init()
            videoModel.videoArr = []
            videoModel.tagArr = []
            videoModel.serialArr = []
            var serialPathXpath = ""
            var serialNameXpath = ""
            var titleXPath = ""
            var urlXPath = ""
            var imgXPath = ""
            var updateXpath = ""
            if type == .halihali {
                // 获取视频封面
                let videoPicXpath = "/html/body/div[2]/div[2]/div[1]/img/@data-original"
                let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
                let picurl:String = videoPicNodeArr![0].content!
                videoModel.picUrl = checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
                // 剧集信息
                serialPathXpath = "//*[@id=\"stab_1_71\"]/ul/li/a/@href"
                serialNameXpath = "//*[@id=\"stab_1_71\"]/ul/li/a"
                // 推荐视频标题
                titleXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/@title"
                urlXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/@href"
                imgXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/div[1]/img/@data-original"
            }else{
                //        视频封面
                let videoImgNodeArr = jiDoc?.xPath("/html/body/div[1]/div[1]/div[1]/div/div[1]/a/img/@data-original")
                videoModel.picUrl = "https://www.laikuaibo.com/"+videoImgNodeArr![0].content!
                //        视频标题
                let videoTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[1]/div[1]/div/div[2]/h4/a")
                videoModel.name = videoTitleNodeArr![0].content
                // 获取tag
                let tagIndexArr = [1,2,4,6]
                for item in tagIndexArr {
                    let tagNodeArr = jiDoc?.xPath("/html/body/div[1]/div[1]/div[1]/div/div[2]/dl/dd[\(item)]/a")
                    var tagArr:[String] = []
                    for tagNode in tagNodeArr! {
                        let tag = tagNode.content
                        tagArr.append(tag!)
                    }
                    videoModel.tagArr?.append(tagArr)
                }
                // 剧集信息
                serialPathXpath = "/html/body/div[1]/div[3]/ul/li/a/@href"
                serialNameXpath = "/html/body/div[1]/div[3]/ul/li/a"
                // 推荐视频
                titleXPath = "/html/body/div[1]/ul[2]/li/h2/a"
                urlXPath = "/html/body/div[1]/ul[2]/li/h2/a/@href"
                imgXPath = "/html/body/div[1]/ul[2]/li/p/a/img/@data-original"
                updateXpath = "/html/body/div[1]/ul[2]/li/p/a/span"
            }
            //        剧集
            let serialTitleNodeArr = jiDoc?.xPath(serialNameXpath)
            let serialUrlNodeArr = jiDoc?.xPath(serialPathXpath)
            if serialUrlNodeArr!.count>0 {
                for (index,item) in serialUrlNodeArr!.enumerated() {
                    let serial = SerialModel.init()
                    serial.name = serialTitleNodeArr![index].content
                    let serialDetailUrl:String = item.content!
                    serial.detailUrl = checkUrl(urlStr: serialDetailUrl, domainUrlStr: baseUrl)
                    videoModel.serialArr?.append(serial)
                }
            }
            //        推荐视频
            let titleNodeArr = jiDoc?.xPath(titleXPath)
            let urlNodeArr = jiDoc?.xPath(urlXPath)
            let imgNodeArr = jiDoc?.xPath(imgXPath)
            let updateNodeArr = jiDoc?.xPath(updateXpath)
            if titleNodeArr!.count > 0{
                for (index,titleNode) in titleNodeArr!.enumerated() {
                    let recommandUrlStr:String = urlNodeArr![index].content!
                    let imgPic:String = imgNodeArr![index].content!
                    let model = VideoModel.init()
                    model.name = titleNode.content
                    model.picUrl = checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                    model.detailUrl = checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                    if type == .halihali{
                        model.num = ""
                    }else{
                        model.num = updateNodeArr![index].content

                    }
                    model.type = 3
                    videoModel.videoArr!.append(model)
                }
            }
            success(videoModel)
        }
    }
        
    // 判断是否有http，并拼接地址
    func checkUrl(urlStr:String,domainUrlStr:String) -> String {
        if urlStr.contains("http") {
            return urlStr
        }else{
            return domainUrlStr+urlStr
        }
    }
    
    // 搜索数据
    func getSearchData(urlStr:String,keyword:String,website:websiteType,success:@escaping(_ searchData:[ListModel])->()){
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        let listModel = ListModel.init()
        listModel.title = "搜索关键字:"+keyword
        listModel.more = false
        listModel.list = []
        var titleNodeArr:[JiNode] = []
        var detailNodeArr:[JiNode] = []
        var updateNodeArr:[JiNode] = []
        var imgNodeArr:[JiNode] = []
        
        if website == .halihali {
            // 获取当前选中的状态，如果是视频，继续判断，否则返回空
            //        /html/body/div[2]/div/div[1]/div/ul/li[2]/a/@class
            let activeNodeArr = jiDoc?.xPath("/html/body/div[2]/div/div[1]/div/ul/li[2]/a/@class")
            //        /html/body/div[2]/div/div[1]/div/ul/li[3]/a/@class
            if activeNodeArr![0].content == "active" {
                //            标题
                titleNodeArr = (jiDoc?.xPath("//*[@id=\"content\"]/div/div[1]/a/@title"))!
                //            详情
                detailNodeArr = (jiDoc?.xPath("//*[@id=\"content\"]/div/div[1]/a/@href"))!
                //            状态
                updateNodeArr = (jiDoc?.xPath("//*[@id=\"content\"]/div/div[2]/ul/li[3]/text()"))!
                //            封面
                imgNodeArr = (jiDoc?.xPath("//*[@id=\"content\"]/div/div[1]/a/@data-original"))!
            }
        }else if website == .laikuaibo{
            titleNodeArr = (jiDoc?.xPath("/html/body/div[1]/ul/li/h2/a"))!
            detailNodeArr = (jiDoc?.xPath("/html/body/div[1]/ul/li/h2/a/@href"))!
            updateNodeArr = (jiDoc?.xPath("/html/body/div[1]/ul/li/p/a/span"))!
            imgNodeArr = (jiDoc?.xPath("/html/body/div[1]/ul/li/p/a/img/@data-original"))!
        }
        for (index,_) in titleNodeArr.enumerated(){
            let videoModel = VideoModel.init()
            videoModel.name = titleNodeArr[index].content
            videoModel.num = updateNodeArr[index].content
            var baseUrl = ""
            if website == .laikuaibo {
                baseUrl = "https://www.laikuaibo.com/"
            }
            videoModel.detailUrl = baseUrl+detailNodeArr[index].content!
            videoModel.picUrl = baseUrl+imgNodeArr[index].content!
            videoModel.type = 3
            listModel.list?.append(videoModel)
        }
        success([listModel])
    }
            
    /// 来快播视频播放界面
    /// - Parameters:
    ///   - urlStr: 视频详情地址
    ///   - success: 成功返回
    /// - Returns:
    func getLkbVideoDetailData(urlStr:String,success:@escaping(_ videoModel:VideoModel)->()){
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        let videoModel = VideoModel.init()
        videoModel.videoArr = []
        videoModel.serialArr = []
        // 获取视频详情
        let playerUrlNodeArr = jiDoc?.xPath("//*[@id=\"cms_player\"]/script[1]")
        if playerUrlNodeArr!.count>0 {
            var playerUrl = playerUrlNodeArr![0].content
            playerUrl = playerUrl?.replacingOccurrences(of: "var cms_player = ", with: "")
            playerUrl = playerUrl?.replacingOccurrences(of: ";", with: "")
            let dic = Dictionary<String, String>.init().stringValueDic(playerUrl!)
            let urlStr:String = "https://www.bfq168.com/m3u8.php?url="+(dic!["url"] as! String)
            videoModel.videoUrl = urlStr
            // 获取推荐视频
            let titleNodeArr = jiDoc?.xPath("/html/body/div[1]/ul[1]/li/h2/a")
            let urlNodeArr = jiDoc?.xPath("/html/body/div[1]/ul[1]/li/p/a/@href")
            let imgNodeArr = jiDoc?.xPath("/html/body/div[1]/ul[1]/li/p/a/img/@data-original")
            let updateNodeArr = jiDoc?.xPath("/html/body/div[1]/ul[1]/li/p/a/span")
            for (i,_) in titleNodeArr!.enumerated() {
                let recomondVideoModel = VideoModel.init()
                recomondVideoModel.name = titleNodeArr![i].content
                recomondVideoModel.detailUrl = "https://www.laikuaibo.com/"+urlNodeArr![i].content!
                recomondVideoModel.picUrl = "https://www.laikuaibo.com/"+imgNodeArr![i].content!
                recomondVideoModel.num = updateNodeArr![i].content
                recomondVideoModel.type = 3
                videoModel.videoArr?.append(recomondVideoModel)
                //                print("封面是\(videoModel.picUrl),标提是\(videoModel.name) 更新信息是\(videoModel.num), 详情地址是\(videoModel.detailUrl)")
            }
            //TODO:获取剧集信息
            //        标题
            let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[6]/ul/li/a")
            //        详情
            let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[1]/div[6]/ul/li/a/@href")
            for (index,_) in serialTitleNodeArr!.enumerated() {
                let serialModel = SerialModel.init()
                serialModel.name = serialTitleNodeArr![index].content
                serialModel.detailUrl = serialUrlNodeArr![index].content
                videoModel.serialArr?.append(serialModel)
            }
        }
        success(videoModel)
    }
}
