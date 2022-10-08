//
//  BangumiViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/17.
//  Copyright © 2020 qykj. All rights reserved.
//  新番地址

import UIKit
import SnapKit
import JXSegmentedView

class BangumiViewController: BaseViewController, JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {

    let segmentedDataSource = JXSegmentedTitleDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }

    func makeUI() {
        let segmentedView = JXSegmentedView.init()
        segmentedView.delegate = self
        view.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(40)
        }

        segmentedDataSource.titles = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]
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
        let VC = BangumiListViewController.init()
        VC.index = index
        return VC
    }

}
