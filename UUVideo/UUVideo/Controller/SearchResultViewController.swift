//
//  SearchResultViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/19.
//  Copyright © 2020 qykj. All rights reserved.
//  哈哩TV搜索结果列表页

import UIKit
import EmptyDataSet_Swift
import UICollectionViewLeftAlignedLayout
class SearchResultViewController: BaseViewController {

    var keyword: String = ""
    var pageNum: Int = 1
    var webType: websiteType = .halihali
    var listArr: [ListModel] = []
    var searchArr: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setNav()
        getResultList()
    }

    func setNav() {
        title = keyword
//        setNavColor(navColor: .systemBackground, titleColor: UIColor.init(.dm, light: .black, dark: .white), barStyle: .default)
    }
    
    //获取搜索数据
    func getResultList() {
        view.makeToastActivity(.center)
            var urlStr = ""
            if webType == .halihali {
                urlStr = Halihali.init().webUrlStr+"search.php"
            } else if webType == .laikuaibo {
                urlStr = Laikuaibo.init().webUrlStr+"vod-search-wd-" + keyword + "-p-\(pageNum).html"
            }else if webType == .sakura{
                urlStr = Sakura.init().webUrlStr+"search/\(keyword)/?page=\(pageNum)"
            }else if webType == .juzhixiao{
                urlStr = Juzhixiao.init().webUrlStr+"search/"+keyword+"-\(pageNum).html"
            }else if webType == .mianfei{
                urlStr = Mianfei.init().webUrlStr+"search/-------------.html?wd=\(keyword)"
            }else if webType == .qihaolou{
                urlStr = Qihaolou.init().webUrlStr+"vodsearch/----------\(pageNum)---.html?wd=\(keyword)"
            }else if webType == .SakuraYingShi{
                urlStr = SakuraYingShi.init().webUrlStr+"search?kw=\(keyword)&page=\(pageNum-1)"
            }else if webType == .Yklunli{
                urlStr = Yklunli.init().webUrlStr+"vod-search-wd-\(keyword)-p-\(pageNum).html"
            }else if webType == .sixMovie{
                urlStr = SixMovie.init().webUrlStr+"vodsearch/\(keyword)----------\(pageNum)---.html"
            }else if webType == .sese{
                urlStr = SeSe.init().webUrlStr+"vodsearch/\(keyword)----------\(pageNum)---.html"
            }else if webType == .thotsflix{
                urlStr = Thotsflix.init().webUrlStr+"page/\(pageNum)/?search_param=all&s=\(keyword)"
            }
        getSearchData(urlStr: urlStr)
    }

    func getSearchData (urlStr:String){
        DispatchQueue.global().async {
            DataManager.init().getSearchData(urlStr: urlStr, keyword: self.keyword, website: self.webType) { (dataArr) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    if self.webType == .halihali{
                        self.mainCollect.es.noticeNoMoreData()
                    }
                    if self.checkSearchResult(searchArr: dataArr) {
                        self.pageNum += 1
                        self.mainCollect.es.stopLoadingMore()
                        if self.listArr.count > 0 {
                            let model = self.listArr[0]
                            let resultModel = dataArr[0]
                            model.list += resultModel.list
                        } else {
                            self.listArr.append(contentsOf: dataArr)
                        }
                        self.mainCollect.listArr = self.listArr
                    } else {
                        self.mainCollect.es.noticeNoMoreData()
                    }
                }
            } failure: { (error) in
                print(error)
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.mainCollect.es.noticeNoMoreData()
                }
            }
        }
    }
    
    // 判断是否有重复的内容
    func checkSearchResult(searchArr: [ListModel]) -> Bool {
        if searchArr.count > 0 {
            let resultModel = searchArr[0]
            for videoModel in resultModel.list {
                if self.searchArr.contains(videoModel.detailUrl) {
                    // 已存在，说明已经到底了，结束循环
                    // 因为每次出现重复，说明是整页的重复，表明整页都是无用数据
                    return false
                } else {
                    self.searchArr.append(videoModel.detailUrl)
                }
            }
            return true
        } else {
            return false
        }
    }

    // 搜索结果列表
    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewLeftAlignedLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.is_hiddenTitle = false
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { [self] indexPath in
            let listModel = mainCollection.listArr[indexPath.section]
            let VC = NetVideoDetailViewController.init()
            VC.videoModel = listModel.list[indexPath.row]
            self.navigationController?.pushViewController(VC, animated: true)
        }
        mainCollection.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString.init(string: "当前搜索无数据"))
        }
        mainCollection.es.addInfiniteScrolling {
            self.getResultList()
        }
        return mainCollection
    }()

}
