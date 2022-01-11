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
import MRDLNA
import ReactiveCocoa
import NotificationBannerSwift

class NetVideoPlayerViewController: BaseViewController,DLNADelegate{

    public var model: VideoModel = VideoModel.init()
    // 创建右侧投屏按钮。如果获取到了播放地址，显示投屏按钮，点击弹出选择按钮。
    private let toupingBtn = UIButton.init(type: .custom)
    private let downloadBtn = UIButton.init(type: .custom)
    public var isFromHistory:Bool = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.vc_viewDidAppear()
        // 重新进入页面，判断是否需要重新播放
        if !model.videoUrl.isEmpty {
            playerVideo()
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
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinish), name: NSNotification.Name.SJMediaPlayerPlaybackDidFinish, object: nil)
    }
    
    @objc func playerDidFinish(){
        self.player.defaultEdgeControlLayer.centerContainerView.isHidden = false
    }

    @objc func replayPlayer(){
        self.player.defaultEdgeControlLayer.centerContainerView.isHidden = true
        self.player.replay()
    }
    
    @objc func playNextVideo(){
        self.player.defaultEdgeControlLayer.centerAdapter.removeItem(forTag: 10)
        if model.webType == 0 {
            // 查看剧集是否有播放地址，如果没有就提示无法播放
            let serialModel = model.serialArr[model.serialIndex+1]
            if serialModel.playerUrl.isEmpty {
                let alert = UIAlertController.init(title: "提醒", message: "该集无法播放", preferredStyle: .alert)
                let sureAction = UIAlertAction.init(title: "确定", style: .cancel, handler: nil)
                alert.addAction(sureAction)
                present(alert, animated: true, completion: nil)
            }else{
                self.player.defaultEdgeControlLayer.centerContainerView.isHidden = true
                model.videoUrl = (serialModel.playerUrl)
                model.progress = 0
                playerVideo()
                model.serialIndex = model.serialIndex+1
                model.serialName = serialModel.name
                mainCollect.model = model
            }
        } else {
            self.player.defaultEdgeControlLayer.centerContainerView.isHidden = true
            let serialModel = model.serialArr[model.serialIndex+1]
            model.serialDetailUrl = serialModel.detailUrl
            model.serialIndex = model.serialIndex+1
            getData()
        }
    }
    
    lazy var dlnaManager: MRDLNA = {
        let dlnaManager = MRDLNA.sharedMRDLNAManager()
        dlnaManager?.delegate = self
        return dlnaManager!
    }()
    
    func setNav(){
        let rightBtnView = UIView.init()
        rightBtnView.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        // 添加右上角投屏按钮
        toupingBtn.frame = CGRect(x: 40, y: 0, width: 40, height: 40)
        toupingBtn.setImage(UIImage.init(systemName: "tv"), for: .normal)
        toupingBtn.addTarget(self, action: #selector(touping), for: .touchUpInside)
        rightBtnView.addSubview(toupingBtn)
        // TODO:添加下载按钮
        downloadBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightBtnView.addSubview(downloadBtn)
        downloadBtn.setImage(UIImage.init(systemName: "arrow.down.square"), for: .normal)
        downloadBtn.reactive.controlEvents(.touchUpInside).observeValues { button in
            // 下载操作
            let alert = UIAlertController.init(title: "提醒", message: self.model.videoUrl, preferredStyle: .alert)
            let copyAction = UIAlertAction.init(title: "复制", style: .default) { action in
                UIPasteboard.general.string = self.model.videoUrl
            }
            alert.addAction(copyAction)
            let openAction = UIAlertAction.init(title: "浏览器打开", style: .default) { action in
                UIApplication.shared.open(URL.init(string: self.model.videoUrl)!, options: [:], completionHandler: nil)
            }
            alert.addAction(openAction)
            self.present(alert, animated: true, completion: nil)
        }
        downloadBtn.isHidden = true
        let rightBtnItem = UIBarButtonItem.init(customView: rightBtnView)
        navigationItem.rightBarButtonItem = rightBtnItem
    }
    
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
                let alert = UIAlertController.init(title: "", message: "请选择设备", preferredStyle: .actionSheet)
                for item in devicesArray {
                    let device:CLUPnPDevice = item as! CLUPnPDevice
                    let deviceAction = UIAlertAction.init(title: device.friendlyName, style: .default) { [self] action in
                        self.dlnaManager.device = device
                        self.dlnaManager.playUrl = self.model.videoUrl
                        self.dlnaManager.start()
                        self.dlnaManager.dlnaPlay()
                        self.player.pause()
                    }
                    alert.addAction(deviceAction)
                }
                let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func dlnaStartPlay() {
        DispatchQueue.main.async {
            self.view.makeToast("投屏成功，开始播放")
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
            // 判断视频是否可以播放
            self.downloadBtn.isHidden = (model.videoUrl.contains("m3u8") || model.videoUrl.contains("html"))
        }
        print("播放地址是"+model.videoUrl)
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
                    if self.model.type == 5 && self.isFromHistory{
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
                    self.mainCollect.model = self.model
                }
            } failure: { (error) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.makeToast("内容获取失败")
                }
            }
        }
    }

    lazy var player: SJVideoPlayer = {
        let playerView = UIView.init()
        self.view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(screenW * 3 / 4)
        }
        let player = SJVideoPlayer.init()
        playerView.addSubview(player.view)
        player.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        player.defaultEdgeControlLayer.topAdapter.removeItem(forTag: SJEdgeControlLayerTopItem_Back)
        player.defaultEdgeControlLayer.topAdapter.reload()
        player.defaultEdgeControlLayer.automaticallyShowsPictureInPictureItem = false
        player.defaultEdgeControlLayer.centerAdapter.removeItem(forTag: SJEdgeControlLayerCenterItem_Replay)
        let buttonView = UIView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        // 重播按钮
        let replayBtn = UIButton.init(type: .custom)
        replayBtn.addTarget(self, action: #selector(replayPlayer), for: .touchUpInside)
        replayBtn.setImage(UIImage.init(named: "sj_video_player_replay"), for: .normal)
        replayBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
        buttonView.addSubview(replayBtn)
        // 下一集按钮
        let nextBtn = UIButton.init(type: .custom)
        nextBtn.addTarget(self, action: #selector(playNextVideo), for: .touchUpInside)
        nextBtn.setImage(UIImage.init(named: "sj_video_player_fast"), for: .normal)
        nextBtn.frame = CGRect(x: 50, y: 0, width: 50, height: 60)
        buttonView.addSubview(nextBtn)
        
        let item = SJEdgeControlButtonItem.frameLayout(withCustomView: buttonView, tag: 10)
        player.defaultEdgeControlLayer.centerAdapter.add(item)
        player.defaultEdgeControlLayer.centerAdapter.reload()
        player.defaultEdgeControlLayer.centerContainerView.isHidden = true
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
                self.model.serialIndex = indexPath.row
                // 在当前页面获取数据并刷新
                if self.model.webType == 0 {
                    // 查看剧集是否有播放地址，如果没有就提示无法播放
                    let serialModel = self.model.serialArr[indexPath.row]
                    if serialModel.playerUrl.isEmpty {
                        let alert = UIAlertController.init(title: "提醒", message: "该集无法播放", preferredStyle: .alert)
                        let sureAction = UIAlertAction.init(title: "确定", style: .cancel, handler: nil)
                        alert.addAction(sureAction)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.model.videoUrl = (serialModel.playerUrl)
                        self.model.progress = 0
                        self.model.serialIndex = indexPath.row
                        self.model.serialName = serialModel.name
                        self.isFromHistory = false
                        self.playerVideo()
                        mainCollection.model = self.model
                    }
                } else {
                    let serialModel = self.model.serialArr[indexPath.row]
                    self.model.serialDetailUrl = serialModel.detailUrl
                    self.model.serialIndex = indexPath.row
                    self.model.progress = 0
                    self.isFromHistory = false
                    self.getData()
                }
            } else {
                // 视频
                let model = mainCollection.model!.videoArr[indexPath.row]
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
