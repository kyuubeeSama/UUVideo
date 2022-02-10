//
//  PadVideoPlayerViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2021/10/9.
//  Copyright © 2021 qykj. All rights reserved.
//

// 界面分三部分，右侧为推荐视频，单竖排. 左上视频播放地址。 左下，视频名称，视频介绍，剧集选择

import UIKit
import GRDB
import SJVideoPlayer
import WebKit
import MRDLNA
import SnapKit
import Popover_OC

class PadVideoPlayerViewController: BaseViewController,DLNADelegate {
    
    public var model: VideoModel = VideoModel.init()
    private let toupingBtn = UIButton.init(type: .custom)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.vc_viewDidAppear()
        // 重新进入页面，判断是否需要重新播放
        if !model.videoUrl.isEmpty {
            playerVideo()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinish), name: NSNotification.Name.SJMediaPlayerPlaybackDidFinish, object: nil)
    }
    
    @objc func playerDidFinish(){
        print("全屏")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.vc_viewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 当视频要退出时，保存视频记录，视频进度
        player.vc_viewDidDisappear()
        if !(model.videoUrl.isEmpty) {
            // 有播放地址才保存
            model.progress = Int(player.currentTime)
            SqlTool.init().saveHistory(model: model)
            player.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setNav()
        getData()
        NotificationCenter.default.reactive.notifications(forName: UIApplication.willResignActiveNotification, object: nil).observe { notification in
            print("进入后台")
            if !(self.model.videoUrl.isEmpty) {
                // 有播放地址才保存
                self.model.progress = Int(self.player.currentTime)
                SqlTool.init().saveHistory(model: self.model)
                self.player.stop()
            }
        }
        NotificationCenter.default.reactive.notifications(forName: UIApplication.didBecomeActiveNotification, object: nil).observe{ notification in
            if !self.model.videoUrl.isEmpty {
                self.playerVideo()
            }
        }
    }
    
    lazy var dlnaManager: MRDLNA = {
        let dlnaManager = MRDLNA.sharedMRDLNAManager()
        dlnaManager?.delegate = self
        return dlnaManager!
    }()
    
    @objc func touping(){
        // 投屏
        dlnaManager.startSearch()
    }
    
    func searchDLNAResult(_ devicesArray: [Any]!) {
        view.makeToastActivity(.center)
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.view.hideToastActivity()
            if devicesArray.isEmpty {
                self.view.makeToast("当前未发现可投屏设备")
            }else{
                let keyWindows = UIApplication.shared.windows[0]
                let lastPopoverView:PopoverView = keyWindows.viewWithTag(100)! as! PopoverView
                lastPopoverView.removeFromSuperview()
                var actionArr:[PopoverAction] = []
                for item in devicesArray {
                    let device:CLUPnPDevice = item as! CLUPnPDevice
                    let deviceAction = PopoverAction.init(title: device.friendlyName) { action in
                        self.dlnaManager.device = device
                        self.dlnaManager.playUrl = self.model.videoUrl
                        self.dlnaManager.start()
                        self.dlnaManager.dlnaPlay()
                        self.player.pause()
                    }
                    actionArr.append(deviceAction!)
                }
                let popoverView = PopoverView.init()
                popoverView.tag = 100
                popoverView.show(to: CGPoint(x: screenW-40, y: top_height), with: actionArr)
            }
        }
    }
    
    func dlnaStartPlay() {
        DispatchQueue.main.async {
            self.view.makeToast("投屏成功，开始播放")
        }
    }
    
    func setNav(){
        // 添加右上角投屏按钮
        toupingBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        toupingBtn.setImage(UIImage.init(systemName: "tv"), for: .normal)
        toupingBtn.addTarget(self, action: #selector(touping), for: .touchUpInside)
        let rightBtnItem = UIBarButtonItem.init(customView: toupingBtn)
        navigationItem.rightBarButtonItem = rightBtnItem
    }
    
    // 获取数据
    func getData() {
        // 正常流程下，需要先获取当前剧集的详情地址，然后再操作播放
        view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getVideoPlayerData(urlStr: (self.model.serialDetailUrl), website:websiteType(rawValue: (self.model.webType)!)!, videoNum: self.model.serialNum) { (resultModel) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.model.videoArr = resultModel.videoArr
                    self.model.serialArr = resultModel.serialArr
                    if (self.model.webType == 1) {
                        self.model.videoUrl = (resultModel.videoUrl.replacingOccurrences(of: "https://www.bfq168.com/m3u8.php?url=", with: ""))
                    }else if(self.model.webType == 2 || self.model.webType == 3){
                        self.model.videoUrl = resultModel.videoUrl
                    }
                    // 此处已获取到所有剧集播放地址，根据选中的剧集，获取到播放地址。
                    if self.model.type == 5 {
                        // 当是从历史记录进入时，播放的是第几集，根据名字匹配是第几集
                        for (index,serialModel) in resultModel.serialArr.enumerated() {
                            if serialModel.name == self.model.serialName {
                                self.model.serialIndex = index
                            }
                        }
                    }
                    let currentSerialModel:SerialModel = resultModel.serialArr[self.model.serialIndex]
                    self.model.serialName = currentSerialModel.name
                    if(self.model.webType == 0){
                        self.model.videoUrl = currentSerialModel.playerUrl
                    }
                    self.playerVideo()
                    let listModel = ListModel.init()
                    listModel.title = "推荐视频"
                    listModel.list = self.model.videoArr
                    self.recommendVideoList.listArr = [listModel]
                    self.mainCollection.model = self.model
                }
            } failure: { (error) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.makeToast("内容获取失败")
                }
            }
        }
    }
    
    func playerVideo(){
        let headers = ["User-Agent":"Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/92.0.4515.107"];
        if model.videoUrl.isEmpty {
            let alert = UIAlertController.init(title: "提示", message: "当前视频没有播放地址", preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "返回上一页", style: .default) { action in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        }else{
            let asset = AVURLAsset.init(url: URL.init(string: model.videoUrl)!, options: ["AVURLAssetHTTPHeaderFieldsKey":headers])
            player.urlAsset = SJVideoPlayerURLAsset.init(avAsset: asset, startPosition: TimeInterval(model.progress), playModel: SJPlayModel.init())
        }
        print("播放地址是"+model.videoUrl)
    }
    
    lazy var playerContainerView: UIView = {
        let playerView = UIView.init()
        view.addSubview(playerView)
        playerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-375)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(450)
        }
        return playerView
    }()
    
    // MARK:视频播放器
    lazy var player: SJVideoPlayer = {
        let player = SJVideoPlayer.init()
        playerContainerView.addSubview(player.view)
        player.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        player.onlyUsedFitOnScreen = true
        player.rotationManager.isDisabledAutorotation = true
        player.defaultEdgeControlLayer.topAdapter.removeItem(forTag: SJEdgeControlLayerTopItem_Back)
        player.defaultEdgeControlLayer.topAdapter.reload()
        player.defaultEdgeControlLayer.automaticallyShowsPictureInPictureItem = true
        player.controlLayerNeedAppear()
        return player
    }()
        
    // MARK:底部内容
    lazy var mainCollection: padVideoDetailCollectionView = {
        let layout = UICollectionViewLeftAlignedLayout.init()
        let mainCollection = padVideoDetailCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(self.playerContainerView.snp.bottom)
            make.right.equalToSuperview().offset(-375)
        }
        mainCollection.cellItemSelected = { [self] indexPath in
            if indexPath.section == 1 {
                // 剧集
                self.player.stop()
                let serialModel = self.model.serialArr[indexPath.row]
                // 在当前页面获取数据并刷新
                if self.model.webType == 0 {
                    // 查看剧集是否有播放地址，如果没有就提示无法播放
                    if serialModel.playerUrl.isEmpty {
                        let alert = UIAlertController.init(title: "提醒", message: "该集无法播放", preferredStyle: .alert)
                        let sureAction = UIAlertAction.init(title: "确定", style: .cancel, handler: nil)
                        alert.addAction(sureAction)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.model.videoUrl = (serialModel.playerUrl)
                        self.playerVideo()
                        self.model.serialIndex = indexPath.row
                        self.model.serialName = serialModel.name
                        mainCollection.model = self.model
                    }
                }else{
                    // 重新获取数据，并刷新页面
                    self.model.serialDetailUrl = serialModel.detailUrl
                    self.model.serialIndex = indexPath.row
                    self.model.serialName = serialModel.name
                    self.getData()
                }
            }
        }
        return mainCollection
    }()
    
    //MARK:右侧推荐视频
    lazy var recommendVideoList: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collectionView = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalTo(375)
        }
        collectionView.cellItemSelected = { indexPath in
            // cell点击，跳转到视频详情
            
        }
        return collectionView
    }()
    
    func prefersStatusBarHidden()->Bool{
        player.vc_prefersStatusBarHidden()
    }
    
    func preferredStatusBarStyle()->UIStatusBarStyle{
        player.vc_preferredStatusBarStyle()
    }
    
    func prefersHomeIndicatorAutoHidden()->Bool{
        true
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
