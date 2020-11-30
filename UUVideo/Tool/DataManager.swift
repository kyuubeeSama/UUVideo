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
            }
            array.append(listArr)
        }
        success(array)
    }
    
    /// 获取视频播放界面相关数据
    /// - Parameters:
    ///   - urlStr: 视频地址
    ///   - success: 成功返回
    /// - Returns: listArr:[videoModel]
    func getVideoDetailData(urlStr:String,success:@escaping(_ listArr:[VideoModel])->()){
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        var array:[VideoModel] = []
        // 标题
        let titleXPath = "/html/body/div[2]/div[2]/div/div[6]/div[2]/ul/li/div/h5/a"
        let titleNodeArr = jiDoc?.xPath(titleXPath)
//        详情
        let urlXPath = "/html/body/div[2]/div[2]/div/div[6]/div[2]/ul/li/div/h5/a/@href"
        let urlNodeArr = jiDoc?.xPath(urlXPath)
//        封面
        let imgXPath = "/html/body/div[2]/div[2]/div/div[6]/div[2]/ul/li/a/img/@src"
        let imgNodeArr = jiDoc?.xPath(imgXPath)
//        更新信息
        let updateInfoXPath = "/html/body/div[2]/div[2]/div/div[6]/div[2]/ul/li/a/span[3]"
        let updateNodeArr = jiDoc?.xPath(updateInfoXPath)
        if titleNodeArr!.count>0 {
            for (index,titleNode) in titleNodeArr!.enumerated() {
                let urlNode = urlNodeArr![index]
                let imgNode = imgNodeArr![index]
                let updateNode = updateNodeArr![index]
                print("标提是\(titleNode.content) 图片是\(imgNode.content) 详情是\(urlNode.content) 更新信息是\(updateNode.content)")
                let model = VideoModel.init()
                model.name = titleNode.content
                model.picUrl = imgNode.content
                model.detailUrl = urlNode.content
                model.num = updateNode.content
                model.type = 3
                array.append(model)
            }
        }
        success(array)
    }
    
    // 获取哈哩tv数据
    // type 页面类型 1.首页  2.具体分类页面
    func getHaliTVData(urlStr:String,type:Int,success:@escaping(_ listData:[ListModel],_ page:Int)->()){
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if type == 1 {
            // 获取首页数据
            // 详情地址
            //        /html/body/div[3]/div[2]/div/ul/li[1]/a
            //封面
            //        /html/body/div[3]/div[2]/div/ul/li[1]/a/img
            // 更新信息
            //        /html/body/div[3]/div[2]/div/ul/li[1]/a/span[3]
            // 标题
            //        /html/body/div[3]/div[2]/div/ul/li[1]/div/h5/a
            let divArr = [2,6,8,10,12]
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
                listModel.list = []
                // TODO:可能获取数据失败
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
            success(resultArr,1)
        }else{
            // 获取是视频列表
            // 标题
            //*[@id="content"]/li[1]/div/h5/a
            // 详情地址
            //*[@id="content"]/li[1]/a/@href
            // 封面
            //*[@id="content"]/li[1]/a/img/@data-original
            // 更新信息
            //*[@id="content"]/li[1]/a/span[3]
            // 尾页
            //*[@id="long-page"]/ul/li[12]/a/@data  p-20
            let listModel = ListModel.init()
            let titleNodeArr = jiDoc?.xPath("//*[@id=\"content\"]/li/div/h5/a")
            let urlNodeArr = jiDoc?.xPath("//*[@id=\"content\"]/li/a/@href")
            let imgNodeArr = jiDoc?.xPath("//*[@id=\"content\"]/li/a/img/@data-original")
            let updateNodeArr = jiDoc?.xPath("//*[@id=\"content\"]/li/a/span[3]")
            listModel.title = ""
            listModel.more = false
            listModel.list = []
            for (i,_) in titleNodeArr!.enumerated() {
                let videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content
                videoModel.detailUrl = urlNodeArr![i].content
                videoModel.picUrl = imgNodeArr![i].content
                videoModel.num = updateNodeArr![i].content
                videoModel.type = 3
                listModel.list?.append(videoModel)
                //                print("封面是\(videoModel.picUrl),标提是\(videoModel.name) 更新信息是\(videoModel.num), 详情地址是\(videoModel.detailUrl)")
            }
            // 尾页
            //FIXME:此处尾页获取有问题
            let pageNodeArr = jiDoc?.xPath("//*[@id=\"long-page\"]/ul/li[last()]/a/@data")
            var pageNumInt = 1
            if pageNodeArr!.count>0 {
                var pageNumStr = pageNodeArr?.first?.content
                pageNumStr = pageNumStr?.replacingOccurrences(of: "p-", with: "")
                //            print("尾页页码是\(pageNum)")
                pageNumInt = Int(pageNumStr!)!
            }
            success([listModel],pageNumInt)
        }
    }
    
    // 获取哈哩tv分类信息
    func getHaliTVCategoryData(urlStr:String,success:@escaping(_ categoryData:[CategoryListModel])->()){
        // 最后li需要去除第一行 最后ul只获取1，2，3
        //        /html/body/div[2]/div/div[1]/div[2]/ul[1]/li/a
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        // 获取标题
        // 获取value
        var listArr:[CategoryListModel]=[]
        let titleArr:[String] = ["按分类","按类型","按地区"]
        let valueArr:[String] = ["id-","mcid-","area-"]
        for item in 1...3 {
            let titleNodeArr = jiDoc?.xPath("/html/body/div[2]/div/div[1]/div[2]/ul[\(item)]/li/a/@title")
            let valueNodeArr = jiDoc?.xPath("/html/body/div[2]/div/div[1]/div[2]/ul[\(item)]/li/a/@data")
            let chooseNodeArr = jiDoc?.xPath("/html/body/div[2]/div/div[1]/div[2]/ul[\(item)]/li/a[@class='active']")
            let listModel = CategoryListModel.init()
            listModel.name = titleArr[item-1]
            listModel.list = []
            for (index,_) in titleNodeArr!.enumerated() {
                let categoryModel = CategoryModel.init()
                let name = titleNodeArr![index].content
                categoryModel.name = name
                for chooseNode in chooseNodeArr! {
                    if name == chooseNode.content {
                        categoryModel.ischoose = true
                    }
                }
                if item == 2 {
                    // 按类型，需要使用id拼接
                    var valueStr = valueNodeArr![index].content
                    valueStr = valueStr?.replacingOccurrences(of: valueArr[item-1], with: "")
                    categoryModel.value = valueStr
                }else{
                    // 按分类和按地区，使用拼音拼接
                    var valueStr = titleNodeArr![index].content
                    valueStr = valueStr!.transformToPinYin(yinbiao: false)
                    categoryModel.value = valueStr
                }
                listModel.list?.append(categoryModel)
            }
            listArr.append(listModel)
        }
        success(listArr)
    }
    
    // 搜索数据
    func getHaliTVSearchData(urlStr:String,keyword:String,success:@escaping(_ searchData:[ListModel])->()){
        let newUrlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let jiDoc = Ji(htmlURL: URL.init(string: newUrlStr)!)
        // 获取当前选中的状态，如果是视频，继续判断，否则返回空
//        /html/body/div[2]/div/div[1]/div/ul/li[2]/a/@class
        let activeNodeArr = jiDoc?.xPath("/html/body/div[2]/div/div[1]/div/ul/li[2]/a/@class")
//        /html/body/div[2]/div/div[1]/div/ul/li[3]/a/@class
        if activeNodeArr![0].content == "active" {
            //            标题
            let titleNodeArr = jiDoc?.xPath("//*[@id=\"content\"]/div/div[1]/a/@title")
            //            详情
            let detailNodeArr = jiDoc?.xPath("//*[@id=\"content\"]/div/div[1]/a/@href")
            //            状态
            let updateNodeArr = jiDoc?.xPath("//*[@id=\"content\"]/div/div[2]/ul/li[3]/text()")
            //            封面
            let imgNodeArr = jiDoc?.xPath("//*[@id=\"content\"]/div/div[1]/a/@data-original")
            let listModel = ListModel.init()
            listModel.title = "搜索关键字:"+keyword
            listModel.more = false
            listModel.list = []
            for (index,_) in titleNodeArr!.enumerated(){
                let videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![index].content
                videoModel.detailUrl = detailNodeArr![index].content
                videoModel.num = updateNodeArr![index].content
                videoModel.picUrl = imgNodeArr![index].content
                videoModel.type = 3
                listModel.list?.append(videoModel)
            }
            success([listModel])
        }else{
            success([])
        }
    }
    
    //获取来快播
    func getLkbData(urlStr:String,type:Int,success:@escaping(_ listData:[ListModel],_ page:Int)->()){
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        if type == 1 {
            // 获取首页数据
            // 详情地址  不带域名
//            /html/body/div[3]/div[2]/div[1]/ul/li[1]/p/a/@href
            //封面  不带域名
//            /html/body/div[3]/div[2]/div[1]/ul/li[1]/p/a/img/@src
            // 更新信息
//            /html/body/div[3]/div[2]/div[1]/ul/li[1]/p/a/span
            // 标题
//            /html/body/div[3]/div[2]/div[1]/ul/li[1]/h2/a
            let divArr = [3,5,7,9,0]
            let titleArr = ["电影","剧集","综艺","动漫","伦理"]
            var resultArr:[ListModel] = []
            for (index,value) in divArr.enumerated() {
                let listModel = ListModel.init()
                let titleNodeArr = jiDoc?.xPath("/html/body/div[\(value)]/div[2]/div[1]/ul/li/h2/a")
                let urlNodeArr = jiDoc?.xPath("/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/@href")
                let imgNodeArr = jiDoc?.xPath("/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/img/@data-original")
                let updateNodeArr = jiDoc?.xPath("/html/body/div[\(value)]/div[2]/div[1]/ul/li/p/a/span")
                listModel.title = titleArr[index]
                listModel.more = true
                listModel.list = []
                if index<4 {
                    for (i,_) in titleNodeArr!.enumerated() {
                        let videoModel = VideoModel.init()
                        videoModel.name = titleNodeArr![i].content
                        videoModel.detailUrl = urlStr+urlNodeArr![i].content!
                        videoModel.picUrl = urlStr+imgNodeArr![i].content!
                        videoModel.num = updateNodeArr![i].content
                        videoModel.type = 3
                        listModel.list?.append(videoModel)
                    }
                }
                resultArr.append(listModel)
            }
            success(resultArr,1)
        }else{
            // 获取是视频列表
            let listModel = ListModel.init()
            let titleNodeArr = jiDoc?.xPath("/html/body/div[1]/ul/li/h2/a")
            let urlNodeArr = jiDoc?.xPath("/html/body/div[1]/ul/li/p/a/@href")
            let imgNodeArr = jiDoc?.xPath("/html/body/div[1]/ul/li/p/a/img/@data-original")
            let updateNodeArr = jiDoc?.xPath("/html/body/div[1]/ul/li/p/a/span")
            listModel.title = ""
            listModel.more = false
            listModel.list = []
            for (i,_) in titleNodeArr!.enumerated() {
                let videoModel = VideoModel.init()
                videoModel.name = titleNodeArr![i].content
                videoModel.detailUrl = "https://www.laikuaibo.com/"+urlNodeArr![i].content!
                videoModel.picUrl = "https://www.laikuaibo.com/"+imgNodeArr![i].content!
                videoModel.num = updateNodeArr![i].content
                videoModel.type = 3
                listModel.list?.append(videoModel)
                //                print("封面是\(videoModel.picUrl),标提是\(videoModel.name) 更新信息是\(videoModel.num), 详情地址是\(videoModel.detailUrl)")
            }
            // 尾页
            //FIXME:此处尾页获取有问题
            let pageNodeArr = jiDoc?.xPath("//*[@id=\"long-page\"]/ul/li[last()]/a/@data")
            var pageNumInt = 1
            if pageNodeArr!.count>0 {
                var pageNumStr = pageNodeArr?.first?.content
                pageNumStr = pageNumStr?.replacingOccurrences(of: "p-", with: "")
                //            print("尾页页码是\(pageNum)")
                pageNumInt = Int(pageNumStr!)!
            }
            success([listModel],pageNumInt)
        }
    }
    
    // 获取来快播分类信息
    func getLkbCategoryData(urlStr:String,success:@escaping(_ categoryData:[CategoryListModel])->()){
        // 最后li需要去除第一行 最后ul只获取1，2，3
        //        /html/body/div[2]/div/div[1]/div[2]/ul[1]/li/a
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        // 获取标题
        // 获取value
        var listArr:[CategoryListModel]=[]
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
    
    // 获取视频详情界面
    func getLkbVideoInfoData(urlStr:String,success:@escaping(_ VideoModel:VideoModel)->()){
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        let videoModel = VideoModel.init()
        videoModel.videoArr = []
        videoModel.tagArr = []
        videoModel.serialArr = []
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
//        剧集
//        标题
        let serialTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/div[3]/ul/li/a")
//        详情
        let serialUrlNodeArr = jiDoc?.xPath("/html/body/div[1]/div[3]/ul/li/a/@href")
        for (index,_) in serialTitleNodeArr!.enumerated() {
            let serialModel = SerialModel.init()
            serialModel.name = serialTitleNodeArr![index].content
            serialModel.detailUrl = serialUrlNodeArr![index].content
            videoModel.serialArr?.append(serialModel)
        }
        
//        推荐视频
        let recommendVideoTitleNodeArr = jiDoc?.xPath("/html/body/div[1]/ul[2]/li/h2/a")
        let recommendVideodetailNodeArr = jiDoc?.xPath("/html/body/div[1]/ul[2]/li/h2/a/@href")
        let recommendVideoImgNodeArr = jiDoc?.xPath("/html/body/div[1]/ul[2]/li/p/a/img/@data-original")
        let recommendVideoNumNodeArr = jiDoc?.xPath("/html/body/div[1]/ul[2]/li/p/a/span")
        for (i,_) in recommendVideoTitleNodeArr!.enumerated() {
            let videoModel1 = VideoModel.init()
            videoModel1.name = recommendVideoTitleNodeArr![i].content
            videoModel1.detailUrl = "https://www.laikuaibo.com/"+recommendVideodetailNodeArr![i].content!
            videoModel1.picUrl = "https://www.laikuaibo.com/"+recommendVideoImgNodeArr![i].content!
            videoModel1.num = recommendVideoNumNodeArr![i].content
            videoModel1.type = 3
            videoModel.videoArr?.append(videoModel1)
            //                print("封面是\(videoModel.picUrl),标提是\(videoModel.name) 更新信息是\(videoModel.num), 详情地址是\(videoModel.detailUrl)")
        }
        success(videoModel)
    }
    
    /// 来快播视频播放接口
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
