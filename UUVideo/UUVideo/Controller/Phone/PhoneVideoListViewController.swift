//
//  PhoneVideoListViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class PhoneVideoListViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mainCollect.listArr = self.getVideo()
//        self.getVideo()
    }
    //获取所有的视频
    func getVideo()->[[String:Any]]{
        // 视频分为本地视频和相册视频
        // 本地视频
        let localArr:[VideoModel] = FileTool.init().getVideoFileList()
//        for item:VideoModel in localArr {
//            print("视频名字是\(item.name),时长是\(item.time)")
//        }
        // 相册视频
        let videoArr:[[String:Any]] = [["title":"本地视频","list":localArr]]
        return videoArr
    }

    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { indexPath in
            let dic = mainCollection.listArr![indexPath.section]
            let listArr:[VideoModel] = dic["list"] as! [VideoModel]
            let VC = VideoPlayerViewController.init()
            VC.model = listArr[indexPath.row]
            VC.modalPresentationStyle = .fullScreen
            self.present(VC, animated: true, completion: nil)
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
