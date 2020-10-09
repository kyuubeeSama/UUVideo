//
//  HaliTVVideoViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/9.
//  Copyright © 2020 qykj. All rights reserved.
//  halitv 具体分类视频列表
// 右上角类型筛选按钮,上拉加载,总页码显示，以及页码跳转

import UIKit

class HaliTVVideoViewController: BaseViewController {

    var pageNum:Int = 1
    var videoType:String = ""
    var area:String = "__"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 类型+国家+页码
//        https://www.halitv.com/list/tvban_129__riben____3.html
        // 类型+页码
//        https://www.halitv.com/list/tvban_129______3.html
        // 页码
//        https://www.halitv.com/list/tvban______3.html
        self.setNav()
        self.getListData()
    }
    
    func setNav(){
        let rightItem = UIBarButtonItem.init(title: "筛选", style: .plain, target: self, action: #selector(rightBtnClick))
        self.navigationItem.rightBarButtonItem = rightItem
    }

    @objc func rightBtnClick(){
//        HaliTVCategoryView
    }
    
    func getListData(){
        var urlStr:String
        switch self.title {
        case "tv动画":
            urlStr = "https://www.halitv.com/list/tvban"
        case "剧场版":
            urlStr = "https://www.halitv.com/list/juchangban"
        case "电影":
            urlStr = "https://www.halitv.com/list/dianying"
        default:
            //剧集
            urlStr = "https://www.halitv.com/list/dianshiju"
        }
        // 添加页码信息
        urlStr += "\(videoType)\(area)____\(pageNum).html"
        print(urlStr)
        DataManager.init().getHaliTVData(urlStr: urlStr,
                                         type: 2) { (resultArr) in
            
        }
    }
    
    lazy var mainCollect: VideoListCollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let mainCollection = VideoListCollectionView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), collectionViewLayout: layout)
        self.view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        mainCollection.cellItemSelected = { indexPath in
            let listModel = mainCollection.listArr![indexPath.section]
            let VC = NetVideoPlayerViewController.init()
            VC.model = listModel.list![indexPath.row]
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
