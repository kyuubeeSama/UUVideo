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
    var listArr:[[VideoModel]] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dataManager = DataManager.init()
        self.view.makeToastActivity(.center)
        dataManager.getBangumiData { [self] (dataArr) in
            self.view.hideToastActivity()
            listArr = dataArr
            self.chooseView.index = 0
        } failure: { (error) in
            print(error)
        }
    }
    
    // 头部时间，下面是tableview视频列表
    lazy var chooseView: CategoryChooseView = {
        let chooseView = CategoryChooseView.init()
        self.view.addSubview(chooseView)
        chooseView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(top_height);
        }
        chooseView.layoutIfNeeded()
        let config = CategoryChooseConfig.init()
        config.listArr = ["周一","周二","周三","周四","周五","周六","周日"]
        config.backColor = UIColor.init(.dm, light: .white, dark: .black)
        config.titleColor = UIColor.init(.dm, light: .black, dark: .white)
        config.highLightColor = UIColor.init(.dm, light: .white, dark: .black)
        chooseView.config = config
        chooseView.chooseBlock = { index in
            print(index)
            let array = self.listArr[index]
            let listModel = ListModel.init()
            listModel.title = ""
            listModel.list = array
            listModel.more = false
            self.mainCollection.listArr = [listModel]
        }
        return chooseView
    }()
    // 创建列表
    lazy var mainCollection: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(collection)
        collection.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.chooseView.snp.bottom)
        }
        collection.cellItemSelected = { indexPath in
            let listModel = collection.listArr![indexPath.section]
            let VC = NetVideoPlayerViewController.init()
            VC.model = listModel.list![indexPath.row]
            self.navigationController?.pushViewController(VC, animated: true)
        }
        return collection
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
