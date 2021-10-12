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

class PadVideoPlayerViewController: BaseViewController,DLNADelegate {
    
    public var model: VideoModel = VideoModel.init()
    private let toupingBtn = UIButton.init(type: .custom)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.vc_viewDidAppear()
        // 重新进入页面，判断是否需要重新播放
        if !model.videoUrl.isEmpty {
            self.playerVideo()
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
                    }else if(self.model.webType == 2){
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
        if self.model.videoUrl.isEmpty {
            let alert = UIAlertController.init(title: "提示", message: "当前视频没有播放地址", preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "返回上一页", style: .default) { action in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            let asset = AVURLAsset.init(url: URL.init(string: self.model.videoUrl)!, options: ["AVURLAssetHTTPHeaderFieldsKey":headers])
            // 获取视频分辨率
            //            let tracksArr = asset.tracks(withMediaType: AVMediaType.video)
            //            if !tracksArr.isEmpty {
            //                let videoTrack = tracksArr[0]
            //                let t = videoTrack.preferredTransform
            //                print("视频大小是 width : \(videoTrack.naturalSize.width) height: \(videoTrack.naturalSize.height)")
            //            }
            self.player.urlAsset = SJVideoPlayerURLAsset.init(avAsset: asset, startPosition: TimeInterval(self.model.progress), playModel: SJPlayModel.init())
        }
        print("播放地址是"+self.model.videoUrl)
    }
    
    // MARK:视频播放器
    lazy var player: SJVideoPlayer = {
        let player = SJVideoPlayer.init()
        self.view.addSubview(player.view)
        player.view.snp.makeConstraints { (make) in
            if Tool.isPhone() {
                make.left.right.equalToSuperview()
                make.height.equalTo(screenW * 3 / 4)
            }else{
                make.left.equalToSuperview()
                make.size.equalTo(CGSize(width: screenW-375, height: (screenW-375) * 3 / 4))
            }
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        player.rotationManager.isDisabledAutorotation = true
        player.defaultEdgeControlLayer.topAdapter.removeItem(forTag: SJEdgeControlLayerTopItem_Back)
        player.defaultEdgeControlLayer.topAdapter.reload()
        player.defaultEdgeControlLayer.automaticallyShowsPictureInPictureItem = true
        player.controlLayerNeedAppear()
        // 截获全屏点击事件，改为自定义
//        let fullItem = player.defaultEdgeControlLayer.bottomAdapter.item(forTag: SJEdgeControlLayerBottomItem_Full)
//        let action = SJEdgeControlButtonItemAction.init(target: self, action: #selector(fullPlayer))
//        fullItem?.addAction(action)
        return player
    }()
    
    @objc func fullPlayer(){
        print("全屏")
        let VC = PadFullPlayerViewController.init()
        VC.view.isHidden = true
        self.view.addSubview(VC.view)
        let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        var videoOrientation:SJOrientation = .landscapeRight
        if orientation == .landscapeRight{
            videoOrientation = .landscapeLeft
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            VC.player.rotate(videoOrientation, animated: true){ player in
                VC.view.isHidden = false
                self.navigationController?.pushViewController(VC, animated: false)
            }
        }
    }
    
    // MARK:底部内容
    
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
