//
//  PhoneVideoListViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class PhoneVideoListViewController: BaseViewController {
    // 1.本地视频  2.哈利tv
    var website:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if website == 1 {
            self.getVideo()
        }else if website == 2{
            
        }else if website == 3{

        }
//        self.getVideo()
//        self.getHaliVideo()
    }
    //获取所有的本地视频
    func getVideo(){
        // 视频分为本地视频和相册视频
        // 本地视频
        let ftool = FileTool.init()
        let localArr:[VideoModel] = ftool.getVideoFileList()
        var videoArr:[[String:Any]] = [["title":"本地视频","list":localArr]]
        self.mainCollect.listArr = videoArr
//        for item:VideoModel in localArr {
//            print("视频名字是\(item.name),时长是\(item.time)")
//        }
        // 相册视频
        ftool.getPhoneVideo()
        ftool.getPhoneVideoComplete = { result in
            videoArr.append(["title":"相册视频","list":result])
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
            let dic = mainCollection.listArr![indexPath.section]
            let listArr:[VideoModel] = dic["list"] as! [VideoModel]
            let VC = LocalVideoPlayerViewController.init()
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
