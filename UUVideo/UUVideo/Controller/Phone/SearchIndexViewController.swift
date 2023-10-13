//
//  SearchIndexViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2023/1/29.
//  Copyright © 2023 qykj. All rights reserved.
//  聚合搜索页

import UIKit
import JXSegmentedView

class SearchIndexViewController: BaseViewController, UISearchBarDelegate, JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    let segmentedDataSource = JXSegmentedTitleDataSource()
    let segmentedView = JXSegmentedView.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        makeUI()
    }
    lazy var titleArr: [String] = {
        [
            Halihali.init().websiteName,
            Laikuaibo.init().websiteName,
            Sakura.init().websiteName,
            Mianfei.init().websiteName,
            Qiqi.init().websiteName,
            KanYing.init().websiteName
        ]
    }()
    lazy var modelArr: [IndexModel] = {
        indexArr[1].list
    }()
    func makeUI() {
        segmentedView.delegate = self
        view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        segmentedDataSource.titles = titleArr
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titleNormalColor = UIColor.init(.dm, light: .black, dark: .white)
        segmentedView.dataSource = segmentedDataSource
        let indicator = JXSegmentedIndicatorLineView()
        segmentedView.indicators = [indicator]
        let listContainerView = JXSegmentedListContainerView(dataSource: self)
        view.addSubview(listContainerView)
        //关联listContainer
        segmentedView.listContainer = listContainerView
        listContainerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(segmentedView.snp.bottom)
        }
    }
    //返回列表的数量
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        segmentedDataSource.titles.count
    }
    //返回遵从`JXSegmentedListContainerViewListDelegate`协议的实例
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let VC = SearchListViewController.init()
        VC.webType = modelArr[index].webType
        VC.keyword = searchBar.text ?? ""
        return VC
    }
    // 添加搜索
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar.init()
        self.view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        return searchBar
    }()
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if searchBar.text!.count > 0 {
            // 搜索数据
            segmentedView.reloadData()
        } else {
            view.makeToast("请输入有效内容")
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}
