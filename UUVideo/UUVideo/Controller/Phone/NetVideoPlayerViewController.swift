//
//  NetVideoPlayerViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/19.
//  Copyright © 2020 qykj. All rights reserved.
//  视频播放界面
// TODO:添加播放记录到数据库

import UIKit
import GRDB
import SJVideoPlayer
import WebKit

class NetVideoPlayerViewController: BaseViewController {

    var model: VideoModel?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.vc_viewDidAppear()
        // 重新进入页面，判断是否需要重新播放
        if !model!.videoUrl.isEmpty {
            self.player.urlAsset = SJVideoPlayerURLAsset.init(url: URL.init(string: (self.model?.videoUrl)!)!, startPosition: TimeInterval(self.model!.progress))
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.vc_viewWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 当视频要退出时，保存视频记录，视频进度
        player.vc_viewDidDisappear()
        if !(model?.videoUrl.isEmpty)! {
            // 有播放地址才保存
            model?.progress = Int(player.currentTime)
            SqlTool.init().saveHistory(model: model!)
            player.stop()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getData()
    }

    // 获取数据
    func getData() {
        // 正常流程下，需要先获取当前剧集的详情地址，然后再操作播放
        view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getVideoPlayerData(urlStr: (self.model?.serialDetailUrl)!, website:websiteType(rawValue: (self.model?.webType)!)!) { (resultModel) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.model?.videoArr = resultModel.videoArr
                    self.model?.serialArr = resultModel.serialArr
                    if (self.model?.webType == 1) {
                        self.model?.videoUrl = (resultModel.videoUrl.replacingOccurrences(of: "https://www.bfq168.com/m3u8.php?url=", with: ""))
                    }
                    // 此处已获取到所有剧集播放地址，根据选中的剧集，获取到播放地址。
                    if self.model?.type == 5 {
                        // 当是从历史记录进入时，播放的是第几集，根据名字匹配是第几集
                        for (index,serialModel) in resultModel.serialArr!.enumerated() {
                            if serialModel.name == self.model?.serialName {
                                self.model?.serialIndex = index
                            }
                        }
                    }
                    let currentSerialModel:SerialModel = resultModel.serialArr![(self.model?.serialIndex)!]
                    self.model?.serialName = currentSerialModel.name
                    if(self.model?.webType == 0){
                        self.model?.videoUrl = currentSerialModel.playerUrl
                    }
                    self.player.urlAsset = SJVideoPlayerURLAsset.init(url: URL.init(string: (self.model?.videoUrl)!)!, startPosition: TimeInterval(self.model!.progress))
                    self.mainCollect.model = self.model
                }
            } failure: { (error) in
                print(error.localizedDescription)
            }
        }
    }

    lazy var player: SJVideoPlayer = {
        //FIXME:在ipad情况下，调整播放器大小
        let player = SJVideoPlayer.init()
        self.view.addSubview(player.view)
        player.view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(screenW * 3 / 4)
        }
        player.defaultEdgeControlLayer.automaticallyShowsPictureInPictureItem = true
        player.controlLayerNeedAppear()
        return player
    }()

    // collectionview
    lazy var mainCollect: NetVideoPlayerCollectionView = {
        let layout = UICollectionViewLeftAlignedLayout.init()
        let mainCollection = NetVideoPlayerCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.player.view.snp.bottom);
        }
        mainCollection.cellItemSelected = { [self] indexPath in
            if indexPath.section == 0 {
                // 剧集
                self.model?.serialIndex = indexPath.row
                // 在当前页面获取数据并刷新
                if self.model?.webType == 0 {
                    // 查看剧集是否有播放地址，如果没有就提示无法播放
                    let serialModel = self.model?.serialArr![indexPath.row]
                    if serialModel!.playerUrl.isEmpty {
                        let alert = UIAlertController.init(title: "提醒", message: "该集无法播放", preferredStyle: .alert)
                        let sureAction = UIAlertAction.init(title: "确定", style: .cancel, handler: nil)
                        alert.addAction(sureAction)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.model?.videoUrl = (serialModel?.playerUrl)!
                        self.player.urlAsset = SJVideoPlayerURLAsset.init(url: URL.init(string: (self.model?.videoUrl)!)!)
                    }
                } else {
                    let serialModel = self.model?.serialArr![indexPath.row]
                    self.model?.serialDetailUrl = serialModel?.detailUrl
                    self.getData()
                }
            } else {
                // 视频
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
