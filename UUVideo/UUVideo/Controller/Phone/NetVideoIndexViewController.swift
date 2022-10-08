//
//  NetVideoIndexViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2021/3/16.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit
import Kingfisher

class NetVideoIndexViewController: BaseViewController, UISearchBarDelegate {

    var listArr: [ListModel] = []
    var isSearch: Bool = false
    var webType: websiteType = .halihali
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ImageCache.default.clearMemoryCache()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = ["哈哩哈哩", "来快播","樱花动漫","笨猪"][webType.rawValue]
        // 获取哈哩tv数据
        getVideoData()
    }

    func getVideoData() {
        view.makeToastActivity(.center)
        DispatchQueue.global().async { [self] in
            DataManager.init().getWebsiteIndexData(type: webType) { (dataArr) in
                DispatchQueue.main.async {
                    view.hideToastActivity()
                    mainCollect.listArr = dataArr
                }
            } failure: { (error) in
                print(error)
                DispatchQueue.main.async {
                    view.hideToastActivity()
                }
            }
        }
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
            let VC = SearchResultViewController.init()
            VC.keyword = searchBar.text!
            VC.webType = webType
            navigationController?.pushViewController(VC, animated: true)
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

    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)

        mainCollection.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.searchBar.snp.bottom)
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr![indexPath.section]
            let VC = NetVideoDetailViewController.init()
            VC.videoModel = listModel.list[indexPath.row]
            self.navigationController?.pushViewController(VC, animated: true)
        }
        mainCollection.headerRightClicked = { indexPath in
            // 根据选中的行跳转对应的分类列表
            print(indexPath.section)
            let model = mainCollection.listArr![indexPath.section]
            let VC = NetVideoListViewController.init()
            VC.title = model.title
            VC.webType = self.webType
            self.navigationController?.pushViewController(VC, animated: true)
        }
        return mainCollection
    }()

}
