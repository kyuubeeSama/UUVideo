//
//  VideoPlayerViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/16.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import SJVideoPlayer
import SnapKit
class VideoPlayerViewController: BaseViewController {
    
    var model:VideoModel?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.player.vc_viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.vc_viewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player.vc_viewDidDisappear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.player.urlAsset = SJVideoPlayerURLAsset.init(url: URL.init(fileURLWithPath: (model?.filePath)!))
    }
    
    // 播放器，默认全屏播放
    lazy var player: SJBaseVideoPlayer = {
        let player = SJBaseVideoPlayer.init()
        self.view.addSubview(player.view)
        player.view.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        player.autoManageViewToFitOnScreenOrRotation = false
        player.useFitOnScreenAndDisableRotation = true
        player.controlLayerNeedAppear()
        return player
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
