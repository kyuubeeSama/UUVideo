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
class NetVideoPlayerViewController: BaseViewController {
    
    var model:VideoModel?
    var index:Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getData()
    }
    // 获取数据
    func getData(){
        let model = self.model?.serialArr![index]
        DataManager.init().getLkbVideoDetailData(urlStr:"https://www.laikuaibo.com"+(model?.detailUrl)!) { (resultModel) in
            print(resultModel)
//            保存数据库到历史记录表中
            let databasePath = FileTool.init().getDocumentPath()+"/database.db"
            let dbQueue = try? DatabaseQueue(path: databasePath)
            try? dbQueue?.write { db in
                try? db.execute(sql: """
                                     INSERT INTO history ('name','url',add_time) VALUES(:name,:url,:add_time)
                                     """,arguments: [resultModel.name,resultModel.detailUrl,Date.getCurrentTimeInterval()])
            }
            self.mainCollect.model = resultModel
        }
    }
    // collectionview
    lazy var mainCollect: NetVideoPlayerCollectionView = {
        let layout = EqualSpaceFlowLayout(AlignType.left,20.0)
        let mainCollection = NetVideoPlayerCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
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
