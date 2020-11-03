//
//  NetVideoViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/3.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class NetVideoDetailViewController: BaseViewController {

    var videoModel:VideoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getLkbDetailData()
    }
    
    // 获取详情数据
    func getLkbDetailData() {
        DataManager.init().getLkbVideoDetailData(urlStr: (videoModel?.detailUrl)!) { (videoModel,videoArr) in
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
