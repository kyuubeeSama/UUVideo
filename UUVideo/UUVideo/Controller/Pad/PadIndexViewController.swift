//
//  PadIndexViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/17.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import SnapKit
import FluentDarkModeKit
import SideMenu
class PadIndexViewController: BaseViewController,UISearchBarDelegate {
    var allVideoArr:[[Any]] = [[],[],[]]
    var tableIndex:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do{
            let path = FileTool.init().getDocumentPath().appending("/video")
            _ = try FileTool.init().createDirectory(path: path)
        }catch (let error){
            print(error)
        }
        self.mainTable.listArr = ["本地视频","新番时间表","哈哩哈哩"]
        self.view.bringSubviewToFront(self.localView)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeRotate(notice:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
        // 添加右侧图片
//        let item = UIBarButtonItem.init(image: UIImage.init(systemName: "person.circle"), style: .plain, target: self, action: #selector(showUser))
//        self.navigationItem.leftBarButtonItem = item
    }
    
    @objc func showUser(){
        print("显示个人中心")
        let VC = UserViewController.init()
        let menu = SideMenuNavigationController(rootViewController: VC)
        menu.presentationStyle = .menuSlideIn
        menu.menuWidth = 375
        menu.leftSide = true
        present(menu, animated: true, completion: nil)
    }
    
    @objc func didChangeRotate(notice:Notification){
//        bangumiView.layoutIfNeeded()
        //        chooseView.refreshView()
    }
    // 左侧按钮
    lazy var mainTable: WebsiteTableView = {
        let mainTable = WebsiteTableView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH), style: .plain)
        self.view.addSubview(mainTable)
        mainTable.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        mainTable.cellItemDidSelect = { [self] indexPath in
            self.view.endEditing(true)
            self.tableIndex = indexPath.row
            let string = mainTable.listArr![indexPath.row]
            // 点击切换数据源
            if(string == "本地视频"){
                self.view.bringSubviewToFront(self.localView)
            }else if(string == "新番时间表"){
                self.view.bringSubviewToFront(self.bangumiView)
            }else if(string == "哈哩哈哩"){
                self.view.bringSubviewToFront(self.haliView)
            }
        }
        return mainTable
    }()
    // 右侧显示内容
//    三个controller的view，选择后将制定的view放在前台
    lazy var localView:UIView = {
        return getView(controller: PhoneVideoListViewController.init())
    }()
    
    lazy var bangumiView: UIView = {
        return getView(controller: BangumiViewController.init())
    }()
    
    lazy var haliView: UIView = {
        return getView(controller: NetVideoIndexViewController.init())
    }()
    
    func getView(controller:UIViewController) -> UIView {
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.view.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(self.view)
            make.left.equalToSuperview().offset(200);
        }
        return controller.view
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
