//
//  SearchListViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/29.
//  Copyright © 2023 qykj. All rights reserved.
//

import UIKit
import JXSegmentedView
import UICollectionViewLeftAlignedLayout
class SearchListViewController: BaseViewController,JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        view
    }
    public var webType:websiteType = .halihali
    public var keyword = ""
    private var pageNum = 1
    private var listArr: [ListModel] = []
    private var searchArr: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getSearchData()
    }

    func getSearchData (){
        view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getSearchData(pageNum: self.pageNum, keyword: self.keyword, website: self.webType) { (dataArr) in
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
            self.getSearchData()
        }
        return mainCollection
    }()
}
