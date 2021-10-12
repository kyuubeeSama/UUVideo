//
//  PadFullPlayerViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2021/10/12.
//  Copyright © 2021 qykj. All rights reserved.
//  全屏播放

import UIKit
import SJVideoPlayer
import SnapKit

class PadFullPlayerViewController: BaseViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.vc_viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.vc_viewWillDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.vc_viewWillDisappear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    lazy var player: SJVideoPlayer = {
        let player = SJVideoPlayer.init()
        self.view.addSubview(player.view)
        player.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalTo(self.player.view.snp.width).multipliedBy(9/16)
        }
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
