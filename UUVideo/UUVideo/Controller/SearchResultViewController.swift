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

    var keyword: String?
    var pageNum: Int = 1
    var webType: websiteType?
    var listArr: [ListModel] = []
    var searchArr: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getResultList()
    }

    //获取搜索数据
    func getResultList() {
        var urlStr: String?
        if webType! == .halihali {
            urlStr = "http://www.halihali2.com/search.php"
        } else if webType! == .laikuaibo {
            urlStr = "https://www.laikuaibo.com/vod-search-wd-" + keyword! + "-p-\(pageNum).html"
        }
        DispatchQueue.global().async {
            DataManager.init().getSearchData(urlStr: urlStr!, keyword: self.keyword!, website: self.webType!) { (dataArr) in
                DispatchQueue.main.async {
                    if self.checkSearchResult(searchArr: dataArr) {
                        self.pageNum += 1
                        self.mainCollect.es.stopLoadingMore()
                        if self.listArr.count > 0 {
                            let model = self.listArr[0]
                            let resultModel = dataArr[0]
                            model.list! += resultModel.list!
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
            }
        }
    }

    // 判断是否有重复的内容
    func checkSearchResult(searchArr: [ListModel]) -> Bool {
        if searchArr.count > 0 {
            let resultModel = searchArr[0]
            for videoModel in resultModel.list! {
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
            VC.videoModel = listModel.list![indexPath.row]
            VC.webType = self.webType!
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
