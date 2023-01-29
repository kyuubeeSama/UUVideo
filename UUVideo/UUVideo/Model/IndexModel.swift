//
//  IndexModel.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/29.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import HandyJSON

struct IndexModel: HandyJSON {
    // 标题
    var title = ""
    // 类型 1.视频站
    var type = 0
    // 视频站类型
    var webType:websiteType = .halihali
}
