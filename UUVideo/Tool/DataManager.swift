//
//  DataManager.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/18.
//  Copyright © 2020 qykj. All rights reserved.
//

import Foundation
import Ji
import Alamofire
import SwiftyJSON

enum XPathError: Error {
    case getContentFail
}

enum websiteType: Int {
    case halihali = 0
    case laikuaibo = 1
    case sakura = 2
}

class DataManager: NSObject {
    /// 获取新番数据
    /// - Parameters:
    ///   - dayIndex: 当前为第几天
    ///   - success: 返回视频列表
    ///   - failure: 返回错误
    /// - Returns: 空
    func getBangumiData(dayIndex: Int, success: @escaping (_ listArr: [VideoModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        let jiDoc = Ji(htmlURL: URL.init(string: "http://halihali2.com/zhougen/")!)
        if (jiDoc == nil) {
            failure(XPathError.getContentFail)
        } else {
            //*[@id="con_dm_1"]/span[2]/a  获取标题
            //*[@id="con_dm_2"]/span[2]/a/@href 详情地址
            var listArr: [VideoModel] = []
            // 获取标题
            let titlePath = "//*[@id=\"con_dm_\(dayIndex + 1)\"]/span/a"
            let titleNodeArr = jiDoc?.xPath(titlePath)
            // 获取详情地址
            let urlPath = "//*[@id=\"con_dm_\(dayIndex + 1)\"]/span/a/@href"
            let urlNodeArr = jiDoc?.xPath(urlPath)
            for (index, _) in titleNodeArr!.enumerated() {
                if (index > 0) {
                    let titleNode = titleNodeArr![index]
                    let titleStr: NSString = titleNode.content! as NSString
                    // 从标题中提取出标题和更新信息
                    let beginRange = titleStr.range(of: "(")
                    let endRange = titleStr.range(of: ")")
                    let string = titleStr.substring(with: NSRange.init(location: beginRange.location + 1, length: endRange.location - beginRange.location - 1))
                    // 标题
                    let title = titleStr.substring(to: beginRange.location)
                    // 更新记录
                    let update = string.replacingOccurrences(of: "最新:", with: "")
                    let urlNode = urlNodeArr![index - 1]
                    var model = VideoModel.init()
                    model.name = title
                    let detailUrl: String = urlNode.content!
                    model.detailUrl = checkUrl(urlStr: detailUrl, domainUrlStr: "http://halihali2.com")
                    model.num = update
                    model.type = 4
                    model.picUrl = ""
                    model.webType = 0
                    listArr.append(model)
                }
            }
            success(listArr)
        }
    }

    /// 获取站点首页数据
    /// - Parameters:
    ///   - type: 站点
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: nil
    func getWebsiteIndexData(type: websiteType, success: @escaping (_ listData: [ListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        let urlArr = ["http://halihali2.com/", "https://www.laikuaibo.com/","http://www.yhdm.so/"]
        let jiDoc = Ji(htmlURL: URL.init(string: urlArr[type.rawValue])!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        } else {
            let divArr = [[5, 6, 7, 8], [3, 5, 7, 9, 0],[4,6,8,10]]
            let titleArr = [["动漫", "电视剧", "电影", "综艺"], ["电影", "剧集", "综艺", "动漫", "伦理"],["日本动漫","国产动漫","欧美动漫","动漫电影"]]
            var resultArr: [ListModel] = []
            for (index, value) in divArr[type.rawValue].enumerated() {
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
                } else if type == .laikuaibo{
                    titleXpath = "/html/body/div[\(value)]/div[2]/div[1]/ul/li/h2/a"
                    urlXpath = "/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/@href"
                    imgXpath = "/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/img/@data-original"
                    updateXpath = "/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/span"
                }else{
                    titleXpath = "/html/body/div[8]/div[1]/div[\(value)]/ul[1]/li/p[1]/a"
                    urlXpath = "/html/body/div[8]/div[1]/div[\(value)]/ul[1]/li/a/@href"
                    imgXpath = "/html/body/div[8]/div[1]/div[\(value)]/ul[1]/li/a/img/@src"
                    updateXpath = "/html/body/div[8]/div[1]/div[\(value)]/ul[1]/li/p[2]/a"
                }
                let titleNodeArr = jiDoc?.xPath(titleXpath)
                let urlNodeArr = jiDoc?.xPath(urlXpath)
                let imgNodeArr = jiDoc?.xPath(imgXpath)
                let updateNodeArr = jiDoc?.xPath(updateXpath)
                listModel.title = titleArr[type.rawValue][index]
                listModel.more = true
                listModel.list = []
                for (i, _) in titleNodeArr!.enumerated() {
                    var videoModel = VideoModel.init()
                    videoModel.name = titleNodeArr![i].content
                    videoModel.webType = type.rawValue
                    let detailUrl: String = urlNodeArr![i].content!
                    if detailUrl.contains("http") {
                        videoModel.detailUrl = detailUrl
                    } else {
                        videoModel.detailUrl = urlArr[type.rawValue] + detailUrl
                    }

                    let picUrl: String = imgNodeArr![i].content!
                    if picUrl.contains("http") {
                        videoModel.picUrl = picUrl
                    } else {
                        videoModel.picUrl = urlArr[type.rawValue] + picUrl
                    }
                    if type != .sakura {
                        videoModel.num = updateNodeArr![i].content!
                    }
                    videoModel.type = 3
                    listModel.list.append(videoModel)
                }
                resultArr.append(listModel)
            }
            success(resultArr)
        }
    }

    /// 获取视频列表
    /// - Parameters:
    ///   - urlStr: 站点地址
    ///   - type: 站点
    ///   - success: 成功
    ///   - failure: 失败
    /// - Returns: nil
    func getVideoListData(urlStr: String, type: websiteType, success: @escaping (_ listData: [ListModel],_ allPageNum:NSInteger) -> (), failure: @escaping (_ error: Error) -> ()) {
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        } else {
            var baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
            if type == .halihali {
                baseUrl = "http://halihali2.com/"
            }
            var allPageNum = 0
            let listModel = ListModel.init()
            listModel.title = ""
            listModel.more = false
            listModel.list = []
            var titleXpath = ""
            var urlXpath = ""
            var imgXpath = ""
            var updateXpath = ""
            var pageNumXpath = ""
            if type == .halihali {
                titleXpath = "/html/body/li/a/@title"
                urlXpath = "/html/body/li/a/@href"
                imgXpath = "/html/body/li/a/div[1]/img/@data-original"
                updateXpath = "/html/body/li/a/div[1]"
            } else if type == .laikuaibo{
                titleXpath = "/html/body/div[1]/ul/li/h2/a"
                urlXpath = "/html/body/div[1]/ul/li/p/a/@href"
                imgXpath = "/html/body/div[1]/ul/li/p/a/img/@data-original"
                updateXpath = "/html/body/div[1]/ul/li/p/a/span"
                pageNumXpath = ""
            }else {
                titleXpath = "/html/body/div[4]/div[3]/div[1]/ul/li/h2/a/@title"
                urlXpath = "/html/body/div[4]/div[3]/div[1]/ul/li/h2/a/@href"
                imgXpath = "/html/body/div[4]/div[3]/div[1]/ul/li/a/img/@src"
                pageNumXpath = "//*[@id=\"lastn\"]"
            }
            let titleNodeArr = jiDoc?.xPath(titleXpath)
            let urlNodeArr = jiDoc?.xPath(urlXpath)
            let imgNodeArr = jiDoc?.xPath(imgXpath)
            let updateNodeArr = jiDoc?.xPath(updateXpath)
            let pageNodeArr = jiDoc?.xPath(pageNumXpath)
            for (i, _) in titleNodeArr!.enumerated() {
                var videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content
                if type != .sakura {
                    videoModel.num = updateNodeArr![i].content!
                }
                let detailUrl: String = urlNodeArr![i].content!
                videoModel.detailUrl = checkUrl(urlStr: detailUrl, domainUrlStr: baseUrl)
                let picUrl: String = imgNodeArr![i].content!
                videoModel.picUrl = checkUrl(urlStr: picUrl, domainUrlStr: baseUrl)
                videoModel.type = 3
                videoModel.webType = type.rawValue
                listModel.list.append(videoModel)
            }
            if type == .sakura{
                let allPageNumStr:String = pageNodeArr![0].content!
                allPageNum = Int(allPageNumStr)!
            }
            success([listModel],allPageNum)
        }
    }

    /// 获取分类数据
    /// - Parameters:
    ///   - urlStr: 请求地址
    ///   - type: 站点
    ///   - success: 成功返回
    ///   - failure: 失败返回
    /// - Returns: 空
    func getWebsiteCategoryData(urlStr: String, type: websiteType, success: @escaping (_ listData: [CategoryListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        } else {
            var listArr: [CategoryListModel] = []
            let titleArr = [["按剧情", "按年代", "按地区"]]
            if type == .halihali {
                for item in 1...3 {
                    let chooseArr = ["", "", "js-tongjip "]
                    let titleXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a"
                    let urlXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a/@href"
                    let chooseXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a[@class='\(chooseArr[item - 1])on']"
                    let titleNodeArr = jiDoc?.xPath(titleXpath)
                    let urlNodeArr = jiDoc?.xPath(urlXpath)
                    let chooseNodeArr = jiDoc?.xPath(chooseXpath)
                    let listModel = CategoryListModel.init()
                    listModel.name = titleArr[type.rawValue][item - 1]
                    listModel.list = []
                    for (index, _) in titleNodeArr!.enumerated() {
                        let categoryModel = CategoryModel.init()
                        let name = titleNodeArr![index].content
                        categoryModel.name = name
                        let detailUrl = urlNodeArr![index].content
                        let detailUrlArr = detailUrl?.components(separatedBy: "/")
                        if chooseNodeArr!.count > 0 && name == chooseNodeArr![0].content {
                            categoryModel.ischoose = true
                        }
                        if item == 1 {
                            categoryModel.value = detailUrlArr![5]
                        } else if item == 2 {
                            categoryModel.value = detailUrlArr![4]
                        } else {
                            categoryModel.value = detailUrlArr![6]
                        }
                        listModel.list.append(categoryModel)
                    }
                    listArr.append(listModel)
                }
                success(listArr)
            } else {
                // TODO:待完善
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
                    categoryModel.name = name
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
                    categoryModel.name = name
                    // 获取当前选中的分类
                    for chooseNode in orderChooseNodeArr! {
                        if name == chooseNode.content {
                            categoryModel.ischoose = true
                        }
                    }
                    orderListModel.list.append(categoryModel)
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
    func getVideoDetailData(urlStr: String, type: websiteType, success: @escaping (_ VideoModel: VideoModel) -> (), failure: @escaping (_ error: Error) -> ()) {
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        } else {
            let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
            var videoModel = VideoModel.init()
            videoModel.detailUrl = urlStr
            videoModel.videoArr = []
            videoModel.tagArr = []
            videoModel.serialArr = []
            var videoPicXpath = ""
            var serialPathXpath = ""
            var serialNameXpath = ""
            var titleXPath = ""
            var urlXPath = ""
            var imgXPath = ""
            var updateXpath = ""
            if type == .halihali {
                // 获取视频封面
                videoPicXpath = "/html/body/div[2]/div[2]/div[1]/img/@data-original"
                // 剧集信息
                serialPathXpath = "//*[@id=\"stab_1_71\"]/ul/li/a/@href"
                serialNameXpath = "//*[@id=\"stab_1_71\"]/ul/li/a"
                // 推荐视频标题
                titleXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/@title"
                urlXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/@href"
                imgXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/div[1]/img/@data-original"
            } else if type == .laikuaibo{
                //        视频封面
                videoPicXpath = "/html/body/div[1]/div[1]/div[1]/div/div[1]/a/img/@data-original"
                //        视频标题
                let videoTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[1]/div[1]/div/div[2]/h4/a")
                videoModel.name = videoTitleNodeArr![0].content
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
                // 剧集信息
                serialPathXpath = "/html/body/div[1]/div[3]/ul/li/a/@href"
                serialNameXpath = "/html/body/div[1]/div[3]/ul/li/a"
                // 推荐视频
                titleXPath = "/html/body/div[1]/ul[2]/li/h2/a"
                urlXPath = "/html/body/div[1]/ul[2]/li/h2/a/@href"
                imgXPath = "/html/body/div[1]/ul[2]/li/p/a/img/@data-original"
                updateXpath = "/html/body/div[1]/ul[2]/li/p/a/span"
            }else{
                videoPicXpath = "/html/body/div[2]/div[2]/div[1]/img/@src"
                serialPathXpath = "//*[@id=\"main0\"]/div/ul/li/a/@href"
                serialNameXpath = "//*[@id=\"main0\"]/div/ul/li/a"
                titleXPath = "/html/body/div[2]/div[3]/div[2]/ul/li/a/img/@alt"
                urlXPath = "/html/body/div[2]/div[3]/div[2]/ul/li/h2/a/@href"
                imgXPath = "/html/body/div[2]/div[3]/div[2]/ul/li/a/img/@src"
                
            }
            let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
            let picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
            //        剧集
            let serialTitleNodeArr = jiDoc?.xPath(serialNameXpath)
            let serialUrlNodeArr = jiDoc?.xPath(serialPathXpath)
            if serialUrlNodeArr!.count > 0 {
                for (index, item) in serialUrlNodeArr!.enumerated() {
                    let serial = SerialModel.init()
                    serial.name = serialTitleNodeArr![index].content!
                    let serialDetailUrl: String = item.content!
                    serial.detailUrl = checkUrl(urlStr: serialDetailUrl, domainUrlStr: baseUrl)
                    videoModel.serialArr.append(serial)
                }
            }
            videoModel.serialNum = videoModel.serialArr.count
            //        推荐视频
            let titleNodeArr = jiDoc?.xPath(titleXPath)
            let urlNodeArr = jiDoc?.xPath(urlXPath)
            let imgNodeArr = jiDoc?.xPath(imgXPath)
            let updateNodeArr = jiDoc?.xPath(updateXpath)
            if titleNodeArr!.count > 0 {
                for (index, titleNode) in titleNodeArr!.enumerated() {
                    var model = VideoModel.init()
                    model.name = titleNode.content
                    let imgPic: String = imgNodeArr![index].content!
                    model.picUrl = checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                    let recommandUrlStr: String = urlNodeArr![index].content!
                    model.detailUrl = checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                    model.webType = type.rawValue
                    if type == .halihali || type == .sakura {
                        model.num = ""
                    } else {
                        model.num = updateNodeArr![index].content!
                    }
                    model.type = 3
                    videoModel.videoArr.append(model)
                }
            }
            success(videoModel)
        }
    }

    // 判断是否有http，并拼接地址
    func checkUrl(urlStr: String, domainUrlStr: String) -> String {
        if urlStr.contains("http") || urlStr.contains("https") {
            return urlStr
        } else {
            return domainUrlStr + urlStr
        }
    }

    // 搜索数据
    func getSearchData(urlStr: String, keyword: String, website: websiteType, success: @escaping (_ searchData: [ListModel]) -> (), failure: @escaping (_ error: Error) -> ()) {
        let listModel = ListModel.init()
        listModel.title = "搜索关键字:" + keyword
        listModel.more = false
        listModel.list = []
        let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
        if website == .halihali {
            AF.request("http://119.29.158.173:9988/ssszz.php", method: .get, parameters: ["q": keyword]).responseJSON { [self](response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for item in json {
                        var videoModel = VideoModel.init()
                        videoModel.name = item.1["title"].string
                        videoModel.num = item.1["lianzaijs"].string!
                        videoModel.detailUrl = checkUrl(urlStr: item.1["url"].string!, domainUrlStr: baseUrl)
                        videoModel.picUrl = item.1["thumb"].string!
                        videoModel.type = 3
                        videoModel.webType = 0
                        listModel.list.append(videoModel)
                    }
                    success([listModel])
                case .failure(let error):
                    print(error)
                    failure(error)
                }
            }
        } else {
            let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
            if jiDoc == nil {
                failure(XPathError.getContentFail)
            } else {
                var titleXpath = ""
                var detailXpath = ""
                var imgXpath = ""
                var updateXpath = ""
                if website == .laikuaibo {
                    titleXpath = "/html/body/div[1]/ul/li/h2/a"
                    detailXpath = "/html/body/div[1]/ul/li/h2/a/@href"
                    imgXpath = "/html/body/div[1]/ul/li/p/a/img/@data-original"
                    updateXpath = "/html/body/div[1]/ul/li/p/a/span"
                }else{
                    titleXpath = "/html/body/div[4]/div[2]/div/ul/li/h2/a/@title"
                    detailXpath = "/html/body/div[4]/div[2]/div/ul/li/h2/a/@href"
                    imgXpath = "/html/body/div[4]/div[2]/div/ul/li/a/img/@src"
                    updateXpath = ""
                }
                let titleNodeArr = jiDoc?.xPath(titleXpath)
                let detailNodeArr = jiDoc?.xPath(detailXpath)
                let updateNodeArr = jiDoc?.xPath(updateXpath)
                let imgNodeArr = jiDoc?.xPath(imgXpath)
                for (index, _) in titleNodeArr!.enumerated() {
                    var videoModel = VideoModel.init()
                    videoModel.name = titleNodeArr![index].content
                    if website != .sakura {
                        videoModel.num = updateNodeArr![index].content!
                    }
                    videoModel.detailUrl = checkUrl(urlStr: detailNodeArr![index].content!, domainUrlStr: baseUrl)
                    videoModel.picUrl = checkUrl(urlStr: imgNodeArr![index].content!, domainUrlStr: baseUrl)
                    videoModel.type = 3
                    videoModel.webType = website.rawValue
                    listModel.list.append(videoModel)
                }
                success([listModel])
            }
        }
    }

    //获取播放界面
    func getVideoPlayerData(urlStr: String, website: websiteType, videoNum:Int, success: @escaping (_ videoModel: VideoModel) -> (), failure: @escaping (_ error: Error) -> ()) {
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if jiDoc == nil {
            failure(XPathError.getContentFail)
        } else {
            let baseUrl = Tool.getRegularData(regularExpress: "((http://)|(https://))[^\\.]*\\.(?<domain>[^/|?]*)", content: urlStr)[0]
            var videoModel = VideoModel.init()
            videoModel.videoArr = []
            videoModel.serialArr = []
            var recommendTitleXpath = ""
            var recommendUrlXpath = ""
            var recommendImgXpath = ""
            var recommendUpdateXpath = ""
            if website == .halihali {
//                TODO:获取剧集
//                                http://t.mtyee.com/ne2/s51696.js?1619401415
                                // 从js中获取视频信息，组装剧集model
                let jsXPath = "/html/script/@src"
                let jsNodeArr = jiDoc?.xPath(jsXPath)
                if jsNodeArr!.count>0 {
                    // 获取播放地址等内容
//                    获取js内容
                    var jsContent = ""
                    do {
                        print(jsNodeArr![0].content!)
                        let data = try Data.init(contentsOf: URL.init(string: jsNodeArr![0].content!)!, options:[])
                        jsContent = String.init(data: data, encoding: .utf8)!
                        var array = jsContent.split(separator: ";")
                        var firstIndex = 0
                        for (index,item) in array.enumerated() {
                            if item.contains("=\(videoNum)") && item.contains("lianzaijs") {
                                // 获取到正确的第一个位置
                                firstIndex = index
                                break
                            }
                        }
                        array.removeFirst(firstIndex)
                        let titleItem = array[0]
                        // 起始位置是空格，结束位置是=号
                        var title:String = String(titleItem[..<titleItem.firstIndex(of: "=")!])
                        title = title.replacingOccurrences(of: "var ", with: "")
                        array.removeFirst(4)
                        // 获取结尾位置
                        let index = array.firstIndex(of: "\(title)_ed=1")
                        // 删除结尾后的所有数据
                        let newArr = array[..<index!]
                        //此处获取的顺序是从小到大，与首页的从大到小相反
                        let newArr1 = newArr.reversed()
                        for item in newArr1{
                            // 从数组中提取出数据
                            var itemStr:String = String(item) as String
                            itemStr = itemStr.replacingOccurrences(of: "\"", with: "")
                            itemStr = String(itemStr[itemStr.firstIndex(of: "=")!...])
                            itemStr.removeFirst()
                            let serial = SerialModel.init()
                            let valueArr = itemStr.split(separator: ",")
                            print(valueArr)
                            if valueArr.count<3{
                             serial.name = String(valueArr.last!.replacingOccurrences(of: "%", with: "\\"))
                                serial.name = serial.name.unicodeToUtf8()
                                serial.playerUrl = ""
                            }else{
                                //编码错误,需要转换
                                serial.name = String(valueArr[2].replacingOccurrences(of: "%", with: "\\"))
                                serial.name = serial.name.unicodeToUtf8()
                                serial.playerUrl = checkUrl(urlStr: String(valueArr[0]), domainUrlStr: baseUrl)
                            }
                            videoModel.serialArr.append(serial)
                        }
                    } catch {
                       print("获取js内容失败")
                    }
                    recommendTitleXpath = "/html/body/div[3]/div[6]/div/ul/li/a/@title"
                    recommendImgXpath = "/html/body/div[3]/div[6]/div/ul/li/a/div[1]/img/@data-original"
                    recommendUrlXpath = "/html/body/div[3]/div[6]/div/ul/li/a/@href"
                }
            } else if website == .laikuaibo {
                // 获取视频详情
                let playerUrlNodeArr = jiDoc?.xPath("//*[@id=\"cms_player\"]/script[1]")
                if playerUrlNodeArr!.count > 0 {
                    var playerUrl = playerUrlNodeArr![0].content
                    playerUrl = playerUrl?.replacingOccurrences(of: "var cms_player = ", with: "")
                    playerUrl = playerUrl?.replacingOccurrences(of: ";", with: "")
                    let dic = Dictionary<String, String>.init().stringValueDic(playerUrl!)
                    let urlStr: String = "https://www.bfq168.com/m3u8.php?url=" + (dic!["url"] as! String)
                    videoModel.videoUrl = urlStr
                    
                    //TODO:获取剧集信息
                    //        标题
                    let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[6]/ul/li/a")
                    //        详情
                    let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[1]/div[6]/ul/li/a/@href")
                    for (index, _) in serialTitleNodeArr!.enumerated() {
                        let serialModel = SerialModel.init()
                        serialModel.name = serialTitleNodeArr![index].content!
                        serialModel.detailUrl = checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
                        videoModel.serialArr.append(serialModel)
                    }
                    recommendTitleXpath = "/html/body/div[1]/ul[1]/li/h2/a"
                    recommendUrlXpath = "/html/body/div[1]/ul[1]/li/p/a/@href"
                    recommendImgXpath = "/html/body/div[1]/ul[1]/li/p/a/img/@data-original"
                    recommendUpdateXpath = "/html/body/div[1]/ul[1]/li/p/a/span"
                }
            }else {
//                备注，视频获取地址的js逻辑
                /*
                if ($('#playbox').length>0){
                        var vid = $('#playbox').attr('data-vid');
                        var gf = $('#playbox').attr('data-gf');
                        if (gf=='1'){
                            $.post('http://tup.yhdm.so/playgf.php',{vid:vid},function(data){
                                $('#playbox').html(data);
                            });
                        }else
                            playit(vid);
                    }
 */
                let vidXpath = "//*[@id=\"playbox\"]/@data-vid"
                let gfXpath = "//*[@id=\"playbox\"]/@data-gf"
                let vidNodeArr = jiDoc?.xPath(vidXpath)
                let gfNodeArr = jiDoc?.xPath(gfXpath)
                var vid = vidNodeArr![0].content
                let gf = gfNodeArr![0].content
                if gf == "1" {
                }else{
                    vid = vid?.replacingOccurrences(of: "$mp4", with: "")
                    videoModel.videoUrl = vid!
                }
                // 获取剧集信息
                //        标题
                let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[7]/div[2]/ul/li/a")
                //        详情
                let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[7]/div[2]/ul/li/a/@href")
                for (index, _) in serialTitleNodeArr!.enumerated() {
                    let serialModel = SerialModel.init()
                    serialModel.name = serialTitleNodeArr![index].content!
                    serialModel.detailUrl = checkUrl(urlStr: serialUrlNodeArr![index].content!, domainUrlStr: baseUrl)
                    videoModel.serialArr.append(serialModel)
                }
                
                recommendTitleXpath = "/html/body/div[9]/div[2]/ul/li/a/img/@alt"
                recommendUrlXpath = "/html/body/div[9]/div[2]/ul/li/p[1]/a/@href"
                recommendImgXpath = "/html/body/div[9]/div[2]/ul/li/a/img/@src"
            }
            // 获取推荐视频
            let recommendTitleNodeArr = jiDoc?.xPath(recommendTitleXpath)
            let recommendUrlNodeArr = jiDoc?.xPath(recommendUrlXpath)
            let recommendImgNodeArr = jiDoc?.xPath(recommendImgXpath)
            let recommendUPdateNodeArr = jiDoc?.xPath(recommendUpdateXpath)
            if recommendTitleNodeArr!.count>0 {
                for (index,item) in recommendTitleNodeArr!.enumerated() {
                    var model = VideoModel.init()
                    model.name = item.content
                    let imgPic: String = recommendImgNodeArr![index].content!
                    model.picUrl = checkUrl(urlStr: imgPic, domainUrlStr: baseUrl)
                    let recommandUrlStr: String = recommendUrlNodeArr![index].content!
                    model.detailUrl = checkUrl(urlStr: recommandUrlStr, domainUrlStr: baseUrl)
                    if website == .laikuaibo {
                        model.num = recommendUPdateNodeArr![index].content!
                    }
                    model.num = ""
                    model.type = 3
                    model.webType = website.rawValue
                    videoModel.videoArr.append(model)
                }
            }
            success(videoModel)
        }
    }
}
