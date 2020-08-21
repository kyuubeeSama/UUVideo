//
//  QYWebView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/19.
//  Copyright © 2020 qykj. All rights reserved.
//  webView

import UIKit
import WebKit
class QYWebView: WKWebView,WKUIDelegate,WKNavigationDelegate{
    //TODO:更新到使用result类型
    var getHtmlData:((_ success:String,_ failure:String)->())?
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.uiDelegate = self
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideToastActivity()
//        webView.evaluateJavaScript("document.body.outerHTML") { (htmlstr, error) in
//            print(htmlstr)
//        }
//        NSString *doc = @"document.body.outerHTML";
//           [self.myWebView evaluateJavaScript:doc
//                            completionHandler:^(id _Nullable htmlStr, NSError * _Nullable error) {
//               if (error) {
//                  NSLog(@"JSError:%@",error);
//               }
//               NSLog(@"html:%@",htmlStr);
//           }] ;
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideToastActivity()
        if self.getHtmlData != nil {
            self.getHtmlData!("","加载失败")
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        print(url)
        var jsString:String
        if Tool.isPad() {
            jsString = "document.getElementsByClassName(\"header\")[0].style.display = \"none\";\n document.getElementsByClassName(\"ty-header\")[0].style.display = \"none\";\n document.getElementsByClassName(\"footer\")[0].style.display = \"none\";\n document.getElementsByClassName(\"layui-row\")[1].style.display = \"none\";\n document.getElementsByClassName(\"layui-row\")[2].style.display = \"none\";\n document.getElementsByClassName(\"layout-right\")[0].style.display = \"none\";"
        }else{
            jsString = "document.getElementsByClassName(\"head\")[0].style.display = \"none\";\n document.getElementsByClassName([\"headernav\"])[0].style.display = \"none\";\n document.getElementsByTagName([\"header\"])[0].style.height = 0;document.getElementsByClassName([\"mod\"])[2].style.display = \"none\";"
        }
        webView.evaluateJavaScript(jsString) { (result, error) in
            
        }
        if url!.contains("hali") {
            decisionHandler(.allow)
        }else{
            decisionHandler(.cancel)
        }
    }
}
