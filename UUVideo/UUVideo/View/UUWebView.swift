//
//  UUWebView.swift
//  UUVideo
//
//  Created by Galaxy on 2021/3/16.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit
import WebKit

class UUWebView: WKWebView, WKNavigationDelegate, WKUIDelegate {
    var getVideoUrlComplete: ((_ videoUrl: String) -> ())?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        uiDelegate = self
        navigationDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("加载失败")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr: String = navigationAction.request.url!.absoluteString
        print("当前地址是" + urlStr)
//        判断当前地址格式，是否包换视频地址，如果包换，将视频地址返回
//        通过mplay获取到播放地址，通过获取参数地址，获取播放地址
//        http://op.mtyee.com:7788/f/mf/mplay.php?url=https://1251316161.vod2.myqcloud.com/007a649dvodcq1251316161/b51a3aa55285890810876304015/Sj8ugapLLuUA.mp4&i4=300
        if urlStr.contains("mplay.php") {
            // 是目标播放地址
            let valueDic = Tool.getKeyValueFromUrl(urlStr: urlStr)
            if getVideoUrlComplete != nil {
                getVideoUrlComplete!(valueDic["url"]!)
            }
        }else if urlStr.contains("search"){
            if getVideoUrlComplete != nil {
                getVideoUrlComplete!(urlStr)
            }
        }
        decisionHandler(.allow)
    }


}
