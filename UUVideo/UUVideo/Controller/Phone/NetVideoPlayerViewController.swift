//
//  NetVideoPlayerViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/19.
//  Copyright © 2020 qykj. All rights reserved.
//  视频播放界面

import UIKit
import GRDB
import SJVideoPlayer
import WebKit
import MRDLNA
import ReactiveCocoa
import NotificationBannerSwift
import MediaPlayer
import UICollectionViewLeftAlignedLayout

class NetVideoPlayerViewController: BaseViewController, DLNADelegate {
    //    投屏设备
    private var deviceArr: [Any] = []
    private var isPlaying: Bool = false
    public var model: VideoModel = VideoModel.init()
    // 创建右侧投屏按钮。如果获取到了播放地址，显示投屏按钮，点击弹出选择按钮。
    private let toupingBtn = UIButton.init(type: .custom)
    private let copyBtn = UIButton.init(type: .custom)
    public var isFromHistory: Bool = false
    public var reloadFatherVC:(()->())?
    func shouldAutorotate()->Bool{
        false
    }
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
        isPlaying = false
        player.vc_viewWillDisappear()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
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
        NotificationCenter.default.reactive.notifications(forName: UIApplication.didEnterBackgroundNotification, object: nil).observe { notification in
            if !(self.model.videoUrl.isEmpty) {
                // 有播放地址才保存
                self.model.progress = Int(self.player.currentTime)
                SqlTool.init().saveHistory(model: self.model)
                self.player.pause()
            }
        }
        NotificationCenter.default.reactive.notifications(forName: UIApplication.willResignActiveNotification, object: nil).observe { notification in
            self.model.progress = Int(self.player.currentTime)
        }
        NotificationCenter.default.reactive.notifications(forName: UIApplication.didBecomeActiveNotification, object: nil).observe { notification in
            if !self.model.videoUrl.isEmpty && self.isPlaying == true {
                self.player.play()
            }
        }
        dlnaManager.startSearch()
    }
    @objc func playerDidFinish() {
        player.defaultEdgeControlLayer.centerContainerView.isHidden = false
    }
    @objc func replayPlayer() {
        player.defaultEdgeControlLayer.centerContainerView.isHidden = true
        isPlaying = true
        player.replay()
    }
    lazy var dlnaManager: MRDLNA = {
        let dlnaManager = MRDLNA.sharedMRDLNAManager()
        dlnaManager?.delegate = self
        return dlnaManager!
    }()
    func setNav() {
        let rightBtnView = UIView.init()
        rightBtnView.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        // 添加右上角投屏按钮
        toupingBtn.frame = CGRect(x: 40, y: 0, width: 40, height: 40)
        toupingBtn.setImage(UIImage.init(systemName: "tv"), for: .normal)
        toupingBtn.addTarget(self, action: #selector(touping), for: .touchUpInside)
        rightBtnView.addSubview(toupingBtn)
        // TODO:添加下载按钮
        copyBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightBtnView.addSubview(copyBtn)
        copyBtn.setImage(UIImage.init(systemName: "doc.on.doc"), for: .normal)
        copyBtn.reactive.controlEvents(.touchUpInside).observeValues { button in
            let actionSheetView = UIAlertController.init(title: "提示", message: "选择复制内容", preferredStyle: .actionSheet)
            let videoUrlAction = UIAlertAction.init(title: "视频播放地址", style: .default) { action in
                UIPasteboard.general.string = self.model.videoUrl
                let alert = UIAlertController.init(title: "提醒", message: "播放地址已复制到接切板", preferredStyle: .alert)
                let cancelAction = UIAlertAction.init(title: "确定", style: .cancel)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            actionSheetView.addAction(videoUrlAction)
            let detailUrlAction = UIAlertAction.init(title: "视频详情地址", style: .default) { action in
                UIPasteboard.general.string = self.model.serialDetailUrl
                let alert = UIAlertController.init(title: "提醒", message: "播放地址已复制到接切板", preferredStyle: .alert)
                let cancelAction = UIAlertAction.init(title: "确定", style: .cancel)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            actionSheetView.addAction(detailUrlAction)
            let cancelAction = UIAlertAction.init(title: "取消", style: .cancel)
            actionSheetView.addAction(cancelAction)
            self.present(actionSheetView, animated: true)
        }
        let rightBtnItem = UIBarButtonItem.init(customView: rightBtnView)
        navigationItem.rightBarButtonItem = rightBtnItem
    }
    @objc func touping() {
        // 投屏
        if deviceArr.isEmpty {
            view.makeToast("当前未发现可投屏设备")
        } else {
            let alert = UIAlertController.init(title: "", message: "请选择设备", preferredStyle: .actionSheet)
            for item in deviceArr {
                let device: CLUPnPDevice = item as! CLUPnPDevice
                let deviceAction = UIAlertAction.init(title: device.friendlyName, style: .default) { [self] action in
                    dlnaManager.device = device
                    dlnaManager.playUrl = model.videoUrl
                    dlnaManager.start()
                    dlnaManager.dlnaPlay()
                    player.pause()
                    isPlaying = false
                }
                alert.addAction(deviceAction)
            }
            let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    func searchDLNAResult(_ devicesArray: [Any]!) {
        deviceArr = devicesArray
    }
    func dlnaStartPlay() {
        DispatchQueue.main.async {
            self.view.makeToast("投屏成功，开始播放")
        }
    }
    func playerVideo() {
        if model.videoUrl.isEmpty {
            let alert = UIAlertController.init(title: "提示", message: "当前视频没有播放地址", preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "返回上一页", style: .default) { action in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
            isPlaying = false
        } else {
            let headers = [
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/92.0.4515.107",
                "Referer":urlArr[model.webType]
            ];
            //FIXME:视频播放地址解包错误
            let asset = AVURLAsset.init(url: URL.init(string: model.videoUrl)!, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
            player.urlAsset = SJVideoPlayerURLAsset.init(avAsset: asset, startPosition: TimeInterval(model.progress), playModel: SJPlayModel.init())
            isPlaying = true
            // MARK: 设置通知栏播放器内容
            var videoInfo:[String:Any] = [:]
            videoInfo[MPMediaItemPropertyTitle] = model.name
            let albumArt = MPMediaItemArtwork.init(boundsSize: CGSize(width: screenW-60, height: 100)) { [self] size in
                var data = Data.init()
                do {
                    data = try NSData.init(contentsOf: URL.init(string: model.picUrl)!) as Data
                    return UIImage.init(data: data)!
                } catch  {
                    return UIImage.init()
                }
            }
            videoInfo[MPMediaItemPropertyArtwork] = albumArt
            videoInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            player.playbackObserver.durationDidChangeExeBlock = { player in
                videoInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
                MPNowPlayingInfoCenter.default().nowPlayingInfo = videoInfo
            }
            player.playbackObserver.currentTimeDidChangeExeBlock = { player in
                videoInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
                MPNowPlayingInfoCenter.default().nowPlayingInfo = videoInfo
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = videoInfo
        }
    }
    // 获取数据
    func getData() {
        // 正常流程下，需要先获取当前剧集的详情地址，然后再操作播放
        view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getVideoPlayerData(urlStr: (self.model.serialDetailUrl), website: websiteType(rawValue: (self.model.webType))!) { (resultModel) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.model.videoArr = resultModel.videoArr
                    self.model.serialArr = resultModel.serialArr
                    self.model.circuitArr = resultModel.circuitArr
                    if (self.model.webType == 1) {
                        self.model.videoUrl = (resultModel.videoUrl.replacingOccurrences(of: "https://www.bfq168.com/m3u8.php?url=", with: ""))
                    } else {
                        self.model.videoUrl = resultModel.videoUrl
                    }
                    // 此处已获取到所有剧集播放地址，根据选中的剧集，获取到播放地址。
                    /*
                    if self.model.type == 5 && self.isFromHistory {
                        // 当是从历史记录进入时，播放的是第几集，根据名字匹配是第几集
                        for (index, serialModel) in resultModel.serialArr.enumerated() {
                            if serialModel.name == self.model.serialName {
                                self.model.serialIndex = index
                            }
                        }
                    }
                     */
                    let circuitModel = self.model.circuitArr[self.model.circuitIndex]
                    let currentSerialModel: SerialModel = circuitModel.serialArr[self.model.serialIndex]
                    currentSerialModel.ischoose = true
                    self.model.serialName = currentSerialModel.name
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
        player.defaultEdgeControlLayer.automaticallyShowsPictureInPictureItem = true
        player.defaultEdgeControlLayer.centerAdapter.removeItem(forTag: SJEdgeControlLayerCenterItem_Replay)
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
            if indexPath.section == model.circuitArr.count {
                // 视频
                let model = mainCollection.model.videoArr[indexPath.row]
                let VC = NetVideoDetailViewController.init()
                VC.videoModel = model
                self.navigationController?.pushViewController(VC, animated: true)
            } else {
                if self.reloadFatherVC != nil {
                    self.reloadFatherVC!()
                }
                // 剧集
                self.model.circuitIndex = indexPath.section
                self.model.serialIndex = indexPath.row
                // 在当前页面获取数据并刷新
                let circuitModel = self.model.circuitArr[indexPath.section]
                let serialModel = circuitModel.serialArr[indexPath.row]
                self.model.serialDetailUrl = serialModel.detailUrl
                self.model.progress = 0
                self.isFromHistory = false
                self.getData()
            }
        }
        return mainCollection
    }()
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
