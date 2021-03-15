//
//  HaliTVVideoViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/9.
//  Copyright © 2020 qykj. All rights reserved.
//  halitv 具体分类视频列表
// 右上角类型筛选按钮,上拉加载

import UIKit
import SideMenu

class HaliTVVideoViewController: BaseViewController {

    var pageNum:Int = 1
    // 视频类型
    var videoType:String = ""
    // 电影地区
    var area:String = "all"
    // 剧情
    var videoCategory:String = "0"
    // 年份
    var year:String = "0"
    
    var urlStr = "http://halihali2.com/"
    var listArr:[ListModel] = []
    var categoryListArr:[CategoryListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch self.title {
        case "电视剧":
            videoType = "tv"
        case "动漫":
            videoType = "acg"
        case "电影":
            videoType = "mov"
        default:
            //综艺
            videoType = "zongyi"
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
            VC.sureBtnReturn = { [self] resultArr in
                print(resultArr)
                videoCategory = resultArr[0]
                year = resultArr[1]
                area = resultArr[2]
                pageNum = 1
                self.listArr = []
                self.getCategoryData()
                self.getListData()
            }
        }else{
            self.view.makeToast("未获取到筛选数据")
        }
    }
//    获取列表信息
    func getListData(){
        let detailUrlStr = "http://121.4.190.96:9991/getsortdata_all_z.php?action=\(videoType)&page=\(pageNum)&year=\(year)&area=\(area)&class=\(videoCategory)&dect=&id="
        DataManager.init().getVideoListData(urlStr: detailUrlStr, type: .halihali) { (dataArr:[ListModel]) in
            if(dataArr[0].list!.count>0){
                self.pageNum += 1
                self.mainCollect.es.stopLoadingMore()
            }else{
                self.mainCollect.es.noticeNoMoreData()
            }
            self.listArr.append(contentsOf: dataArr)
            self.mainCollect.listArr = self.listArr
        } failure: { (error) in
            print(error)
        }
    }
//     获取分类信息
    func getCategoryData(){
//        http://halihali2.com/mov/0/0/all/1.html
        DataManager.init().getWebsiteCategoryData(urlStr: urlStr+"\(videoType)/\(year)/\(videoCategory)/\(area)/\(pageNum).html", type: .halihali) { (dataArr) in
            self.categoryListArr = dataArr
        } failure: { (error) in
            print(error)
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
            let VC = WebVideoPlayerViewController.init()
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
