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
    var webType: websiteType = .halihali
    private var playerUrl = ""

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.vc_viewDidAppear()
        // 重新进入页面，判断是否需要重新播放
        if !playerUrl.isEmpty {
            player.urlAsset = SJVideoPlayerURLAsset.init(url: URL.init(string: playerUrl)!)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.vc_viewWillDisappear()
        // TODO:当视频要退出时，保存视频记录，视频进度
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //FIXME:退出界面时停止播放，进入页面时需要重新播放
        player.stop()
        player.vc_viewDidDisappear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getData()
    }

    // 获取数据
    func getData() {
        let model = self.model?.serialArr![(self.model?.serialIndex)!]
        view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getVideoPlayerData(urlStr: (model?.detailUrl)!, website: self.webType) { (resultModel) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.model?.webType = self.webType.rawValue
                    self.model?.videoArr = resultModel.videoArr
                    self.model?.serialArr = resultModel.serialArr
                    if (self.webType == .laikuaibo){
                        self.playerUrl = (resultModel.videoUrl?.replacingOccurrences(of: "https://www.bfq168.com/m3u8.php?url=", with: ""))!
                        self.model?.videoUrl = self.playerUrl
                        print("视频播放地址是\(self.playerUrl)")
                    }else if(self.webType == .halihali){
                        let config = WKWebViewConfiguration.init()
                        let webView = UUWebView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: config)
                        self.view.addSubview(webView)
                        webView.load(URLRequest.init(url: URL.init(string: (model?.detailUrl)!)!))
                        webView.getVideoUrlComplete = { videoUrl in
                            self.view.hideToastActivity()
                            print("视频播放地址是\(videoUrl)")
                            self.playerUrl = videoUrl
                            self.player.urlAsset = SJVideoPlayerURLAsset.init(url: URL.init(string: self.playerUrl)!)
                            webView.removeFromSuperview()
                        }
                    }
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
                if self.webType == .halihali {
                    let model = self.model?.serialArr![indexPath.row]
                    self.playerUrl = (model?.detailUrl)!
                    self.player.urlAsset = SJVideoPlayerURLAsset.init(url: URL.init(string: self.playerUrl)!)
                }else{
                    self.getData()
                }
            } else {
                // 视频
                let model = mainCollection.model!.videoArr![indexPath.row]
                let VC = NetVideoDetailViewController.init()
                VC.videoModel = model
                VC.webType = self.webType
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
