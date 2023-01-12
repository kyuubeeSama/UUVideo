//
//  CategoryModel.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/10.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class CategoryListModel:NSObject {
    var name:String?
    var list:[CategoryModel] = []
}

class CategoryModel: NSObject {
    var name:String = ""
    var value:String = ""
//    默认未选中
    var ischoose:Bool = false
    
    static func getSakuraCategoryData() -> [CategoryListModel] {
        let titleArr = ["年代","地区","语言","类型"]
        let valueArr = [
            ["2021","2020","2019","2018","2017","2016","2015","2014","2013","2012"],
            ["japan","china","american","england","korea"],
            ["29","30","31","32","33","34"],
            ["66","64","91","70","67","111","83","81","75","74","84","73","72","102","61","69","62","103","85","99","80","119"]
        ]
        let nameArr = [
            ["2021","2020","2019","2018","2017","2016","2015","2014","2013","2012"],
            ["日本","大陆","美国","英国","韩国"],
            ["日语","国语","粤语","英语","汉语","方言"],
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
}
