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
        urlStr = ["http://halihali2.com/", "https://www.laikuaibo.com/"][webType.rawValue]
        if webType == .halihali {
            area = "all"
            videoCategory = "0"
            year = "0"
            switch title {
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
        } else {
            videoType = "1"
            switch title {
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
        }
        if webType == .halihali {
            setNav()
            getCategoryData()
        }
        getListData()
    }

    func setNav() {
        let rightItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(rightBtnClick))
        navigationItem.rightBarButtonItem = rightItem
    }

    // 右键筛选
    @objc func rightBtnClick() {
//        HaliTVCategoryView
        if categoryListArr.count > 0 {
            // 滑出筛选界面
            let VC = CategoryChooseViewController.init()
            VC.listArr = categoryListArr
            let menu = SideMenuNavigationController(rootViewController: VC)
            menu.presentationStyle = .menuSlideIn
            menu.menuWidth = screenW * 0.9
            present(menu, animated: true, completion: nil)
            VC.sureBtnReturn = { [self] resultArr in
                print(resultArr)
                videoCategory = resultArr[0]
                year = resultArr[1]
                area = resultArr[2]
                pageNum = 1
                listArr = []
                getCategoryData()
                getListData()
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
        } else {
            detailUrlStr = urlStr + "list-select-id-\(videoType)-area-\(area)-order-\(order)-p-\(pageNum).html"
        }
        DispatchQueue.global().async {
            DataManager.init().getVideoListData(urlStr: detailUrlStr, type: self.webType) { (dataArr: [ListModel]) in
                DispatchQueue.main.async {
                    if (dataArr[0].list!.count > 0) {
                        self.pageNum += 1
                        self.mainCollect.es.stopLoadingMore()
                    } else {
                        self.mainCollect.es.noticeNoMoreData()
                    }
                    self.listArr.append(contentsOf: dataArr)
                    self.mainCollect.listArr = self.listArr
                }
            } failure: { (error) in
                print(error)
            }
        }
    }

//     获取分类信息
    func getCategoryData() {
//        http://halihali2.com/mov/0/0/all/1.html
        DataManager.init().getWebsiteCategoryData(urlStr: urlStr + "\(videoType)/\(year)/\(videoCategory)/\(area)/\(pageNum).html", type: .halihali) { (dataArr) in
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
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr![indexPath.section]
            let VC = NetVideoDetailViewController.init()
            VC.videoModel = listModel.list![indexPath.row]
            VC.webType = self.webType
            self.navigationController?.pushViewController(VC, animated: true)
        }
        mainCollection.es.addInfiniteScrolling {
            self.getListData()
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
