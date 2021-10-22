//
//  PageView.swift
//  UUVideo
//
//  Created by Galaxy on 2021/10/21.
//  Copyright © 2021 qykj. All rights reserved.
//
// 获取页码，按照顺序，创建上一页，下一页，数字页
// 根据需要，判断哪些文章有页码，哪些没有
// 樱花有页码

import UIKit
import SwiftUI
import ReactiveCocoa
import GRDB

class PageView: UIView {
    
    var currentPageIndex:Int = 1
    var allPageNum:Int = 1{
        didSet{
            makeContentPageItems()
        }
    }
    var pageBtnClickBlock:((_ pageNum:Int)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        leftBtn.reactive.controlEvents(.touchUpInside).observe { button in
            self.currentPageIndex = self.currentPageIndex == 1 ? self.currentPageIndex : self.currentPageIndex-1
            self.pageBtnClickBlock!(self.currentPageIndex)
        }
        rightBtn.reactive.controlEvents(.touchUpInside).observe { button in
            self.currentPageIndex = self.currentPageIndex == self.allPageNum ? self.allPageNum : self.currentPageIndex+1
            self.pageBtnClickBlock!(self.currentPageIndex)
        }
    }
    
    func makeContentPageItems() {
        if allPageNum > 0{
            var pageArr:[Int] = []
            if allPageNum >= 5{
                if currentPageIndex <= allPageNum-5 || currentPageIndex < 4{
                    pageArr = [currentPageIndex,currentPageIndex+1,currentPageIndex+2,currentPageIndex+3,currentPageIndex+4]
                }else{
                    pageArr = [currentPageIndex-2,currentPageIndex-1,currentPageIndex,currentPageIndex+1,currentPageIndex+2]
                }
            }else{
                for item in 1...allPageNum {
                    pageArr.append(item)
                }
            }
            contentView.snp.updateConstraints { make in
                make.size.equalTo(CGSize(width: 70*pageArr.count+10, height: 40))
            }
            for (index,item) in pageArr.enumerated() {
                let btn = contentView.viewWithTag(400+index) as! UIButton
                btn.setTitle("\(item)", for: .normal)
                btn.reactive.controlEvents(.touchUpInside).observe { button in
                    self.currentPageIndex = item
                    self.pageBtnClickBlock!(item)
                }
            }
        }else{
            for item in contentView.subviews {
                item.removeFromSuperview()
            }
        }
    }
    
    lazy var contentView: UIView = {
        let contentView = UIView.init()
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 40))
        }
        for item in 0...4 {
            let btn = UIButton.init(type: .custom)
            contentView.addSubview(btn)
            btn.frame = CGRect(x: 10+item*70, y: 0, width: 60, height: 40)
            btn.tag = 400+item
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btn.setTitleColor(UIColor.init(.dm, light: .black, dark: .white), for: .normal)
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = 3
            btn.layer.borderColor = UIColor.init(.dm, light: .black, dark: .white).cgColor
            btn.layer.borderWidth = 1
        }
        contentView.layer.masksToBounds = true
        return contentView
    }()
    
    lazy var leftBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("上一页", for: .normal)
        button.setTitleColor(UIColor.init(.dm, light: .black, dark: .white), for: .normal)
        self.addSubview(button)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 40))
            make.centerY.equalToSuperview()
            make.right.equalTo(contentView.snp.left)
        }
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.init(.dm, light: .black, dark: .white).cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    lazy var rightBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        self.addSubview(button)
        button.setTitle("下一页", for: .normal)
        button.setTitleColor(UIColor.init(.dm, light: .black, dark: .white), for: .normal)
        self.addSubview(button)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 40))
            make.centerY.equalToSuperview()
            make.left.equalTo(contentView.snp.right)
        }
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.init(.dm, light: .black, dark: .white).cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
