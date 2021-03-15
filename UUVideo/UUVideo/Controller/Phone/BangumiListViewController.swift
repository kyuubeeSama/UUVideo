//
//  BangumiListViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2021/3/15.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit
import JXSegmentedView

class BangumiListViewController: BaseViewController,JXSegmentedListContainerViewListDelegate {
    
    func listView() -> UIView {
        return view
    }
    
    var index:Int?
    var listArr:[VideoModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getData()
    }
    
    // 获取数据
    func getData() {
        let dataManager = DataManager.init()
        self.view.makeToastActivity(.center)
        DispatchQueue.global().async { [self] in
            dataManager.getBangumiData(dayIndex: index!) { (dataArr) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    let model = ListModel.init()
                    model.title = ""
                    model.list = dataArr
                    mainCollection.listArr = [model]
                }
            } failure: { (error) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.makeToast("获取内容失败")
                }
                print(error)
            }
        }
    }
    
    // 创建列表
    lazy var mainCollection: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(collection)
        collection.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
        
        collection.cellItemSelected = { indexPath in
            let listModel = collection.listArr![indexPath.section]
            let VC = WebVideoPlayerViewController.init()
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
