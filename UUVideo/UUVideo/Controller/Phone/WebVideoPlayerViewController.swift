//
//  NetVideoPlayerViewController.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/18.
//  Copyright © 2020 qykj. All rights reserved.
// 视频网页地址

import UIKit
import WebKit
import SnapKit
class WebVideoPlayerViewController: BaseViewController {

    var model:VideoModel?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var urlStr = model?.detailUrl?.replacingOccurrences(of: ".html", with: "-1-1.html")
        urlStr = urlStr?.replacingOccurrences(of: "detail", with: "play")
        webView.makeToastActivity(.center)
        webView.load(URLRequest.init(url: URL.init(string: "https://m.halitv.com/"+urlStr!)!))
//        webView.scrollView.es.addPullToRefresh { [self] in
//            webView.reload()
//            webView.scrollView.es.stopPullToRefresh()
//        }
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
