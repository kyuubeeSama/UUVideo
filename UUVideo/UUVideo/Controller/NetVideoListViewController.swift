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
    public var videoCategoryIndex = 0
    private var pageNum: Int = 1
    // 电影地区
    private var area: String = ""
    // 剧情
    private var videoCategory: String = ""
    // 年份
    private var year: String = ""
    // 排序
    var order: String = ""
    private var urlStr: String {
        urlArr[webType.rawValue]
    }
    private var listArr: [ListModel] = []
    private var categoryListArr: [CategoryListModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if webType == .halihali {
            area = "all"
            videoCategory = "0"
            year = "0"
        }
        if webType == .halihali || webType == .juzhixiao || webType == .qihaolou || webType == .SakuraYingShi || webType == .sakura {
            if webType == .juzhixiao {
                videoCategory = "mcid-0"
                year = "year-0"
                area = "area-0"
            }
            setNav()
            getCategoryData()
        }
        getListData()
    }

    func setNav() {
//        setNavColor(navColor: .systemBackground, titleColor: UIColor.init(.dm, light: .black, dark: .white), barStyle: .default)
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
                VC.view.bounds = CGRect(x: 0, y: 0, width: Tool.isPad() ? screenW - 80 : 500, height: 500);
                view.window?.QY_ShowPopView(popStyle: .center, popView: VC.view, offset: CGPoint(x: 0, y: 0), dismissWhenClickCoverView: true, isBlur: false, alpha: 0.3)
            }
            VC.sureBtnReturn = { [self] resultArr in
                if Tool.isPhone() {
                    VC.dismiss(animated: true)
                } else {
                    view.window?.wb_dismissPopView(popStyle: .center, completion: {})
                }
                if webType == .sakura {
//                    videoType = resultArr[0]
                    year = resultArr[0]
                    area = resultArr[1]
                    videoCategory = resultArr[2]
                } else if webType == .halihali {
                    videoCategory = resultArr[0]
                    year = resultArr[1]
                    area = resultArr[2]
                } else if webType == .juzhixiao {
                    videoCategory = resultArr[1]
                    year = resultArr[2]
                    area = resultArr[0]
                } else if webType == .mianfei {
                    videoCategory = resultArr[0]
                    year = resultArr[2]
                    area = resultArr[1]
                } else if webType == .qihaolou {
                    videoCategory = resultArr[0]
                    area = resultArr[1]
                    year = resultArr[2]
                } else if webType == .SakuraYingShi {
                    area = resultArr[0]
                    year = resultArr[1]
                    videoCategory = resultArr[2]
                }
                mainCollect.es.resetNoMoreData()
                pageNum = 1
                listArr = []
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
        view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getVideoListData(videoTypeIndex: self.videoCategoryIndex, category: (area: self.area, year: self.year, videoCategory: self.videoCategory), type: self.webType, pageNum: self.pageNum) { listData in
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
                }
            } failure: { error in
                print(error)
                DispatchQueue.main.async {
                    self.view.hideAllToasts()
                    self.view.makeToast("获取视频列表失败")
                }
            }
        }
    }

//     获取分类信息
    func getCategoryData() {
        DataManager.init().getWebsiteCategoryData(videoTypeIndex: self.videoCategoryIndex, type: webType) { (dataArr) in
            self.categoryListArr = dataArr
        } failure: { (error) in
            print(error)
            self.view.makeToast("获取分类失败")
        }
    }

    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            if Tool.isMac() {
                make.bottom.equalToSuperview().offset(-60)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr[indexPath.section]
            let VC = NetVideoDetailViewController.init()
            VC.videoModel = listModel.list[indexPath.row]
            self.navigationController?.pushViewController(VC, animated: true)
        }
        if !Tool.isMac() {
            mainCollection.es.addInfiniteScrolling(animator: headerAnimator) {
                self.getListData()
            }
        }
        return mainCollection
    }()

}
