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

    var keyword:String?
    var pageNum:Int = 1
    var webType:websiteType?
    var listArr:[ListModel] = []
    var searchArr:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getResultList()
        self.getMoreData()
    }
    
    //获取搜索数据
    func getResultList(){
        var urlStr:String?
        if self.webType! == .halihali {
            urlStr = "https://www.halitv.com/search/"+keyword!+"-\(pageNum).html"
        }else if webType! == .laikuaibo{
//            https://www.laikuaibo.com/vod-search-wd-%E5%A4%A9-p-2.html
            urlStr = "https://www.laikuaibo.com/vod-search-wd-"+keyword!+"-p-\(pageNum).html"
        }
        DataManager.init().getSearchData(urlStr: urlStr!, keyword: self.keyword!, website: self.webType!) { (resultArr) in
            if self.checkSearchResult(searchArr: resultArr) {
                self.pageNum += 1
                self.mainCollect.es.stopLoadingMore()
                if self.listArr.count > 0{
                    let model = self.listArr[0]
                    let resultModel = resultArr[0]
                    model.list! += resultModel.list!
                }else{
                    self.listArr.append(contentsOf: resultArr)
                }
                self.mainCollect.listArr = self.listArr
            }else{
                self.mainCollect.es.noticeNoMoreData()
            }
        }
    }
    
    // 判断是否有重复的内容
    func checkSearchResult(searchArr:[ListModel]) -> Bool {
        if searchArr.count > 0 {
            let resultModel = searchArr[0]
            for videoModel in resultModel.list! {
                if self.searchArr.contains(videoModel.detailUrl!) {
                    // 已存在，说明已经到底了，结束循环
                    // 因为每次出现重复，说明是整页的重复，表明整页都是无用数据
                    return false
                }else{
                    self.searchArr.append(videoModel.detailUrl!)
                }
            }
            return true
        }else{
            return false
        }
    }
    
    // 获取更多数据
    func getMoreData(){
        self.mainCollect.es.addInfiniteScrolling {
            self.getResultList()
        }
    }
    
    // 搜索结果列表
    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr![indexPath.section]
            if self.webType! == .laikuaibo{
                let VC = NetVideoDetailViewController.init()
                VC.videoModel = listModel.list![indexPath.row]
                self.navigationController?.pushViewController(VC, animated: true)
            }else if self.webType! == .halihali{
                let VC = WebVideoPlayerViewController.init()
                VC.model = listModel.list![indexPath.row]
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
        mainCollection.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString.init(string: "当前搜索无数据"))
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
