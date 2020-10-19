//
//  BaseViewController.swift
//  swiftdemo
//
//  Created by liuqingyuan on 2018/11/12.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

import UIKit
import Toast_Swift

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        文件保存成功
        NotificationCenter.default.addObserver(self, selector: #selector(FileSaveSuccessNotification(notification:)), name: NSNotification.Name(rawValue: "FileSaveSuccessNotification"), object: nil)
        // 文件保存失败
        NotificationCenter.default.addObserver(self, selector: #selector(FileSaveFieldFileNotification(notification:)), name: NSNotification.Name(rawValue: "FileSaveFieldFileNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FileExistsNotification(notification:)), name: NSNotification.Name(rawValue: "FileExistsNotification"), object: nil)
        
        self.view.backgroundColor = UIColor.systemBackground
        
    }
    @objc func FileSaveSuccessNotification(notification:Notification){
        let info = notification.userInfo
        let fileName:String = info!["fileName"] as! String
        Tool.showSystemAlert(viewController:self,title: "提示", message: "文件\(fileName)保存成功") {
        }
    }
    @objc func FileSaveFieldFileNotification(notification:Notification){
        let info = notification.userInfo
        let fileName:String = info!["fileName"] as! String
        Tool.showSystemAlert(viewController:self,title: "提示", message: "文件\(fileName)保存失败") {
        }
    }
    
    @objc func FileExistsNotification(notification:Notification){
        let info = notification.userInfo
        let fileName:String = info!["fileName"] as! String
        Tool.showSystemAlert(viewController:self,title: "提示", message: "文件\(fileName)已存在") {
        }
    }
    
    func setNavColor(navColor:UIColor,titleColor:UIColor,barStyle:UIBarStyle) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = barStyle
        self.navigationController?.navigationBar.barTintColor = navColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:titleColor]
        self.navigationController?.navigationBar.tintColor = titleColor
        if #available(iOS 13.0, *) {
            let statusBarView = UIView(frame: view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBarView.backgroundColor = navColor
            view.addSubview(statusBarView)
        } else {
            // Fallback on earlier versions
            //            let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
            //            print(statusBarView.frame.origin.x,statusBarView.frame.origin.y,statusBarView.frame.size.width,statusBarView.frame.size.height)
            //            statusBarView.backgroundColor = navColor
            //            view.addSubview(statusBarView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
