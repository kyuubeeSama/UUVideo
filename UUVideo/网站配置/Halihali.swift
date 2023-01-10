//
//  Halihali.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/9.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import Ji
import SwiftyJSON
import Alamofire

class Halihali: WebsiteBaseModel, WebsiteProtocol {
    required override init() {
        super.init()
        webUrlStr = "http://halihali12.com/"
        websiteName = "哈哩哈哩"
    }
    func getIndexData() -> [ListModel] {
        let jiDoc = Ji.init(htmlURL: URL.init(string: webUrlStr)!)
        if jiDoc == nil {
            return []
        }
        let divArr = [5, 6, 7, 8]
        let titleArr = ["动漫", "电视剧", "电影", "综艺"]
        var resultArr: [ListModel] = []
        for (index, item) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleXpath = "/html/body/div[2]/div[\(item)]/div[1]/ul/li/a/@title"
            let urlXpath = "/html/body/div[2]/div[\(item)]/div[1]/ul/li/a/@href"
            let imgXpath = "/html/body/div[2]/div[\(item)]/div[1]/ul/li/a/div[1]/img/@data-original"
            let updateXpath = "/html/body/div[2]/div[\(item)]/div[1]/ul/li/a/div[1]/p"
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
                videoModel.webType = 0
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
        let titleXpath = "/html/body/li/a/@title"
        let urlXpath = "/html/body/li/a/@href"
        let imgXpath = "/html/body/li/a/div[1]/img/@data-original"
        let updateXpath = "/html/body/li/a/div[1]"
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
            videoModel.webType = 0
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
            let titleArr = ["按剧情", "按年代", "按地区"]
            for item in 1...3 {
                let chooseArr = ["", "", "js-tongjip "]
                let titleXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a"
                let urlXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a/@href"
                let chooseXpath = "/html/body/div[2]/div[1]/div[2]/dl[\(item)]/dd/a[@class='\(chooseArr[item - 1])on']"
                let titleNodeArr = jiDoc?.xPath(titleXpath)
                let urlNodeArr = jiDoc?.xPath(urlXpath)
                let chooseNodeArr = jiDoc?.xPath(chooseXpath)
                let listModel = CategoryListModel.init()
                listModel.name = titleArr[item - 1]
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
        // 获取视频封面
        let videoPicXpath = "/html/body/div[2]/div[2]/div[1]/img/@data-original"
        let videoPicNodeArr = jiDoc?.xPath(videoPicXpath)
        if videoPicNodeArr!.count > 0 {
            let picurl: String = videoPicNodeArr![0].content!
            videoModel.picUrl = Tool.checkUrl(urlStr: picurl, domainUrlStr: baseUrl)
        }
        //        剧集
        let serialPathXpath = "//*[@id=\"stab_1_71\"]/ul/li/a/@href"
        let serialNameXpath = "//*[@id=\"stab_1_71\"]/ul/li/a"
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
        let titleXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/@title"
        let urlXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/@href"
        let imgXPath = "/html/body/div[2]/div[4]/div[8]/ul/li/a/div[1]/img/@data-original"
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
                model.webType = 0
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
            // 获取剧集
            // http://t.mtyee.com/ne2/s51696.js?1619401415
            // 从js中获取视频信息，组装剧集model
            let jsXPath = "/html/script/@src"
            let jsNodeArr = jiDoc?.xPath(jsXPath)
            let circuitModel = CircuitModel.init()
            if jsNodeArr!.count > 0 {
                // 获取播放地址等内容
                //                    获取js内容
                var jsContent = ""
                do {
                    print(jsNodeArr![0].content!)
                    let data = try Data.init(contentsOf: URL.init(string: jsNodeArr![0].content!)!, options: [])
                    jsContent = String.init(data: data, encoding: .utf8)!
                    var array = jsContent.split(separator: ";")
                    let firstIndex = 0
                    array.removeFirst(firstIndex)
                    let titleItem = array[0]
                    // 起始位置是空格，结束位置是=号
                    var title: String = String(titleItem[..<titleItem.firstIndex(of: "=")!])
                    title = title.replacingOccurrences(of: "var ", with: "")
                    array.removeFirst(4)
                    // 获取结尾位置
                    let index = array.firstIndex(of: "\(title)_ed=1")
                    // 删除结尾后的所有数据
                    let newArr = array[..<index!]
                    //此处获取的顺序是从小到大，与首页的从大到小相反
                    let newArr1 = newArr.reversed()
                    for item in newArr1 {
                        // 从数组中提取出数据
                        var itemStr: String = String(item) as String
                        itemStr = itemStr.replacingOccurrences(of: "\"", with: "")
                        itemStr = String(itemStr[itemStr.firstIndex(of: "=")!...])
                        itemStr.removeFirst()
                        let serial = SerialModel.init()
                        let valueArr = itemStr.split(separator: ",")
                        print(valueArr)
                        if valueArr.count < 3 {
                            serial.name = String(valueArr.last!.replacingOccurrences(of: "%", with: "\\"))
                            serial.name = serial.name.unicodeToUtf8()
                            serial.playerUrl = ""
                        } else {
                            //编码错误,需要转换
                            serial.name = String(valueArr[2].replacingOccurrences(of: "%", with: "\\"))
                            serial.name = serial.name.unicodeToUtf8()
                            serial.playerUrl = Tool.checkUrl(urlStr: String(valueArr[0]), domainUrlStr: baseUrl)
                        }
                        circuitModel.serialArr.append(serial)
                    }
                    videoModel.circuitArr = [circuitModel]
                } catch {
                    return (result: false, model: VideoModel.init())
                }
            }
            // 获取推荐视频
            recommendTitleXpath = "/html/body/div[3]/div[6]/div/ul/li/a/@title"
            recommendImgXpath = "/html/body/div[3]/div[6]/div/ul/li/a/div[1]/img/@data-original"
            recommendUrlXpath = "/html/body/div[3]/div[6]/div/ul/li/a/@href"
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
                    model.webType = 0
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
        let signal = DispatchSemaphore.init(value: 0)
        var resultArr: [ListModel] = []
        AF.request("http://119.29.158.173:9988/ssszz.php", method: .get, parameters: ["q": keyword], encoding: URLEncoding.default).responseData { response in
            switch response.result {
            case .success(let data):
                let jsonStr = String.init(data: data, encoding: .utf8)
                if let videoArr = [VideoModel].deserialize(from: jsonStr) {
                    for var item in videoArr.map({ item in
                        item!
                    }) {
                        item.detailUrl = Tool.checkUrl(urlStr: item.detailUrl, domainUrlStr: baseUrl)
                        item.type = 3
                        item.webType = 0
                        listModel.list.append(item)
                    }
                    resultArr.append(listModel)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            signal.signal()
        }
        signal.wait()
        return resultArr
    }
    // 获取新番数据
    func getBanggumiData(dayIndex: Int) -> [VideoModel] {
        let jiDoc = Ji(htmlURL: URL.init(string: "http://halihali2.com/zhougen/")!)
        if (jiDoc == nil) {
            return []
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
                    model.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: "http://halihali2.com")
                    model.num = update
                    model.type = 4
                    model.picUrl = ""
                    model.webType = 0
                    listArr.append(model)
                }
            }
            return listArr
        }
    }
}
