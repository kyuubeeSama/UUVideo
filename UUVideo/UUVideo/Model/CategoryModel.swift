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
    var list:[CategoryModel]?
}

class CategoryModel: NSObject {
    var name:String?
    var value:String?
//    默认未选中
    var ischoose:Bool? = false
}
