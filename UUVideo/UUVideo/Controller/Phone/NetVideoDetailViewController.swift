//
//  NetVideoViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/3.
//  Copyright © 2020 qykj. All rights reserved.
//  视频详情界面

import UIKit

class NetVideoDetailViewController: BaseViewController {

    var videoModel: VideoModel?
    let collectBtn = UIButton.init(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getLkbDetailData()
    }

    //TODO:nav上添加收藏按钮
    func addCollectItem(videoModel: VideoModel) {
        // 判断用户是否收藏该视频
        var imageName = "heart"
        if SqlTool.init().isCollect(model: videoModel) {
            imageName = "heart.fill"
        }
        collectBtn.tag = 500
        collectBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        collectBtn.setImage(UIImage.init(systemName: imageName), for: .normal)
        collectBtn.addTarget(self, action: #selector(collectClick), for: .touchUpInside)
        let rightBtnItem = UIBarButtonItem.init(customView: collectBtn)
        navigationItem.rightBarButtonItem = rightBtnItem
    }

    @objc func collectClick() {
        if SqlTool.init().isCollect(model: videoModel!) {
            // 删除收藏
            if SqlTool.init().deleteCollect(model: videoModel!) {
                collectBtn.setImage(UIImage.init(systemName: "heart"), for: .normal)
            } else {
                view.makeToast("操作失败")
            }
        } else {
            // 添加收藏
            if SqlTool.init().saveCollect(model: videoModel!) {
                // 修改bar按钮
                collectBtn.setImage(UIImage.init(systemName: "heart.fill"), for: .normal)
            } else {
                view.makeToast("操作成功")
            }
        }
    }

    // 获取详情数据
    func getLkbDetailData() {
        view.makeToastActivity(.center)
        DispatchQueue.global().async { [self] in
            DataManager.init().getVideoDetailData(urlStr: (videoModel?.detailUrl)!, type: websiteType(rawValue: (self.videoModel?.webType)!)!) { (resultModel) in
                DispatchQueue.main.async {
                    view.hideToastActivity()
                    self.videoModel?.picUrl = resultModel.picUrl
                    self.videoModel?.videoArr = resultModel.videoArr
                    self.videoModel?.serialArr = resultModel.serialArr
                    mainCollect.model = self.videoModel
                    addCollectItem(videoModel: self.videoModel!)
                }
            } failure: { (error) in
                print(error)
            }
        }
    }

    lazy var mainCollect: NetVideoDetailCollectionView = {
        let layout = UICollectionViewLeftAlignedLayout.init()
        let mainCollection = NetVideoDetailCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        mainCollection.cellItemSelected = { indexPath in
            if indexPath.section == 1 {
                // 剧集
                let VC = NetVideoPlayerViewController.init()
                VC.model = self.videoModel
                let serialModel = self.videoModel?.serialArr![indexPath.row]
                VC.model!.serialDetailUrl = serialModel?.detailUrl
                VC.model?.serialIndex = indexPath.row
//                VC.webType = self.webType
                self.navigationController?.pushViewController(VC, animated: true)
            } else if indexPath.section == 2 {
//                视频
                let model = mainCollection.model!.videoArr![indexPath.row]
                let VC = NetVideoDetailViewController.init()
//                VC.webType = self.webType
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
