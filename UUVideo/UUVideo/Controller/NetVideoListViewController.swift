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
        urlStr = ["http://halihali2.com/", "https://www.laikuaibo.com/", "http://www.yhdm.so/"][webType.rawValue]
        let videoTypeData = [["电视剧":"tv","动漫":"acg","电影":"mov","综艺":"zongyi"],["电影":"1","剧集":"2","综艺":"4","动漫":"3","伦理":"19"],["日本动漫":"japan","国产动漫":"china","美国动漫":"american","动漫电影":"movie"]]
        if webType == .halihali {
            area = "all"
            videoCategory = "0"
            year = "0"
        } else {
            videoType = "1"
        }
        videoType = videoTypeData[webType.rawValue][title!]!
        if webType == .halihali {
            setNav()
            getCategoryData()
        }else if webType == .sakura {
            setNav()
            self.categoryListArr = CategoryModel.getSakuraCategoryData()
            for listModel in self.categoryListArr {
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

    // 右键筛选
    @objc func rightBtnClick() {
//        HaliTVCategoryView
        if categoryListArr.count > 0 {
            // 滑出筛选界面
            let VC = CategoryChooseViewController.init()
            VC.type = self.webType
            VC.listArr = categoryListArr
            let menu = SideMenuNavigationController(rootViewController: VC)
            menu.presentationStyle = .menuSlideIn
            menu.menuWidth = screenW * 0.9
            present(menu, animated: true, completion: nil)
            VC.sureBtnReturn = { [self] resultArr in
                print(resultArr)
                if self.webType == .sakura {
                    videoType = resultArr[0]
                }else{
                    videoCategory = resultArr[0]
                    year = resultArr[1]
                    area = resultArr[2]
                }
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
        } else if webType == .laikuaibo {
            detailUrlStr = urlStr + "list-select-id-\(videoType)-area-\(area)-order-\(order)-p-\(pageNum).html"
        }else{
            var pageInfo = ""
            if pageNum>1 {
                pageInfo = "\(pageNum).html"
            }
            detailUrlStr = urlStr + "\(videoType)/"+pageInfo
        }
        DispatchQueue.global().async {
            DataManager.init().getVideoListData(urlStr: detailUrlStr, type: self.webType) { (dataArr: [ListModel]) in
                DispatchQueue.main.async {
                    if (dataArr[0].list.count > 0) {
                        self.pageNum += 1
                        self.mainCollect.es.stopLoadingMore()
                    } else {
                        self.mainCollect.es.noticeNoMoreData()
                    }
                    if self.listArr.count > 0{
                        self.listArr[0].list.append(array: dataArr[0].list)
                    }else{
                        self.listArr.append(contentsOf: dataArr)
                    }
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
            VC.videoModel = listModel.list[indexPath.row]
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
