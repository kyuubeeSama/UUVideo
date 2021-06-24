//
//  HistoryViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2021/3/28.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit

class HistoryViewController: BaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Tool.isPhone() {
            getHistoryData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if Tool.isPhone() {
            getHistoryData()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "清空", style: .plain, target: self, action: #selector(cleanHistory))
    }
    
    @objc func cleanHistory(){
        let alert = UIAlertController.init(title: "警告", message: "是否删除所有历史记录", preferredStyle: .alert)
        let sureAction = UIAlertAction.init(title: "删除", style: .default) { action in
            if SqlTool.init().cleanHistory() {
                self.mainCollect.listArr = []
            }
        }
        alert.addAction(sureAction)
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getHistoryData(){
        let listModel = SqlTool.init().getHistory()
        mainCollect.listArr = [listModel]
    }
    // TODO: cell 显示上次播放的时间
    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { indexPath in
            //            进入剧集界面
            let listModel = mainCollection.listArr![indexPath.section]
            let VC = NetVideoPlayerViewController.init()
            let videoModel = listModel.list[indexPath.row]
            VC.model = videoModel
            self.navigationController?.pushViewController(VC, animated: true)
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
