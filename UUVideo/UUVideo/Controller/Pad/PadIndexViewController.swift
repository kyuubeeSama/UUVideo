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
    var allVideoArr:[[Any]] = [[],[]]
    var tableIndex:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do{
            let path = FileTool.init().getDocumentPath().appending("/video")
            _ = try FileTool.init().createDirectory(path: path)
        }catch (let error){
            print(error)
        }
        self.mainTable.listArr = ["本地视频","新番时间表"]
        self.getVideo()
    }
    
    lazy var mainTable: WebsiteTableView = {
        let mainTable = WebsiteTableView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), style: .plain)
        self.view.addSubview(mainTable)
        mainTable.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        mainTable.cellItemDidSelect = { indexPath in
            self.tableIndex = indexPath.row
            let string = mainTable.listArr![indexPath.row]
            // 点击切换数据源
            if(string == "本地视频"){
                self.getVideo()
            }else if(string == "新番时间表"){
                self.getBangumi()
            }
        }
        return mainTable
    }()

    lazy var chooseView: CategoryChooseView = {
        let chooseView = CategoryChooseView.init(frame: CGRect(x: 0, y: top_height, width: screenW, height: 40))
        self.view.addSubview(chooseView)
        let config = CategoryChooseConfig.init()
        config.listArr = ["周一","周二","周三","周四","周五","周六","周日"]
        config.backColor = .white
        chooseView.config = config
        chooseView.chooseBlock = { index in
            let listArr:[[VideoModel]] = self.allVideoArr[self.tableIndex] as! [[VideoModel]]
            let array = listArr[index]
            self.mainCollect.listArr = [["title":"","list":array]]
        }
        chooseView.isHidden = false
        chooseView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(self.mainTable.snp.right)
            make.top.equalToSuperview().offset(top_height)
            make.height.equalTo(40)
        }
        return chooseView
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
            let listArr:[VideoModel] = dic["list"] as! [VideoModel]
            let VC = LocalVideoPlayerViewController.init()
            VC.model = listArr[indexPath.row]
            VC.modalPresentationStyle = .fullScreen
            self.present(VC, animated: true, completion: nil)
        }
        return mainCollection
    }()
    
    //获取所有的视频
    func getVideo(){
        self.mainCollect.snp.remakeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(200)
        }
        self.chooseView.isHidden = true
        self.tableIndex = 0
        let array = self.allVideoArr[self.tableIndex]
        if array.count == 0 {
            // 视频分为本地视频和相册视频
            // 本地视频
            let ftool = FileTool.init()
            let localArr:[VideoModel] = ftool.getVideoFileList()
            var videoArr:[[String:Any]] = [["title":"本地视频","list":localArr]]
            self.allVideoArr [0] = videoArr
            self.mainCollect.listArr = videoArr
    //        for item:VideoModel in localArr {
    //            print("视频名字是\(item.name),时长是\(item.time)")
    //        }
            // 相册视频
            ftool.getPhoneVideo()
            ftool.getPhoneVideoComplete = { result in
                videoArr.append(["title":"相册视频","list":result])
                self.allVideoArr[0] = videoArr
                DispatchQueue.main.async {
                    self.mainCollect.listArr = videoArr
                }
            }
        }else{
            let videoArr:[[String:Any]] = self.allVideoArr[0] as! [[String:Any]]
            self.mainCollect.listArr = videoArr
        }
    }
    
    // 获取新番数据
    func getBangumi(){
        mainCollect.snp.remakeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.top.equalTo(chooseView.snp.bottom)
            make.left.equalTo(chooseView.snp.left)
        }
        self.chooseView.isHidden = false
        let array:[[VideoModel]] = self.allVideoArr[1] as! [[VideoModel]]
        mainCollect.listArr = []
        mainCollect.reloadData()
        mainCollect.makeToastActivity(.center)
        if array.count == 0 {
            let dataManager = DataManager.init()
            dataManager.getBangumiData { (dataArr) in
                self.mainCollect.hideToastActivity()
                self.allVideoArr[self.tableIndex] = dataArr
                self.chooseView.index = 0
            } failure: { (error) in
                print(error)
            }
        }else{
            self.chooseView.index = 0
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
