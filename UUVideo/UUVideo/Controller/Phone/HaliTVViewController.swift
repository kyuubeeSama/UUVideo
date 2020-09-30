//
//  HaliTVViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/9/30.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class HaliTVViewController: BaseViewController {

    var listArr:[ListModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 获取哈哩tv数据
        self.getVideoData()
    }
    
    func getVideoData(){
        DataManager.init().getHaliTVData(urlStr: "https://www.halitv.com/", type: 1) { (resultArr) in
            self.mainCollect.listArr = resultArr
        }
    }
    
    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr![indexPath.section]
            let VC = NetVideoPlayerViewController.init()
            VC.model = listModel.list![indexPath.row]
            self.navigationController?.pushViewController(VC, animated: true)
        }
        mainCollection.headerRightClicked = { indexPath in
             // 根据选中的行跳转对应页面
            
        }
        return mainCollection
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
