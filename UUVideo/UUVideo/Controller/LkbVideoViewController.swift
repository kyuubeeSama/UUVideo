//
//  ZdzyVideoViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/3.
//  Copyright © 2020 qykj. All rights reserved.
//  最大资源网视频列表

import UIKit
import SideMenu
class LkbVideoViewController: BaseViewController {
    
    var pageNum:Int = 1
    // 类型
    var videoType:String = "1"
    // 地区
    var area:String = ""
    // 排序
    var order:String = ""
    var urlStr = "https://www.laikuaibo.com/"
    var listArr:[ListModel] = []
    var categoryListArr:[CategoryListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        https://www.laikuaibo.com/list-select-id-\(id)-area-\(area)-order-\(order)-p-(\pagenum).html
        switch self.title {
        case "电影":
            videoType = "1"
        case "剧集":
            videoType = "2"
        case "综艺":
            videoType = "4"
        case "动漫":
            videoType = "3"
        default:
            //剧集
            videoType = "19"
        }
//        self.setNav()
        self.getListData()
//        self.getCategoryData()
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
                pageNum = 1
                self.listArr = []
                self.getListData()
                self.getCategoryData()
            }
        }
    }
    //    获取列表信息
    func getListData(){
        DataManager.init().getLkbData(urlStr: urlStr+"list-select-id-\(videoType)-area-\(area)-order-\(order)-p-\(pageNum).html",
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
        DataManager.init().getLkbCategoryData(urlStr: urlStr+"list-select-id-\(videoType)-area-\(area)-order-\(order)-p-\(pageNum).html)") { (resutlArr) in
            self.categoryListArr = resutlArr
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
            let VC = NetVideoDetailViewController.init()
            VC.videoModel = listModel.list![indexPath.row]
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
