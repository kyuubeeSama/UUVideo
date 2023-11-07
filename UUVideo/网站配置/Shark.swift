//
// Created by Galaxy on 2023/11/7.
// Copyright (c) 2023 qykj. All rights reserved.
//
import Foundation
import Ji
import ReactiveCocoa

class Shark: WebsiteBaseModel {
    override init() {
        super.init()
        websiteName = "鲨鱼资源"
        webUrlStr = "http://sybyapi.com/"
        valueArr = ["1", "2", "3", "20", "22", "23", "24", "25", "26", "27", "28", "31"]
    }
    private func changeArray(array: [CaiJiModel]) -> [VideoModel] {
        var videoArr: [VideoModel] = []
        for item in array {
            var model = VideoModel.init()
            model.name = item.vod_name
            model.webType = websiteType.shark.rawValue
            let detailUrl: String = "detail?id=\(item.vod_id)"
            model.detailUrl = Tool.checkUrl(urlStr: detailUrl, domainUrlStr: webUrlStr)
            let picUrl: String = item.vod_pic
            model.picUrl = Tool.checkUrl(urlStr: picUrl, domainUrlStr: webUrlStr)
            model.videoUrl = item.vod_play_url.replacingOccurrences(of: "在线播放$", with: "")
            model.num = ""
            model.type = 3
            videoArr.append(model)
        }
        return videoArr
    }
    override func getIndexData() -> [ListModel] {
        let titleArr = ["国产情色", "日本无码", "AV明星", "中文字幕", "成人动漫", "欧美情色", "国模私拍", "长腿丝袜", "邻家人妻", "韩国伦理", "香港伦理", "精品推荐"]
        var resultArr: [ListModel] = []
        for _ in titleArr {
            resultArr.append(ListModel.init())
        }
        let semaphore = DispatchSemaphore(value: 0)
        let group = DispatchGroup()
        for (index, item) in valueArr.enumerated() {
            DispatchQueue.global().async(group: group, qos: .default) {
                group.enter()
                let listModel = ListModel.init()
                listModel.title = titleArr[index]
                listModel.more = true
                NetManager().element { element in
                    element.url = "https://shayuapi.com/api.php/provide/vod/at/json/"
                    element.parameters = [
                        "ac": "detail",
                        "t": item,
                        "pg": 1
                    ]
                }
                .toast(toast: { toast in
                    toast.show = false
                })
                .request().dealSucc { resStr in
                    let resultArray = [CaiJiModel].deserialize(from: resStr, designatedPath: "list")!
                    let array: [CaiJiModel] = resultArray.map({ $0! })
                    listModel.list.append(contentsOf: self.changeArray(array: array))
                    resultArr[index] = listModel
                    group.leave()
                }
                .makeEnd()
            }
        }
        group.notify(queue: DispatchQueue.global()) {
            semaphore.signal()
        }
        semaphore.wait()
        return resultArr
    }
    override func getVideoList(videoTypeIndex: Int, category: (area: String, year: String, videoCategory: String), pageNum: Int) -> [ListModel] {
        let videoType = valueArr[videoTypeIndex]
        let listModel = ListModel.init()
        let semaphore = DispatchSemaphore(value: 0)
        NetManager().element { element in
            element.url = "https://shayuapi.com/api.php/provide/vod/at/json/"
            element.parameters = [
                "ac": "detail",
                "t": videoType,
                "pg": 1
            ]
        }
        .toast(toast: { toast in
            toast.show = false
        })
        .request().dealSucc { resStr in
            let resultArray = [CaiJiModel].deserialize(from: resStr, designatedPath: "list")!
            let array: [CaiJiModel] = resultArray.map({ $0! })
            listModel.list.append(contentsOf: self.changeArray(array: array))
            semaphore.signal()
        }
        .makeEnd()
        semaphore.wait()
        return [listModel]
    }
    override func getVideoCategory(videoTypeIndex: Int) -> [CategoryListModel] {
        []
    }
    override func getVideoDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
        let urlDic = Tool.getKeyValueFromUrl(urlStr: urlStr)
        var videoModel = VideoModel.init()
        videoModel.detailUrl = urlStr
        let semaphore = DispatchSemaphore(value: 0)
        var boolResult = true
        NetManager().element { element in
            element.url = "https://shayuapi.com/api.php/provide/vod/at/json/"
            element.parameters = [
                "ac": "detail",
                "ids": urlDic["id"] ?? ""
            ]
        }
        .toast(toast: { toast in
            toast.show = false
        })
        .request().dealSucc { resStr in
            let resultArray = [CaiJiModel].deserialize(from: resStr, designatedPath: "list")!
            let array: [CaiJiModel] = resultArray.map({ $0! })
            let videoArr = self.changeArray(array: array)
            if videoArr.isEmpty {
                boolResult = false
            }else{
                videoModel = videoArr[0]
                videoModel.detailUrl = urlStr
                // 获取线路
                let model = CircuitModel.init()
                model.name = "默认线路"
                let serialModel = SerialModel.init()
                serialModel.name = "默认"
                serialModel.detailUrl = urlStr
                model.serialArr.append(serialModel)
                let circuitArr: [CircuitModel] = [model]
                videoModel.circuitArr = circuitArr
                videoModel.serialNum = videoModel.serialArr.count
            }
            semaphore.signal()
        }
        .makeEnd()
        semaphore.wait()
        return (result: boolResult, model: videoModel)
    }
    override func getVideoPlayerDetail(urlStr: String) -> (result: Bool, model: VideoModel) {
        let urlDic = Tool.getKeyValueFromUrl(urlStr: urlStr)
        var videoModel = VideoModel.init()
        videoModel.detailUrl = urlStr
        let semaphore = DispatchSemaphore(value: 0)
        var boolResult = true
        NetManager().element { element in
            element.url = "https://shayuapi.com/api.php/provide/vod/at/json/"
            element.parameters = [
                "ac": "detail",
                "ids": urlDic["id"] ?? ""
            ]
        }
        .toast(toast: { toast in
            toast.show = false
        })
        .request().dealSucc { resStr in
            let resultArray = [CaiJiModel].deserialize(from: resStr, designatedPath: "list")!
            let array: [CaiJiModel] = resultArray.map({ $0! })
            let videoArr = self.changeArray(array: array)
            if videoArr.isEmpty {
                boolResult = false
            }else{
                videoModel = videoArr[0]
                videoModel.detailUrl = urlStr
                // 获取线路
                let model = CircuitModel.init()
                model.name = "默认线路"
                let serialModel = SerialModel.init()
                serialModel.name = "默认"
                serialModel.detailUrl = urlStr
                model.serialArr.append(serialModel)
                let circuitArr: [CircuitModel] = [model]
                videoModel.circuitArr = circuitArr
                videoModel.serialNum = videoModel.serialArr.count
            }
            semaphore.signal()
        }
        .makeEnd()
        semaphore.wait()
        return (result: boolResult, model: videoModel)
    }
    override func getSearchData(pageNum: Int, keyword: String) -> [ListModel] {
        let listModel = ListModel.init()
        listModel.title = "搜索关键字:" + keyword
        listModel.more = false
        listModel.list = []
        let semaphore = DispatchSemaphore(value: 0)
        NetManager().element { element in
            element.url = "https://shayuapi.com/api.php/provide/vod/at/json/"
            element.parameters = [
                "ac": "detail",
                "pg": pageNum,
                "wd": keyword
            ]
        }
        .toast(toast: { toast in
            toast.show = false
        })
        .request().dealSucc { resStr in
            let resultArray = [CaiJiModel].deserialize(from: resStr, designatedPath: "list")!
            let array: [CaiJiModel] = resultArray.map({ $0! })
            listModel.list.append(contentsOf: self.changeArray(array: array))
            semaphore.signal()
        }
        .makeEnd()
        semaphore.wait()
        return [listModel]
    }
}
