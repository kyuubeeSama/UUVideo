//
//  PhoneIndexViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//  首页地址

import UIKit
import SnapKit

class PhoneIndexViewController: BaseViewController {
    
    @objc func injected(){
        viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 创建video文件夹
        title = "悠悠视频"
        do {
            let path = FileTool.init().getDocumentPath().appending("/video")
            _ = try FileTool.init().createDirectory(path: path)
        } catch (let error) {
            print(error)
        }
        mainTable.listArr = indexArr
    }

    lazy var mainTable: WebsiteTableView = {
        let table = WebsiteTableView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), style: .insetGrouped)
        self.view.addSubview(table)
        table.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        table.cellItemDidSelect = { indexPath in
            let model = table.listArr[indexPath.section].list[indexPath.row]
            let string = model.title
            if (string == "新番时间表") {
                let VC = BangumiViewController.init()
                self.navigationController?.pushViewController(VC, animated: true)
            } else if (string == "本地视频") {
                let VC = PhoneVideoListViewController.init()
                self.navigationController?.pushViewController(VC, animated: true)
            } else if (string == "历史记录") {
                let VC = HistoryViewController.init()
                self.navigationController?.pushViewController(VC, animated: true)
            } else if (string == "我的收藏") {
                let VC = CollectViewController.init()
                self.navigationController?.pushViewController(VC, animated: true)
            } else if(string == "聚合搜索"){
                let VC = SearchIndexViewController.init()
                self.navigationController?.pushViewController(VC, animated: true)
            }
            else {
                let VC = NetVideoIndexViewController.init()
                VC.webType = model.webType
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
        return table
    }()

}
