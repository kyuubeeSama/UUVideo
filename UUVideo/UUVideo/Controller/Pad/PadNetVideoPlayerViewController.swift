//
//  PadNetVIdeoPlayerViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/21.
//  Copyright © 2020 qykj. All rights reserved.
//  pad端webview播放页面

import UIKit
import WebKit
import SideMenu
import ESPullToRefresh
import GRDB

class PadNetVideoPlayerViewController: BaseViewController {
    var model: VideoModel?
    var dataArr: [[VideoModel]]?
    var listArr: [ListModel]?
    var is_collect: Bool = false
    var collectItem:UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNav()
        self.reloadWebView()
        let databasePath = FileTool.init().getDocumentPath() + "/.database.db"
        let dbQueue = try? DatabaseQueue(path: databasePath)
        try? dbQueue?.write { db in
            try? db.execute(sql: """
                                 REPLACE INTO history ('name','url',add_time) VALUES(:name,:url,:add_time)
                                 """, arguments: [model?.name, "https://www.halitv.com/" + (model?.detailUrl)!, Date.getCurrentTimeInterval()])
        }

        self.getData()
    }

    func reloadWebView() {
        webView.makeToastActivity(.center)
        webView.load(URLRequest.init(url: URL.init(string: self.getUrl())!))
    }

    func getUrl() -> String {
        var urlStr = model?.detailUrl?.replacingOccurrences(of: ".html", with: "-1-1.html")
        urlStr = urlStr?.replacingOccurrences(of: "detail", with: "play")
        return "https://www.halitv.com/" + urlStr!
    }

    func setNav() {
        let baritem = UIBarButtonItem.init(image: UIImage.init(systemName: "slider.horizontal.3"), style: .done, target: self, action: #selector(leftSideMenu))
        let databasePath = FileTool.init().getDocumentPath() + "/.database.db"
        let dbQueue = try? DatabaseQueue(path: databasePath)
        // 从数据库查询当前视频是否收藏
        var imageName = "star"
        do{
            try dbQueue?.read { db in
                if (try Row.fetchOne(db, sql: """
                                                          SELECT * FROM collect WHERE name = :name and url = :url
                                                          """, arguments: [model?.name, "https://www.halitv.com/" + (model?.detailUrl)!])) != nil {
                    // 已收藏
                    is_collect = true
                    imageName = "star.fill"
                } else {
                    // 未收藏
                    is_collect = false
                }

            }
        }catch {
            print(error.localizedDescription)
        }
        
        self.collectItem = UIBarButtonItem.init(image: UIImage.init(systemName: imageName), style: .done, target: self, action: #selector(collect))
        navigationItem.rightBarButtonItems = [baritem, self.collectItem!]
    }

    @objc func collect() {
        // 修改按钮图片
        let databasePath = FileTool.init().getDocumentPath() + "/.database.db"
        let dbQueue = try? DatabaseQueue(path: databasePath)
        if self.is_collect {
            // 取消收藏
            try? dbQueue?.write { db in
                try db.execute(sql: """
                                    DELETE FROM collect WHERE name = :name and url = :url
                                    """, arguments: [model?.name, "https://www.halitv.com/" + (model?.detailUrl)!])
            }
            is_collect = false
            self.collectItem?.image = UIImage.init(systemName: "star")
        } else {
            // 添加收藏
            try? dbQueue?.write { db in
                try db.execute(sql: """
                                     INSERT INTO collect ('name','url',add_time) VALUES(:name,:url,:add_time)
                                    """, arguments: [model?.name, "https://www.halitv.com/" + (model?.detailUrl)!, Date.getCurrentTimeInterval()])
            }
            is_collect = true
            self.collectItem?.image = UIImage.init(systemName: "star.fill")
        }
    }

    // 获取推荐视频
    func getData() {
        DataManager.init().getVideoDetailData(urlStr: self.getUrl()) { (videoArr) in
            let model = ListModel.init()
            model.title = "猜你喜欢"
            model.list = videoArr
            self.listArr = [model]
        }
    }

    @objc func leftSideMenu() {
        if self.listArr!.count > 0 {
            let VC = RightViewController.init()
            VC.listArr = self.listArr
            VC.cellItemSelected = { indexPath in
                let listModel = self.listArr![0]
                let model = listModel.list![indexPath.row]
                self.model = model
                self.reloadWebView()
                self.dismiss(animated: true, completion: nil)
            }
            let menu = SideMenuNavigationController(rootViewController: VC)
            menu.presentationStyle = .menuSlideIn
            menu.menuWidth = 375
            present(menu, animated: true, completion: nil)
        }
    }

    lazy var webView: QYWebView = {
        let config = WKWebViewConfiguration.init()
        let preference = WKPreferences.init()
        preference.minimumFontSize = 0
        preference.javaScriptEnabled = true
        preference.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preference
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        let webView = QYWebView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: config)
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        return webView
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
