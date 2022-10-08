//
//  RightViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/21.
//  Copyright © 2020 qykj. All rights reserved.
//  单独的推荐视频界面，暂时无用

import UIKit

class RightViewController: BaseViewController {
    var cellItemSelected:((_ indexPath:IndexPath)->())?
    var listArr:[ListModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.listArr = listArr
    }
        
    // 使用tableview。列表展示推荐视频
    lazy var collectionView: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collectionView = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalTo(375)
        }
        collectionView.cellItemSelected = { indexPath in
            // cell点击，跳转到视频详情
            if self.cellItemSelected != nil{
                self.cellItemSelected!(indexPath)
            }
        }
        return collectionView
    }()
    
}
