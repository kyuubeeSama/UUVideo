//
//  BangumiViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/17.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import SnapKit
class BangumiViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.chooseView.index = 0
    }
    
    // 头部时间，下面是tableview视频列表
    lazy var chooseView: CategoryChooseView = {
        let chooseView = CategoryChooseView.init(frame: CGRect(x: 0, y: top_height, width: screenW, height: 40))
        self.view.addSubview(chooseView)
        let config = CategoryChooseConfig.init()
        config.listArr = ["周一","周二","周三","周四","周五","周六","周日"]
        config.backColor = .white
        chooseView.config = config
        chooseView.chooseBlock = { index in
            print(index)
        }
        return chooseView
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
