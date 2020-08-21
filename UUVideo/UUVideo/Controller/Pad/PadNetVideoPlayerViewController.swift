//
//  PadNetVIdeoPlayerViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/21.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import WebKit
import SideMenu
import ESPullToRefresh
class PadNetVideoPlayerViewController: BaseViewController {
    var model:VideoModel?
    var dataArr:[[VideoModel]]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNav()
        self.reloadWebView()
//        webView.scrollView.es.addPullToRefresh{ [self] in
//            webView.reload()
//            webView.scrollView.es.stopPullToRefresh()
//        }
    }
    
    func reloadWebView(){
        var urlStr = model?.detailUrl?.replacingOccurrences(of: ".html", with: "-1-1.html")
        urlStr = urlStr?.replacingOccurrences(of: "detail", with: "play")
        webView.makeToastActivity(.center)
        webView.load(URLRequest.init(url: URL.init(string: "https://www.halitv.com/"+urlStr!)!))
    }
    
    func setNav(){
        let baritem = UIBarButtonItem.init(image: UIImage.init(systemName: "slider.horizontal.3"), style: .done, target: self, action: #selector(leftSideMenu))
        self.navigationItem.rightBarButtonItem = baritem
    }
    
    @objc func leftSideMenu(){
        let VC = RightViewController.init()
        VC.dataArr = self.dataArr
        VC.cellIitemSelected = { indexPath in
            let array:[VideoModel] = self.dataArr![indexPath.section]
            let model = array[indexPath.row]
            self.model = model
            self.reloadWebView()
            self.dismiss(animated: true, completion: nil)
        }
        let menu = SideMenuNavigationController(rootViewController: VC)
        menu.presentationStyle = .menuSlideIn
        present(menu, animated: true, completion: nil)
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
