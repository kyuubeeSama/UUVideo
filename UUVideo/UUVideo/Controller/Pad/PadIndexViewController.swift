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

class PadIndexViewController: BaseViewController, UISearchBarDelegate {
    var allVideoArr: [[Any]] = [[], [], []]
    var tableIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            let path = FileTool.init().getDocumentPath().appending("/video")
            _ = try FileTool.init().createDirectory(path: path)
        } catch (let error) {
            print(error)
        }
        mainTable.listArr = indexArr
        view.bringSubviewToFront(localView)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeRotate(notice:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
    }
        
    @objc func showUser() {
        print("显示个人中心")
        let VC = UserViewController.init()
        let menu = SideMenuNavigationController(rootViewController: VC)
        menu.presentationStyle = .menuSlideIn
        menu.menuWidth = 375
        menu.leftSide = true
        present(menu, animated: true, completion: nil)
    }

    @objc func didChangeRotate(notice: Notification) {
        // TODO:此处用于重新适配
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
            let string = mainTable.listArr[indexPath.section].list[indexPath.row]
            // 点击切换数据源
            if (string == "本地视频") {
                self.view.bringSubviewToFront(self.localView)
            } else if (string == "新番时间表") {
                self.view.bringSubviewToFront(self.bangumiView)
            } else if (string == "哈哩哈哩") {
                self.view.bringSubviewToFront(self.haliView)
            } else if (string == "樱花动漫") {
                self.view.bringSubviewToFront(self.sakuraView)
            } else if(string == "笨猪"){
                self.view.bringSubviewToFront(self.benpigView)
            } else if (string == "历史记录"){
                self.view.bringSubviewToFront(self.historyView)
            } else if(string == "我的收藏"){
                self.view.bringSubviewToFront(self.collectView)
            } else if (string == "来快播") {
                self.view.bringSubviewToFront(self.laikuaiboView)
            }
        }
        return mainTable
    }()
    // 右侧显示内容
//    三个controller的view，选择后将制定的view放在前台
    lazy var localView: UIView = {
        getView(controller: PhoneVideoListViewController.init())
    }()

    lazy var bangumiView: UIView = {
        getView(controller: BangumiViewController.init())
    }()
    
    lazy var historyView: UIView = {
        getView(controller: HistoryViewController.init())
    }()
    
    lazy var collectView: UIView = {
        getView(controller: CollectViewController.init())
    }()
    
    lazy var haliView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .halihali
        return getView(controller:VC)
    }()

    lazy var sakuraView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .sakura
        return getView(controller:VC)
    }()
    
    lazy var laikuaiboView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .laikuaibo
        return getView(controller:VC)
    }()
    
    lazy var benpigView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .benpig
        return getView(controller: VC)
    }()
    
    func getView(controller: UIViewController) -> UIView {
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(self.view)
            make.left.equalToSuperview().offset(200);
        }
        return controller.view
    }

}
