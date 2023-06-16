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
    var getHtmlContentComplete:((_ htmlStr:String) -> ())?

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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let doc = "document.body.outerHTML"
        webView.evaluateJavaScript(doc) { htmlStr, error in
            if self.getHtmlContentComplete != nil {
                self.getHtmlContentComplete!(htmlStr as! String)
            }
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr: String = navigationAction.request.url!.absoluteString
        print("当前地址是" + urlStr)
        if urlStr.contains("m3u8"){
            if getVideoUrlComplete != nil{
               getVideoUrlComplete!(urlStr)
                decisionHandler(.cancel)
            }
        }
        decisionHandler(.allow)
    }


}
