//
//  UserViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/16.
//  Copyright © 2020 qykj. All rights reserved.
//  个人中心界面


import UIKit

class UserViewController: BaseViewController {

    var listArr: [String] = ["收藏", "历史记录"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.yellow
    }

    //获取浏览记录和收藏
    func getData() {
        collectionView.reloadData()
    }
    //TODO:重做个人中心页面
    // collectionview 2个section，一个section显示浏览记录 一个section显示收藏列表
    // 每个section最多不超过3行
    // section上有查看更多按钮，进入查看更多列表
    lazy var collectionView: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collectionView = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(self.view.snp.left)
            if Tool.isPhone() {
                make.width.equalTo(self.view.frame.size.width)
            }else{
                make.width.equalTo(375)
            }
        }
        // 点击具体的cell
        collectionView.cellItemSelected = { indexPath in

        }
        // 查看更多
        collectionView.headerRightClicked = { indexPath in

        }
        return collectionView
    }()
}
