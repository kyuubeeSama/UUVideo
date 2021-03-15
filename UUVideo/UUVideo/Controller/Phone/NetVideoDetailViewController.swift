//
//  NetVideoViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/3.
//  Copyright © 2020 qykj. All rights reserved.
//  视频详情界面

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
        self.view.makeToastActivity(.center)
        DispatchQueue.global().async { [self] in
            DataManager.init().getLkbVideoInfoData(urlStr: (videoModel?.detailUrl)!) { (videoModel) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.mainCollect.model = videoModel
                }
            }
        }
    }

    lazy var mainCollect: NetVideoDetailCollectionView = {
        let layout = EqualSpaceFlowLayout(AlignType.left,20.0)
        let mainCollection = NetVideoDetailCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        mainCollection.cellItemSelected = { indexPath in
            if indexPath.section == 1{
                // 剧集
                let VC = NetVideoPlayerViewController.init()
                VC.model = mainCollection.model
                VC.index = indexPath.row
                self.navigationController?.pushViewController(VC, animated: true)
            }else{
//                视频
                let model = mainCollection.model!.videoArr![indexPath.row]
                let VC = NetVideoDetailViewController.init()
                VC.videoModel = model
                self.navigationController?.pushViewController(VC, animated: true)
            }
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