//
//  PadIndexViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/17.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import SnapKit
class PadIndexViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do{
            let path = FileTool.init().getDocumentPath().appending("/video")
            _ = try FileTool.init().createDirectory(path: path)
        }catch (let error){
            print(error)
        }
        self.mainTable.listArr = ["本地视频"]
    }
    
    lazy var mainTable: WebsiteTableView = {
        let mainTable = WebsiteTableView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), style: .plain)
        self.view.addSubview(mainTable)
        mainTable.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        mainTable.cellItemDidSelect = { indexPath in
            let string = mainTable.listArr![indexPath.row]
            // 点击切换数据源
            if(string == "本地视频"){
                self.getVideo()
            }
        }
        return mainTable
    }()
    
    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(200)
        }
        mainCollection.cellItemSelected = { indexPath in
            let dic = mainCollection.listArr![indexPath.section]
            let listArr:[videoModel] = dic["list"] as! [videoModel]
            let VC = VideoPlayerViewController.init()
            VC.model = listArr[indexPath.row]
            VC.modalPresentationStyle = .fullScreen
            self.present(VC, animated: true, completion: nil)
        }
        return mainCollection
    }()
    
    //获取所有的视频
    func getVideo(){
        // 视频分为本地视频和相册视频
        // 本地视频
        let ftool = FileTool.init()
        let localArr:[videoModel] = ftool.getVideoFileList()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
