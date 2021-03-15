//
//  PadIndexViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/17.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import SnapKit
import FluentDarkModeKit
import SideMenu
class PadIndexViewController: BaseViewController,UISearchBarDelegate {
    var allVideoArr:[[Any]] = [[],[],[]]
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
        self.mainTable.listArr = ["本地视频","新番时间表","哈哩TV"]
        self.getVideo()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeRotate(notice:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
        // 添加右侧图片
        let item = UIBarButtonItem.init(image: UIImage.init(systemName: "person.circle"), style: .plain, target: self, action: #selector(showUser))
        self.navigationItem.leftBarButtonItem = item
    }
    
    @objc func showUser(){
        print("显示个人中心")
        let VC = UserViewController.init()
        let menu = SideMenuNavigationController(rootViewController: VC)
        menu.presentationStyle = .menuSlideIn
        menu.menuWidth = 375
        menu.leftSide = true
        present(menu, animated: true, completion: nil)
    }
    
    @objc func didChangeRotate(notice:Notification){
        chooseView.layoutIfNeeded()
        chooseView.refreshView()
    }
    
    lazy var mainTable: WebsiteTableView = {
        let mainTable = WebsiteTableView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), style: .plain)
        self.view.addSubview(mainTable)
        mainTable.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        mainTable.cellItemDidSelect = { indexPath in
            self.view.endEditing(true)
            self.tableIndex = indexPath.row
            let string = mainTable.listArr![indexPath.row]
            // 点击切换数据源
            if(string == "本地视频"){
                self.getVideo()
            }else if(string == "新番时间表"){
                self.getBangumi()
            }else if(string == "哈哩TV"){
                self.getHaliTVData()
            }
        }
        return mainTable
    }()
    // 日期选择
    lazy var chooseView: CategoryChooseView = {
        let chooseView = CategoryChooseView.init()
        self.view.addSubview(chooseView)
        chooseView.snp.makeConstraints { (make) in
            make.right.equalTo(self.mainCollect.snp.right)
            make.left.equalToSuperview().offset(200)
            make.top.equalToSuperview().offset(top_height)
            make.height.equalTo(40)
        }
        chooseView.layoutIfNeeded()
        let config = CategoryChooseConfig.init()
        config.listArr = ["周一","周二","周三","周四","周五","周六","周日"]
        config.backColor = UIColor.init(.dm, light: .white, dark: .black)
        config.titleColor = UIColor.init(.dm, light: .black, dark: .white)
        config.highLightColor = UIColor.init(.dm, light: .white, dark: .black)
        chooseView.config = config
        chooseView.chooseBlock = { index in
            let listArr:[[VideoModel]] = self.allVideoArr[self.tableIndex] as! [[VideoModel]]
            let array = listArr[index]
            let listModel = ListModel.init()
            listModel.title = ""
            listModel.list = array
            listModel.more = false
            self.mainCollect.listArr = [listModel]
        }
        chooseView.isHidden = false
        return chooseView
    }()
    
    // 搜索界面
    lazy var searchView:UIView = {
        let searchView = UIView.init()
        self.view.addSubview(searchView)
        searchView.isHidden = true
        searchView.snp.makeConstraints { (make) in
            make.right.equalTo(self.mainCollect.snp.right)
            make.left.equalToSuperview().offset(200)
            make.top.equalToSuperview().offset(top_height)
            make.height.equalTo(50)
        }
        
        let searchBar = UISearchBar.init()
        searchView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 300, height: 30))
        }
        searchBar.delegate = self
        return searchView
    }()
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count>0 {
            let VC = SearchResultViewController.init()
            VC.keyword = searchBar.text
            VC.websiteValue = .haliTV
            self.navigationController?.pushViewController(VC, animated: true)
        }else{
            self.mainCollect.makeToast("请输入有效内容")
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.view.endEditing(true)
    }
    
    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(200)
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr![indexPath.section];
            let model = listModel.list![indexPath.row]
            if(model.type == 4 || model.type == 3){
                // 番剧
                let VC = PadNetVideoPlayerViewController.init()
                VC.dataArr = (self.allVideoArr[1] as! [[VideoModel]])
                VC.model = model
                self.navigationController?.pushViewController(VC, animated: true)
            }else{
                let VC = LocalVideoPlayerViewController.init()
                VC.model = model
                VC.modalPresentationStyle = .fullScreen
                self.present(VC, animated: true, completion: nil)
            }
        }
        mainCollection.headerRightClicked = { indexPath in
            let model = mainCollection.listArr![indexPath.section]
            let VC = HaliTVVideoViewController.init()
            VC.title = model.title
            self.navigationController?.pushViewController(VC, animated: true)
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
            let listModel1 = ListModel.init()
            listModel1.title = "本地视频"
            listModel1.more = false
            listModel1.list = localArr
            var videoArr:[ListModel] = [listModel1]
            self.allVideoArr [0] = videoArr
            self.mainCollect.listArr = videoArr
    //        for item:VideoModel in localArr {
    //            print("视频名字是\(item.name),时长是\(item.time)")
    //        }
            // 相册视频
            ftool.getPhoneVideo()
            ftool.getPhoneVideoComplete = { result in
                let listModel2 = ListModel.init()
                listModel2.title = "相册视频"
                listModel2.list = result
                listModel2.more = false
                videoArr.append(listModel2)
                self.allVideoArr[0] = videoArr
                DispatchQueue.main.async {
                    self.mainCollect.listArr = videoArr
                }
            }
        }else{
            let videoArr:[ListModel] = self.allVideoArr[0] as! [ListModel]
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
        self.searchView.isHidden = true
        let array:[[VideoModel]] = self.allVideoArr[1] as! [[VideoModel]]
        mainCollect.listArr = []
        mainCollect.reloadData()
        if array.count == 0 {
            mainCollect.makeToastActivity(.center)
            let dataManager = DataManager.init()
//            dataManager.getBangumiData { (dataArr) in
//                self.mainCollect.hideToastActivity()
//                self.allVideoArr[self.tableIndex] = dataArr
//                self.chooseView.index = 0
//            } failure: { (error) in
//                DispatchQueue.main.async {
//                    self.mainCollect.hideToastActivity()
//                    self.mainCollect.makeToast("获取数据失败")
//                }
//                print(error)
//            }
        }else{
            self.chooseView.index = 0
        }
    }
    
    // 获取哈哩tv数据
    func getHaliTVData(){
        mainCollect.snp.remakeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
            make.left.equalTo(searchView.snp.left)
        }
        self.chooseView.isHidden = true
        self.searchView.isHidden = false
        let array:[ListModel] = self.allVideoArr[2] as! [ListModel]
        mainCollect.listArr = []
        mainCollect.reloadData()
        if array.count == 0 {
            mainCollect.makeToastActivity(.center)
            /*
            DataManager.init().getHaliTVData(urlStr: "https://www.halitv.com/",
                                             type: 1) { (resultArr, page) in
                self.mainCollect.hideToastActivity()
                self.allVideoArr[self.tableIndex] = resultArr
                self.mainCollect.listArr = resultArr
            }
 */
        }else{
            mainCollect.listArr = array
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
