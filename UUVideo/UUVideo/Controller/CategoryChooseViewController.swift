//
//  CategoryChooseViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/15.
//  Copyright © 2020 qykj. All rights reserved.
//  电影类型选择界面

import UIKit

class CategoryChooseViewController: BaseViewController {

    var listArr: [CategoryListModel]?
    var sureBtnReturn: ((_ resultArr: [String]) -> ())?
    var type:websiteType?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainCollect.listArr = listArr
    }

    lazy var mainCollect: VideoCategoryCollectionView = {
        let layout = UICollectionViewLeftAlignedLayout.init()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        let mainCollection = VideoCategoryCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
        }
        mainCollection.cellItemClick = { indexPath in
            if self.type == .sakura{
                for listModel in self.listArr! {
                    for model in listModel.list {
                        model.ischoose = false
                    }
                }
                let model = self.listArr![indexPath.section].list[indexPath.row]
                model.ischoose = true
                mainCollection.reloadData()
            }
        }
        return mainCollection
    }()
    // 底部确认和取消按钮
    lazy var bottomView: CategoryBottomView = {
        let bottomView = CategoryBottomView.init()
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        bottomView.sureBtnBlock = {
            // 将选中的界面添加保存在数组中，并返回上一页
            var valueArr: [String] = []
            for listModel in self.mainCollect.listArr! {
                for categoryModel in listModel.list {
                    if categoryModel.ischoose == true {
                        //            videoCategory videoType area
                        valueArr.append(categoryModel.value)
                    }
                }
            }
            if (self.sureBtnReturn != nil) {
                self.sureBtnReturn!(valueArr)
            }
        }

        return bottomView
    }()
}
