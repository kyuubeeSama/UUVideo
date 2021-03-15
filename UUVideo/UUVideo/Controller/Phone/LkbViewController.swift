//
//  LkbViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/11/2.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class LkbViewController: BaseViewController,UISearchBarDelegate {

    var listArr:[ListModel]?
    var isSearch:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "来快播"
        // 获取哈哩tv数据
        self.getVideoData()
    }
    
    func getVideoData(){
        self.view.makeToastActivity(.center)
        DispatchQueue.global().async {
            DataManager.init().getWebsiteIndexData(type: .laikuaibo) { (dataArr) in
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.mainCollect.listArr = dataArr
                }
            } failure: { (error) in
                print(error)
            }
        }
    }
    
    // 添加搜索
    lazy var searchBar:UISearchBar = {
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
        self.view.endEditing(true)
        if searchBar.text!.count>0 {
            let VC = SearchResultViewController.init()
            VC.keyword = searchBar.text
            VC.websiteValue = .laiKuaiBo
            self.navigationController?.pushViewController(VC, animated: true)
        }else{
            self.view.makeToast("请输入有效内容")
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
            VC.videoModel = listModel.list![indexPath.row]
            self.navigationController?.pushViewController(VC, animated: true)
        }
        mainCollection.headerRightClicked = { indexPath in
            // 根据选中的行跳转对应页面
            print(indexPath.section)
            let model = mainCollection.listArr![indexPath.section]
            let VC = LkbVideoViewController.init()
            VC.title = model.title
            self.navigationController?.pushViewController(VC, animated: true)
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
