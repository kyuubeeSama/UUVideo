//
//  PhoneVideoListViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//  本地视频

import UIKit

class PhoneVideoListViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getVideo()
    }

    //获取所有的本地视频
    func getVideo() {
        // 视频分为本地视频和相册视频
        // 本地视频
        let ftool = FileTool.init()
        let localArr: [VideoModel] = ftool.getVideoFileList()
        let listModel1 = ListModel.init()
        listModel1.title = "本地视频"
        listModel1.more = false
        listModel1.list = localArr
        var videoArr: [ListModel] = [listModel1]
        mainCollect.listArr = videoArr
        // 相册视频
        ftool.getPhoneVideo()
        ftool.getPhoneVideoComplete = { result in
            let listModel2 = ListModel.init()
            listModel2.title = "相册视频"
            listModel2.more = false
            listModel2.list = result
            videoArr.append(listModel2)
            DispatchQueue.main.async {
                self.mainCollect.listArr = videoArr
            }
        }
    }

    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr[indexPath.section]
            let VC = LocalVideoPlayerViewController.init()
            VC.model = listModel.list[indexPath.row]
            VC.modalPresentationStyle = .fullScreen
            self.present(VC, animated: true, completion: nil)
        }
        return mainCollection
    }()

}
