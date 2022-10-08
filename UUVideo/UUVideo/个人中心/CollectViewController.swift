//
//  CollectViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2021/4/25.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit

class CollectViewController: BaseViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Tool.isPhone() {
            getCollectData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if Tool.isPhone() {
            getCollectData()
        }
    }
    
    func getCollectData(){
        let listModel = SqlTool.init().getCollect()
        mainCollect.listArr = [listModel]
    }
    
    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr![indexPath.section]
            //TODO:收藏的话，进入视频详情界面
            let VC = NetVideoDetailViewController.init()
            let videoModel = listModel.list[indexPath.row]
            VC.videoModel = videoModel
            self.navigationController?.pushViewController(VC, animated: true)
        }
        mainCollection.emptyDataSetView { emptyView in
            emptyView.detailLabelString(NSAttributedString.init(string: "快去收藏喜欢的内容吧")).image(UIImage.init(named: "emptyimg"))
        }
        return mainCollection
    }()
}
