//
//  NetVideoViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/3.
//  Copyright © 2020 qykj. All rights reserved.
//  视频详情界面

import UIKit
import UICollectionViewLeftAlignedLayout
class NetVideoDetailViewController: BaseViewController {
    var videoModel: VideoModel = VideoModel.init()
    let collectBtn = UIButton.init(type: .custom)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getDetailData()
    }
    //nav上添加收藏按钮
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
        if SqlTool.init().isCollect(model: videoModel) {
            // 删除收藏
            if SqlTool.init().deleteCollect(model: videoModel) {
                collectBtn.setImage(UIImage.init(systemName: "heart"), for: .normal)
            } else {
                view.makeToast("操作失败")
            }
        } else {
            // 添加收藏
            if SqlTool.init().saveCollect(model: videoModel) {
                // 修改bar按钮
                collectBtn.setImage(UIImage.init(systemName: "heart.fill"), for: .normal)
            } else {
                view.makeToast("操作成功")
            }
        }
    }
    // 获取详情数据
    func getDetailData() {
        view.makeToastActivity(.center)
        DispatchQueue.global().async { [self] in
            DataManager.init().getVideoDetailData(urlStr: (videoModel.detailUrl), type: websiteType(rawValue: (videoModel.webType))!) { (resultModel) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.videoModel.picUrl = resultModel.picUrl
                    self.videoModel.videoArr = resultModel.videoArr
                    self.videoModel.serialArr = resultModel.serialArr
                    self.videoModel.serialNum = resultModel.serialNum
                    self.videoModel.circuitArr = resultModel.circuitArr
                    self.mainCollect.model = self.videoModel
                    self.addCollectItem(videoModel: self.videoModel)
                    if resultModel.circuitArr.isEmpty {
                        let alert = UIAlertController.init(title: "提示", message: "当前视频没有剧集", preferredStyle: .alert)
                        let alertAction = UIAlertAction.init(title: "返回上一页", style: .default) { action in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } failure: { (error) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.makeToast("加载失败")
                }
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
            if indexPath.section == self.videoModel.circuitArr.count + 1 {
                //                推荐视频
                let model = mainCollection.model.videoArr[indexPath.row]
                let VC = NetVideoDetailViewController.init()
                VC.videoModel = model
                self.navigationController?.pushViewController(VC, animated: true)
            } else if indexPath.section != 0 {
                let circuitModel = self.videoModel.circuitArr[indexPath.section-1]
                let serialModel = circuitModel.serialArr[indexPath.row]
                if Tool.isPhone() {
                    let VC = NetVideoPlayerViewController.init()
                    VC.model = self.videoModel
                    VC.model.serialDetailUrl = serialModel.detailUrl
                    VC.model.serialIndex = indexPath.row
                    VC.model.circuitIndex = indexPath.section-1
                    VC.reloadFatherVC = {
                        mainCollection.reloadData()
                    }
                    self.navigationController?.pushViewController(VC, animated: true)
                } else {
                    let VC = PadVideoPlayerViewController.init()
                    VC.model = self.videoModel
                    VC.model.serialDetailUrl = serialModel.detailUrl
                    VC.model.serialIndex = indexPath.row
                    VC.model.circuitIndex = indexPath.section-1
                    VC.reloadFatherVC = {
                        mainCollection.reloadData()
                    }
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            }
        }
        return mainCollection
    }()
}
