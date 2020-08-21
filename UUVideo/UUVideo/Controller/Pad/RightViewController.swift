//
//  RightViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/21.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class RightViewController: BaseViewController {
    var dataArr:[[VideoModel]]?
    var cellIitemSelected:((_ indexPath:IndexPath)->())?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let dayArr = ["周一","周二","周三","周四","周五","周六","周日"]
        var collectionArr:[[String:Any]] = []
        for (index,array) in self.dataArr!.enumerated() {
            let dic = ["title":dayArr[index],"list":array] as [String : Any]
            collectionArr.append(dic)
        }
        collectionView.listArr = collectionArr
    }
    
    lazy var collectionView: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: 270, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(collection)
        collection.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(270)
        }
        collection.cellItemSelected = { indexPath in
            // 点击事件
            if(self.cellIitemSelected != nil){
                self.cellIitemSelected!(indexPath)
            }
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
