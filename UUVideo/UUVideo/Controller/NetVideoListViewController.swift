//
//  NetVideoListViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2021/3/16.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit
import SideMenu
import ESPullToRefresh
import Toast_Swift

class NetVideoListViewController: BaseViewController {

    public var webType: websiteType = .halihali
    private var pageNum: Int = 1
    // 视频类型
    private var videoType: String = ""
    // 电影地区
    private var area: String = ""
    // 剧情
    private var videoCategory: String = ""
    // 年份
    private var year: String = ""
    // 排序
    var order: String = ""
    private var urlStr: String = ""
    private var listArr: [ListModel] = []
    private var categoryListArr: [CategoryListModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pageNum = webType == .benpig ? 0 : 1
        urlStr = [
            "http://halihali2.com/",
            "https://www.laikuaibo.com/",
            "http://www.yhdm.so/",
            "http://www.benpig.com/"
        ][webType.rawValue]
        let videoTypeData = [
            ["电视剧": "tv", "动漫": "acg", "电影": "mov", "综艺": "zongyi"],
            ["电影": "1", "剧集": "2", "综艺": "4", "动漫": "3", "伦理": "19"],
            ["日本动漫": "japan", "国产动漫": "china", "欧美动漫": "american", "动漫电影": "movie"],
            ["电影":"1","电视剧":"2","综艺":"3","动漫":"4"]
        ]
        if webType == .halihali {
            area = "all"
            videoCategory = "0"
            year = "0"
        } else {
            videoType = "1"
        }
        videoType = videoTypeData[webType.rawValue][title!]!
        if webType == .halihali || webType == .benpig{
            if webType == .benpig{
                videoCategory = "0"
                year = "0"
                area = "0"
            }
            setNav()
            getCategoryData()
        } else if webType == .sakura {
            setNav()
            categoryListArr = CategoryModel.getSakuraCategoryData()
            for listModel in categoryListArr {
                for model in listModel.list {
                    if model.value == videoType {
                        model.ischoose = true
                    }
                }
            }
        }
        getListData()
    }

    func setNav() {
        let rightItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(rightBtnClick))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    // 如果是macos，底部添加bottomview
    lazy var pageView: PageView = {
        let pageView = PageView.init()
        view.addSubview(pageView)
        pageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
        pageView.pageBtnClickBlock = { nextPageNum in
            self.pageNum = nextPageNum
            self.listArr = []
            self.getListData()
        }
        return pageView
    }()
        
    // 右键筛选
    @objc func rightBtnClick() {
//        HaliTVCategoryView
        if categoryListArr.count > 0 {
            // 滑出筛选界面
            let VC = CategoryChooseViewController.init()
            VC.type = webType
            VC.listArr = categoryListArr
            if Tool.isPhone() {
                let menu = SideMenuNavigationController(rootViewController: VC)
                menu.presentationStyle = .menuSlideIn
                menu.menuWidth = screenW * 0.9
                present(menu, animated: true, completion: nil)
            } else {
                VC.view.bounds = CGRect(x: 0, y: 0, width: Tool.isPad() ? screenW-80 : 500, height: 500);
                view.window?.QY_ShowPopView(popStyle: .center, popView: VC.view, offset: CGPoint(x: 0, y: 0), dismissWhenClickCoverView: true, isBlur: false, alpha: 0.3)
            }
            VC.sureBtnReturn = { [self] resultArr in
                if Tool.isPhone() {
                    VC.dismiss(animated: true)
                } else {
                    view.window?.wb_dismissPopView(popStyle: .center, completion: {})
                }
                print(resultArr)
                if webType == .sakura {
                    videoType = resultArr[0]
                } else if webType == .halihali{
                    videoCategory = resultArr[0]
                    year = resultArr[1]
                    area = resultArr[2]
                }else if webType == .benpig {
                    videoCategory = resultArr[1]
                    year = resultArr[2]
                    area = resultArr[0]
                }
                mainCollect.es.resetNoMoreData()
                pageNum = webType == .benpig ? 0 : 1
                listArr = []
                if webType == .halihali{
                    getCategoryData()
                }
                getListData()
            }
            VC.bottomView.cancelBtnBlock = {
                if Tool.isPhone() {
                    VC.dismiss(animated: true)
                } else {
                    self.view.window?.wb_dismissPopView(popStyle: .center, completion: {})
                }
            }
        } else {
            view.makeToast("未获取到筛选数据")
        }
    }
    
//    获取列表信息
    func getListData() {
        var detailUrlStr = ""
        if webType == .halihali {
            detailUrlStr = "http://121.4.190.96:9991/getsortdata_all_z.php?action=\(videoType)&page=\(pageNum)&year=\(year)&area=\(area)&class=\(videoCategory)&dect=&id="
        } else if webType == .laikuaibo {
//            detailUrlStr = urlStr + "list-select-id-\(videoType)-area-\(area)-order-\(order)-addtime-p-\(pageNum).html"
            detailUrlStr = urlStr + "list-select-id-\(videoType)-area--order-addtime-p-\(pageNum).html"
        } else if webType == .sakura{
            var pageInfo = ""
            if pageNum > 1 {
                pageInfo = "\(pageNum).html"
            }
            detailUrlStr = urlStr + "\(videoType)/" + pageInfo
        }else{
            detailUrlStr = urlStr+"type/\(videoType)-\(videoCategory)-\(area)-\(year)-0-\(pageNum).html"
        }
        view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getVideoListData(urlStr: detailUrlStr, type: self.webType) { listData, allPageNum in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    if (listData[0].list.count > 0) {
                        self.pageNum += 1
                        self.mainCollect.es.stopLoadingMore()
                    } else {
                        self.mainCollect.es.noticeNoMoreData()
                    }
                    if self.listArr.count > 0 {
                        self.listArr[0].list.append(array: listData[0].list)
                    } else {
                        self.listArr.append(contentsOf: listData)
                    }
                    self.mainCollect.listArr = self.listArr
                    if Tool.isMac(){
                        self.mainCollect.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                        self.pageView.allPageNum = allPageNum
                    }
                }
            } failure: { error in
                print(error)
                DispatchQueue.main.async {
                    self.view.makeToast("获取视频列表失败")
                }
            }
        }
    }

//     获取分类信息
    func getCategoryData() {
//        http://halihali2.com/mov/0/0/all/1.html
        var categoryUrlStr:String = ""
        if webType == .halihali {
            categoryUrlStr = urlStr + "\(videoType)/\(year)/\(videoCategory)/\(area)/\(pageNum).html"
        }else if webType == .benpig {
            categoryUrlStr = urlStr+"type/\(videoType)-0-0-0-0-0.html"
        }
        DataManager.init().getWebsiteCategoryData(urlStr: categoryUrlStr, type: webType) { (dataArr) in
            self.categoryListArr = dataArr
        } failure: { (error) in
            print(error)
        }
    }

    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            if Tool.isMac(){
                make.bottom.equalToSuperview().offset(-60)
            }else{
                make.bottom.equalToSuperview()
            }
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr![indexPath.section]
            let VC = NetVideoDetailViewController.init()
            VC.videoModel = listModel.list[indexPath.row]
            self.navigationController?.pushViewController(VC, animated: true)
        }
        if !Tool.isMac(){
            mainCollection.es.addInfiniteScrolling(animator: headerAnimator) {
                self.getListData()
            }
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
