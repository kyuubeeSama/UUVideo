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
    private var urlStr: String {
        urlArr[webType.rawValue]
    }
    private var listArr: [ListModel] = []
    private var categoryListArr: [CategoryListModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let videoTypeData = [
            ["电视剧": "tv", "动漫": "acg", "电影": "mov", "综艺": "zongyi"],
            ["电影": "1", "剧集": "2", "综艺": "4", "动漫": "3", "伦理": "19"],
            ["日本动漫": "japan", "国产动漫": "china", "欧美动漫": "american", "动漫电影": "movie"],
            ["电视剧":"2","电影":"1","综艺":"4","动漫":"3"],
            ["电影":"dy","电视剧":"tv","综艺":"zy","动漫":"dm"],
            ["电影":"dianying","电视剧":"lianxuju","综艺":"zongyi","动漫":"dongman"],
            ["电视剧":"电视剧","电影":"电影","动漫":"动漫","综艺":"综艺"],
            ["韩国伦理":"1","日本伦理":"2","欧美伦理":"3","香港伦理":"4"],
            ["电影":"1","电视剧":"6","综艺":"I","动漫":"u","福利":"i"],
            ["中文":"1","欧美":"2","动漫":"3","主播":"4","制服":"5","人妻":"6","美乳":"7","伦理":"8"],
            ["精品推荐":"4","主播秀色":"5","日本有码":"6","日本无码":"7","中文字幕":"8","强奸乱伦":"9","三级伦理":"16","卡通动漫":"17","丝袜OL":"18","自拍偷拍":"19","传媒系列":"20","女同人妖":"21","国产精品":"22"],
            ["默认":"0"],
        ]
        if webType == .halihali {
            area = "all"
            videoCategory = "0"
            year = "0"
        } else {
            videoType = "1"
        }
//    https://www.qybfb.com/index.php?s=home-vod-type-id-2-mcid-114-area-泰国-year-2022-letter--order--picm-1-p-1
        videoType = videoTypeData[webType.rawValue][title!]!
        if webType == .halihali || webType == .juzhixiao || webType == .qihaolou || webType == .SakuraYingShi{
            if webType == .juzhixiao{
                videoCategory = "mcid-0"
                year = "year-0"
                area = "area-0"
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
                VC.view.bounds = CGRect(x: 0, y: 0, width: Tool.isPad() ? screenW-80 : 500, height: 500);
                view.window?.QY_ShowPopView(popStyle: .center, popView: VC.view, offset: CGPoint(x: 0, y: 0), dismissWhenClickCoverView: true, isBlur: false, alpha: 0.3)
            }
            VC.sureBtnReturn = { [self] resultArr in
                if Tool.isPhone() {
                    VC.dismiss(animated: true)
                } else {
                    view.window?.wb_dismissPopView(popStyle: .center, completion: {})
                }
                if webType == .sakura {
                    videoType = resultArr[0]
                } else if webType == .halihali{
                    videoCategory = resultArr[0]
                    year = resultArr[1]
                    area = resultArr[2]
                }else if webType == .juzhixiao {
                    videoCategory = resultArr[1]
                    year = resultArr[2]
                    area = resultArr[0]
                }else if webType == .mianfei {
                    videoCategory = resultArr[0]
                    year = resultArr[2]
                    area = resultArr[1]
                }else if webType == .qihaolou {
                    videoCategory = resultArr[0]
                    area = resultArr[1]
                    year = resultArr[2]
                }else if webType == .SakuraYingShi {
                    area = resultArr[0]
                    year = resultArr[1]
                    videoCategory = resultArr[2]
                }
                mainCollect.es.resetNoMoreData()
                pageNum = 1
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
        }else if webType == .juzhixiao{
            // 剧知晓
            detailUrlStr = urlStr + "index.php?s=home-vod-type-id-\(videoType)-\(videoCategory)--\(area)--\(year)--letter--order--picm-1-p-\(pageNum)"
        }else if webType == .mianfei {
            if pageNum == 1 {
                detailUrlStr = urlStr + videoType
            } else {
                detailUrlStr = urlStr + videoType + "/index_\(pageNum).html"
            }
//            if area.isEmpty && videoCategory.isEmpty && year.isEmpty {
//                detailUrlStr = urlStr + "/"+videoType
//            }else{
//                detailUrlStr = urlStr+"haokan/\(videoType)-\(videoCategory)----------\(year).html"
//            }
        }else if webType == .qihaolou {
            if  area.isEmpty && videoCategory.isEmpty && year.isEmpty{

                detailUrlStr = urlStr+"vodshow/\(videoType)--------\(pageNum)---.html"
            }else{
                //            https://qhlou.com/vodshow/dongzuopian-%E5%A4%A7%E9%99%86----------2020.html
                detailUrlStr = urlStr + "vodshow/\(videoCategory)-\(area)-------\(pageNum)---\(year).html"
            }
        }else if webType == .SakuraYingShi {
            detailUrlStr = urlStr + "v/type/\(videoType)-\(area)-\(year)-\(videoCategory)-----0-24.html?order=&page=\(pageNum-1)&size=24"
            detailUrlStr = detailUrlStr.replacingOccurrences(of: " ", with: "")
        }else if webType == .Yklunli {
            detailUrlStr = urlStr + "list-select-id-\(videoType)-type--area--year--star--state--order-addtime-p-\(pageNum).html";
        }else if webType == .sixMovie {
            detailUrlStr = urlStr + "vodshow/\(videoType)MMM1--------\(pageNum)---.html"
        }else if webType == .lawyering {
            detailUrlStr = urlStr+"index.php/vod/type/id/\(videoType)/page/\(pageNum).html"
        }else if webType == .sese {
            detailUrlStr = urlStr+"/vodtype/\(videoType)-\(pageNum).html"
        }else if webType == .thotsflix{
            detailUrlStr = urlStr+"/page/\(pageNum)/"
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
                    self.view.hideAllToasts()
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
        }else if webType == .juzhixiao {
//            categoryUrlStr = urlStr+"type/\(videoType)-0-0-0-0-0.html"
            categoryUrlStr = urlStr + "index.php?s=home-vod-type-id-\(videoType)-mcid--area--year--letter--order--picm-1-p-\(pageNum)"
        }else if webType == .mianfei {
            categoryUrlStr = urlStr + "/\(videoType)/"
        }else if webType == .qihaolou {
            categoryUrlStr = urlStr+"vodtype/\(videoType).html"
        }else if webType == .SakuraYingShi {
            categoryUrlStr = urlStr+"v/type/--------0-24.html"
        }else if webType == .Yklunli {
            categoryUrlStr = urlStr+"list-select-id-1-type--area--year--star--state--order-addtime-p-1.html";
        }
        DataManager.init().getWebsiteCategoryData(urlStr: categoryUrlStr, type: webType) { (dataArr) in
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
            if Tool.isMac(){
                make.bottom.equalToSuperview().offset(-60)
            }else{
                make.bottom.equalToSuperview()
            }
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr[indexPath.section]
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

}
