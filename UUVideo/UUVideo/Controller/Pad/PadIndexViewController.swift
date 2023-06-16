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
            let model = mainTable.listArr[indexPath.section].list[indexPath.row]
            let string = model.title
            // 点击切换数据源
            if model.type == 0 {
                if (string == "本地视频") {
                    self.view.bringSubviewToFront(self.localView)
                } else if (string == "新番时间表") {
                    self.view.bringSubviewToFront(self.bangumiView)
                } else if (string == "历史记录") {
                    self.view.bringSubviewToFront(self.historyView)
                } else if (string == "我的收藏") {
                    self.view.bringSubviewToFront(self.collectView)
                } else if(string == "聚合搜索") {

                }
            } else {
                switch model.webType {
                case .halihali:
                    self.view.bringSubviewToFront(self.haliView)
                case .laikuaibo:
                    self.view.bringSubviewToFront(self.laikuaiboView)
                case .sakura:
                    self.view.bringSubviewToFront(self.sakuraView)
                case .juzhixiao:
                    self.view.bringSubviewToFront(self.juzhixiaoView)
                case .mianfei:
                    self.view.bringSubviewToFront(self.mianfeiView)
                case .qihaolou:
                    self.view.bringSubviewToFront(self.qihaolouView)
                case .SakuraYingShi:
                    self.view.bringSubviewToFront(self.sakuraYingshiView)
                case .Yklunli:
                    self.view.bringSubviewToFront(self.YklunliView)
                case .sixMovie:
                    self.view.bringSubviewToFront(self.sixMovieView)
                case .lawyering:
                    self.view.bringSubviewToFront(self.lawyering)
                case .sese:
                    self.view.bringSubviewToFront(self.lawyering)
                case .cechi:
                    self.view.bringSubviewToFront(self.lawyering)
                }
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
        return getView(controller: VC)
    }()
    lazy var sakuraYingshiView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .SakuraYingShi
        return getView(controller: VC)
    }()
    lazy var YklunliView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .Yklunli
        return getView(controller: VC)
    }()
    lazy var sakuraView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .sakura
        return getView(controller: VC)
    }()
    lazy var lawyering: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .lawyering
        return getView(controller: VC)
    }()
    lazy var laikuaiboView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .laikuaibo
        return getView(controller: VC)
    }()
    lazy var juzhixiaoView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .juzhixiao
        return getView(controller: VC)
    }()
    lazy var mianfeiView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .mianfei
        return getView(controller: VC)
    }()
    lazy var qihaolouView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .qihaolou
        return getView(controller: VC)
    }()
    lazy var sixMovieView: UIView = {
        let VC = NetVideoIndexViewController.init()
        VC.webType = .sixMovie
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
