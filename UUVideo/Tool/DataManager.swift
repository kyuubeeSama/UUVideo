//
//  DataManager.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/18.
//  Copyright © 2020 qykj. All rights reserved.
//

import Foundation
import Ji
class DataManager: NSObject {
    // 获取新番数据
    func getBangumiData(success:@escaping(_ listArr:[[VideoModel]])->(),failure:@escaping(_ error:Error)->()) {
        let jiDoc = Ji(htmlURL: URL.init(string: "https://www.halitv.com/")!)
        //*[@id="bg-time"]/div[2]/ul[1]/li[x]/a/h4  获取标题
        //*[@id="bg-time"]/div[2]/ul[1]/li[x]/a/div/img  获取图片
        //*[@id="bg-time"]/div[2]/ul[1]/li[x]/a  详情地址
        //*[@id="bg-time"]/div[2]/ul[1]/li[1]/p/a  更新信息
        var array:[[VideoModel]] = []
        for j in 1...7{
            var listArr:[VideoModel] = []
            // 获取标题
            let titlePath = "//*[@id=\"bg-time\"]/div[2]/ul[\(j)]/li/a/h4"
            let titleNodeArr = jiDoc?.xPath(titlePath)
            // 获取封面
            let imgPath = "//*[@id=\"bg-time\"]/div[2]/ul[\(j)]/li/a/div/img/@src"
            let imgNodeArr = jiDoc?.xPath(imgPath)
            // 获取详情地址
            let urlPath = "//*[@id=\"bg-time\"]/div[2]/ul[\(j)]/li/a/@href"
            let urlNodeArr = jiDoc?.xPath(urlPath)
            // 获取更新信息
            let updateInfoPath = "//*[@id=\"bg-time\"]/div[2]/ul[\(j)]/li/p/a"
            let updateNodeArr = jiDoc?.xPath(updateInfoPath)
            for (index,_) in titleNodeArr!.enumerated() {
                let titleNode = titleNodeArr![index]
                let urlNode = urlNodeArr![index]
                let updateNode = updateNodeArr![index]
                let imgNode = imgNodeArr![index]
                let model = VideoModel.init()
                model.name = titleNode.content
                model.detailUrl = urlNode.content
                model.picUrl = imgNode.content
                model.type = 4
                model.num = updateNode.content
                listArr.append(model)
                print("周\(j)")
                print("更新信息是\(updateNode.content as Any)")
                print("详情地址是\(urlNode.content as Any)")
                print("图片地址是\(imgNode.content as Any)")
                print("标题是\(titleNode.content as Any)")
            }
            array.append(listArr)
        }
        success(array)
    }
    
    // 获取视频播放界面相关数据
    func getVideoDetailData(urlStr:String,success:@escaping(_ dataDic:[String:Any])->(),failure:@escaping(_ error:Error)->()){
        QYRequestData.shared.getHtmlContent(urlStr: urlStr, params: nil) { (result) in
//            print(result)
//            "url":([\s\S]+?)",
//            获取请求值
            var v:String = Tool.getRegularData(regularExpress: "\"url\":([\\s\\S]+?)\",", content: result)[0]
            v = v.replacingOccurrences(of: "\"url\":", with: "")
            v = v.replacingOccurrences(of: "\",", with: "")
            v = v.replacingOccurrences(of: "\"", with: "")
//            "name":([\s\S]+?)",
//            获取那么属性
            var name:String = Tool.getRegularData(regularExpress: "\"name\":([\\s\\S]+?)\",", content: result)[0]
            name = name.replacingOccurrences(of: "\"name\":", with: "")
            name = name.replacingOccurrences(of: "\",", with: "")
            name = name.replacingOccurrences(of: "\"", with: "")
//            根据这两个参数，请求新页面
            let playerUrlStr = "https://www.halitv.com/api/haliapi.php?v="+v+"&name="+name
            QYRequestData.shared.getHtmlContent(urlStr: playerUrlStr, params: nil) { (playerResult) in
                print(playerResult)
            } failure: { (error) in
                failure(error)
            }

        } failure: { (error) in
            failure(error)
        }
    }
    // 获取哈哩tv数据
    // type 页面类型 1.首页
    func getHaliTVData(urlStr:String,type:NSInteger,success:@escaping(_ listData:[ListModel])->()){
        // 获取首页数据
        let jiDoc = Ji(htmlURL: URL.init(string: "https://www.halitv.com/")!)
        // 详情地址
//        /html/body/div[3]/div[2]/div/ul/li[1]/a
        //封面
//        /html/body/div[3]/div[2]/div/ul/li[1]/a/img
        // 更新信息
//        /html/body/div[3]/div[2]/div/ul/li[1]/a/span[3]
        // 标题
//        /html/body/div[3]/div[2]/div/ul/li[1]/div/h5/a
        let divArr = [2,5,7,9,11]
        let titleArr = ["热播推荐","tv动画","剧场版","电影","剧集"]
        var resultArr:[ListModel] = []
        for (index,value) in divArr.enumerated() {
            let listModel = ListModel.init()
            let titleNodeArr = jiDoc?.xPath("/html/body/div[3]/div[\(value)]/div/ul/li/div/h5/a")
            let urlNodeArr = jiDoc?.xPath("/html/body/div[3]/div[\(value)]/div/ul/li/a/@href")
            let imgNodeArr = jiDoc?.xPath("/html/body/div[3]/div[\(value)]/div/ul/li/a/img/@data-original")
            let updateNodeArr = jiDoc?.xPath("/html/body/div[3]/div[\(value)]/div/ul/li/a/span[3]")
            listModel.title = titleArr[index]
            if index>0 {
                listModel.more = true
            }else{
                listModel.more = false
            }
            print("当前分类是\(titleArr[index])")
            listModel.list = []
            for (i,_) in titleNodeArr!.enumerated() {
                let videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content
                videoModel.detailUrl = urlNodeArr![i].content
                videoModel.picUrl = imgNodeArr![i].content
                videoModel.num = updateNodeArr![i].content
                videoModel.type = 3
                listModel.list?.append(videoModel)
            }
            resultArr.append(listModel)
        }
        success(resultArr)
    }
}
