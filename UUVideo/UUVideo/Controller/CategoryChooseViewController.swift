//
//  CategoryChooseViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/15.
//  Copyright © 2020 qykj. All rights reserved.
//  电影类型选择界面

import UIKit

class CategoryChooseViewController: BaseViewController {

    var listArr:[CategoryListModel]?
    var sureBtnReturn:((_ resultDic:[String:String])->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mainCollect.listArr = listArr
    }
    
    lazy var mainCollect: VideoCategoryCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        let mainCollection = VideoCategoryCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
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
            var valueDic:[String:String] = ["videoCategory":"","videoType":"","area":""]
            for listModel in self.mainCollect.listArr! {
                for categoryModel in listModel.list! {
                    if categoryModel.ischoose == true {
                        //            videoCategory videoType area
                        if categoryModel.name != "全部" {
                            if listModel.name == "按分类" {
                                // 设置到分类
                                valueDic["videoCategory"] = categoryModel.value?.lowercased()
                            }else if listModel.name == "按类型"{
                                valueDic["videoType"] = categoryModel.value
                            }else{
                                valueDic["area"] = categoryModel.value
                            }
                        }
                    }
                }
            }
            if (self.sureBtnReturn != nil) {
                self.sureBtnReturn!(valueDic)
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        bottomView.cancelBtnBlock = {
            // 重置选项为初始选项，返回上一页
            self.dismiss(animated: true, completion: nil)
        }
        
        return bottomView
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
