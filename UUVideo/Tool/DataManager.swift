//
//  DataManager.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/18.
//  Copyright © 2020 qykj. All rights reserved.
//

import Foundation
class DataManager: NSObject {
    // 获取新番数据
    func getBangumiData(success:@escaping(_ listArr:[[VideoModel]])->(),failure:@escaping(_ error:Error)->()) {
        QYRequestData.shared.getHtmlContent(urlStr: "https://www.halitv.com/", params: nil) { (result) in
//            print(result)
            var array:[[VideoModel]] = []
            //获取七天的内容
//            layui-tab-item([\s\S]+?)<\/ul>
//            按照顺序表示周一到周日
            let gumiContentArr:[String] = Tool.getRegularData(regularExpress: "layui-tab-item([\\s\\S]+?)<\\/ul>", content: result)
            for item in gumiContentArr{
                var listArr:[VideoModel] = []
                //            <li([\s\S]+?)<\/li>
                //            获取其中一条
                let gumiArr:[String] = Tool.getRegularData(regularExpress: "<li([\\s\\S]+?)<\\/li>", content: item)
                for gumiStr in gumiArr {
                    //            src="([\s\S]+?)"
                    //            封面
                    var picStr:String = Tool.getRegularData(regularExpress: "src=\"([\\s\\S]+?)\"", content: gumiStr)[0]
                    picStr = picStr.replacingOccurrences(of: "src=\"", with: "")
                    picStr = picStr.replacingOccurrences(of: "\"", with: "")
                    if !picStr.contains("https") {
                        // 不包含https
                        picStr = "https:"+picStr
                    }
                    //            alt="([\s\S]+?)"
                    //            标题
                    var titleStr:String = Tool.getRegularData(regularExpress: "alt=\"([\\s\\S]+?)\"", content: gumiStr)[0]
                    titleStr = titleStr.replacingOccurrences(of: "alt=\"", with: "")
                    titleStr = titleStr.replacingOccurrences(of: "\"", with: "")
                    //            更新至([\s\S]+?)集
                    //            最新集
                    let numStr:String
                    let numArr:[String] = Tool.getRegularData(regularExpress: "更新至([\\s\\S]+?)集", content: gumiStr)
                    if numArr.count>0 {
                        numStr = numArr[0]
                    }else{
                        numStr = Tool.getRegularData(regularExpress: "第([\\s\\S]+?)集", content: gumiStr)[0]
                    }
                    //            href="([\s\S]+?)"
                    //            视频详情页
                    var urlStr:String = Tool.getRegularData(regularExpress: "href=\"([\\s\\S]+?)\"", content: gumiStr)[0]
                    urlStr = urlStr.replacingOccurrences(of: "href=\"", with: "")
                    urlStr = urlStr.replacingOccurrences(of: "\"", with: "")
                    print("封面是\(picStr),标题是\(titleStr),最新集\(numStr),详情\(urlStr)")
                    let model = VideoModel.init()
                    model.name = titleStr
                    model.detailUrl = urlStr
                    model.picUrl = picStr
                    model.type = 4
                    model.num = numStr
                    listArr.append(model)
                }
                array.append(listArr)
            }
            success(array)
        } failure: { (error) in
            print(error)
        }
    }
    // 获取视频播放界面相关数据
    func getVideoDetailData(urlStr:String,success:@escaping(_ dataDic:[String:Any])->(),failure:@escaping(_ error:Error)->()){
        QYRequestData.shared.getHtmlContent(urlStr: urlStr, params: nil) { (result) in
            print(result)
        } failure: { (error) in
            failure(error)
        }
    }
}
