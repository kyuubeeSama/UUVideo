//
//  HaliTVVideoViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/9.
//  Copyright © 2020 qykj. All rights reserved.
//  halitv 具体分类视频列表
// 右上角类型筛选按钮,上拉加载,总页码显示，以及页码跳转

import UIKit
import SideMenu

class HaliTVVideoViewController: BaseViewController {

    var pageNum:Int = 1
    // 电影类型
    var videoType:String = "_"
    // 电影地区
    var area:String = "__"
    // 电影分类
    var videoCategory:String = ""
    var urlStr = "https://www.halitv.com/list/"
    var listArr:[ListModel] = []
    var categoryListArr:[CategoryListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 类型+地区+页码
//        https://www.halitv.com/list/tvban_129__riben____3.html
        // 类型+页码
//        https://www.halitv.com/list/tvban_129______3.html
        // 页码
//        https://www.halitv.com/list/tvban______3.html
        switch self.title {
        case "tv动画":
            videoCategory = "tvban"
        case "剧场版":
            videoCategory = "juchangban"
        case "电影":
            videoCategory = "dianying"
        default:
            //剧集
            videoCategory = "dianshiju"
        }
        self.setNav()
        self.getListData()
        self.getCategoryData()
        self.getMoreData()
    }
    
    func setNav(){
        let rightItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(rightBtnClick))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    // 右键筛选
    @objc func rightBtnClick(){
//        HaliTVCategoryView
        if self.categoryListArr.count>0 {
            // 滑出筛选界面
            let VC = CategoryChooseViewController.init()
            VC.listArr = self.categoryListArr
            let menu = SideMenuNavigationController(rootViewController: VC)
            menu.presentationStyle = .menuSlideIn
            menu.menuWidth = screenW*0.9
            present(menu, animated: true, completion: nil)
            VC.sureBtnReturn = { [self] resultDic in
                print(resultDic)
                //            videoCategory videoType area
                videoCategory = resultDic["videoCategory"]!
                videoType = "_"+resultDic["videoType"]!
                area = "__"+resultDic["area"]!
                pageNum = 1
                self.listArr = []
                self.getListData()
                self.getCategoryData()
            }
        }
    }
//    获取列表信息
    func getListData(){
        DataManager.init().getHaliTVData(urlStr: urlStr+"\(videoCategory)\(videoType)\(area)____\(pageNum).html",
                                         type: 2) { (resultArr, page) in
            if(resultArr.count>0){
                self.pageNum += 1
                self.mainCollect.es.stopLoadingMore()
            }else{
                self.mainCollect.es.noticeNoMoreData()
            }
            self.listArr.append(contentsOf: resultArr)
            self.mainCollect.listArr = self.listArr
        }
    }
//     获取分类信息
    func getCategoryData(){
        DataManager.init().getHaliTVCategoryData(urlStr: urlStr+"\(videoCategory)\(videoType)\(area)____\(pageNum).html") { (resultArr) in
            self.categoryListArr = resultArr
        }
    }
    
    func getMoreData(){
        self.mainCollect.es.addInfiniteScrolling {
            self.getListData()
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
            let listModel = mainCollection.listArr![indexPath.section]
            let VC = NetVideoPlayerViewController.init()
            VC.model = listModel.list![indexPath.row]
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
