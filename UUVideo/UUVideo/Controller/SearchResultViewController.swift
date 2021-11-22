//
//  SearchResultViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/19.
//  Copyright © 2020 qykj. All rights reserved.
//  哈哩TV搜索结果列表页

import UIKit
import EmptyDataSet_Swift

class SearchResultViewController: BaseViewController {

    var keyword: String = ""
    var pageNum: Int = 1
    var webType: websiteType = .halihali
    var listArr: [ListModel] = []
    var searchArr: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setNavColor(navColor: .white, titleColor: .black, barStyle: .default)
        getResultList()
    }

    //获取搜索数据
    func getResultList() {
        self.view.makeToastActivity(.center)
        if webType == .benpig{
            let webView = UUWebView.init()
            view.addSubview(webView)
            let body = "show=title%2Cstarring&tbname=movie&tempid=1&keyboard=\(keyword)"
            var request = URLRequest.init(url: URL.init(string: "http://www.benpig.com/e/search/index.php")!)
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = body.data(using: .utf8)
            webView.load(request)
            webView.getVideoUrlComplete = { urlStr in
                self.getSearchData(urlStr: urlStr)
            }
        }else{
            var urlStr: String?
            if webType == .halihali {
                urlStr = "http://www.halihali2.com/search.php"
            } else if webType == .laikuaibo {
                urlStr = "https://www.laikuaibo.com/vod-search-wd-" + keyword + "-p-\(pageNum).html"
            }else if webType == .sakura{
                urlStr = "http://www.yhdm.so/search/\(keyword)/?page=\(pageNum)"
            }
            getSearchData(urlStr: urlStr!)
        }
    }

    func getSearchData (urlStr:String){
        DispatchQueue.global().async {
            DataManager.init().getSearchData(urlStr: urlStr, keyword: self.keyword, website: self.webType) { (dataArr) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    if self.webType == .benpig || self.webType == .halihali{
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
                if self.searchArr.contains(videoModel.detailUrl!) {
                    // 已存在，说明已经到底了，结束循环
                    // 因为每次出现重复，说明是整页的重复，表明整页都是无用数据
                    return false
                } else {
                    self.searchArr.append(videoModel.detailUrl!)
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
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { [self] indexPath in
            let listModel = mainCollection.listArr![indexPath.section]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
