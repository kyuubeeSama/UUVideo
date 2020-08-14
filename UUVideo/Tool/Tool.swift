//
//  Tool.swift
//  InsuranceDemo
//
//  Created by liuqingyuan on 2019/12/2.
//  Copyright © 2019 qykj. All rights reserved.
//

import UIKit
import Kingfisher
class Tool:NSObject {
    
    static func calculateSize(size:UInt)->String{
        var cache = ""
        if size < 1000{
            cache = "0.00M"
        }else if size > 1000 && size < 1000*1000{
            cache = String.init(format: "%0.2fk", CGFloat(size)/1000.0)
        }else{
            cache = String.init(format: "%0.2fM", CGFloat(size)/1000.0/1000.0)
        }
        return cache
    }
        
    /// 1.打电话  2.发短信
    static func callOrSendMessage(phoneNum:String,type:Int,failure:@escaping(_ error:String)->()){
        if phoneNum.isMobilePhone(){
            let deviceType = UIDevice.current.model
            if deviceType == "iPod touch" || deviceType ==
                "iPad" || (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1){
                failure("当前设备不支持打电话")
            }else{
                var str = ""
                if type == 1{
                    str = "tel:"+phoneNum
                }else{
                    str = "sms:"+phoneNum
                }
                let dic:Dictionary<UIApplication.OpenExternalURLOptionsKey,Any> = [:]
                UIApplication.shared.open(URL.init(string: str)!, options: dic) { (success) in
                    
                }
            }
        }
    }
    
    // 谓词正则筛选
    static func showSystemAlert(viewController:UIViewController,title:String,message:String,sureBtnClick:@escaping(()->())) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let sureAction = UIAlertAction.init(title: "确定", style: .default) { (sureAction) in
            sureBtnClick()
        }
        alert.addAction(sureAction)
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (cancelAction) in
            
        }
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    // TODO:正则表达式筛选
    // TODO:获取相册视频
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
