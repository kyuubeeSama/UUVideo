//
//  HaliTVSearchResultViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/19.
//  Copyright © 2020 qykj. All rights reserved.
//  哈哩TV搜索结果列表页

import UIKit
import EmptyDataSet_Swift
class HaliTVSearchResultViewController: BaseViewController {

    var keyword:String?
    var pageNum:Int = 1
    var listArr:[ListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getResultList()
        self.getMoreData()
    }
    
    //获取搜索数据
    func getResultList(){
//        https://www.halitv.com/search/%E9%A3%9F%E6%88%9F%E4%B9%8B%E7%81%B5-1.html
        let urlStr = "https://www.halitv.com/search/"+self.keyword!+"-\(self.pageNum).html"
        DataManager.init().getHaliTVSearchData(urlStr: urlStr, keyword: self.keyword!) { (resultArr) in
            if(resultArr.count>0){
                self.pageNum += 1
                self.mainCollect.es.stopLoadingMore()
            }else{
                self.mainCollect.es.noticeNoMoreData()
            }
            self.listArr.append(contentsOf: resultArr)
            self.mainCollect.listArr = self.listArr
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
            let VC = WebVideoPlayerViewController.init()
            VC.model = listModel.list![indexPath.row]
            self.navigationController?.pushViewController(VC, animated: true)
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
