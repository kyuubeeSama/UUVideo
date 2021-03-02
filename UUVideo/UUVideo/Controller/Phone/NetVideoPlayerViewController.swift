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
class NetVideoPlayerViewController: BaseViewController {
    
    var model:VideoModel?
    var index:Int!
    
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
        self.getData()
    }

    // 获取数据
    func getData(){
        let model = self.model?.serialArr![index]
        self.view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getLkbVideoDetailData(urlStr:"https://www.laikuaibo.com"+(model?.detailUrl)!) { (resultModel) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    //            保存数据库到历史记录表中
                    let databasePath = FileTool.init().getDocumentPath()+"/.database.db"
                    do{
                        let dbQueue = try DatabaseQueue(path: databasePath)
                        try dbQueue.write { db in
                            try db.execute(sql: """
                                                 INSERT INTO history ('name','url',add_time) VALUES(:name,:url,:add_time)
                                                 """,arguments: [model!.name,"https://www.laikuaibo.com"+(model?.detailUrl)!,Date.getCurrentTimeInterval()])
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                    resultModel.videoUrl = resultModel.videoUrl?.replacingOccurrences(of: "https://www.bfq168.com/m3u8.php?url=", with: "")
                    self.player.defaultEdgeControlLayer.automaticallyShowsPictureInPictureItem = true
                    self.player.urlAsset = SJVideoPlayerURLAsset.init(url: URL.init(string: resultModel.videoUrl!)!)
                    self.mainCollect.model = resultModel
                }
            }
        }
    }
    lazy var player: SJVideoPlayer = {
        let player = SJVideoPlayer.init()
        self.view.addSubview(player.view)
        player.view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(screenW*3/4)
        }
        player.controlLayerNeedAppear()
        return player
    }()
    
    // collectionview
    lazy var mainCollect: NetVideoPlayerCollectionView = {
        let layout = EqualSpaceFlowLayout(AlignType.left,20.0)
        let mainCollection = NetVideoPlayerCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.player.view.snp.bottom);
        }
        mainCollection.cellItemSelected = { indexPath in
            if indexPath.section == 1{
                // 剧集
                let VC = NetVideoPlayerViewController.init()
                VC.model = mainCollection.model
                VC.index = indexPath.row
                self.navigationController?.pushViewController(VC, animated: true)
            }else{
                //                视频
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
