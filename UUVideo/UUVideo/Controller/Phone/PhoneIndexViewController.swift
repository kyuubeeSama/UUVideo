//
//  PhoneIndexViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import SnapKit
class PhoneIndexViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 创建video文件夹
        do{
            let path = FileTool.init().getDocumentPath().appending("/video")
            _ = try FileTool.init().createDirectory(path: path)
        }catch (let error){
            print(error)
        }
        print(FileTool.init().getDocumentPath())
        self.mainTable.listArr = ["本地视频","新番时间表","哈哩TV"]
    }
    
    lazy var mainTable: WebsiteTableView = {
        let table = WebsiteTableView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), style: .plain)
        self.view.addSubview(table)
        table.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        table.cellItemDidSelect = { indexPath in
            let string = table.listArr![indexPath.row]
            if(string == "新番时间表"){
                let VC = BangumiViewController.init()
                self.navigationController?.pushViewController(VC, animated: true)
            }else{
                let VC = PhoneVideoListViewController.init()
                VC.website = indexPath.row+1
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
        return table
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
