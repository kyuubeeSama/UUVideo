//
//  CategoryBottomView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/10/19.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class CategoryBottomView: UIView {

    var sureBtnBlock:(()->())?
    var cancelBtnBlock:(()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.systemBackground
        // 取消按钮
        let cancelBtn = UIButton.init(type: .custom)
        self.addSubview(cancelBtn)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(UIColor.init(.dm, light: .black, dark: .white), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        cancelBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.snp.centerX).offset(-30)
            make.size.equalTo(CGSize(width: 100, height: 35))
        }
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.init(.dm, light: .black, dark: .white).cgColor
        cancelBtn.layer.masksToBounds = true
        cancelBtn.layer.cornerRadius = 17.5
        
        // 确认按钮
        let sureBtn = UIButton.init(type: .custom)
        self.addSubview(sureBtn)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(UIColor.red, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        sureBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.snp.centerX).offset(30)
            make.size.equalTo(CGSize(width: 100, height: 35))
        }
        sureBtn.layer.borderWidth = 1
        sureBtn.layer.borderColor = UIColor.red.cgColor
        sureBtn.layer.masksToBounds = true
        sureBtn.layer.cornerRadius = 17.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sureBtnClick(){
        if self.sureBtnBlock != nil {
            self.sureBtnBlock!()
        }
    }
    
    @objc func cancelBtnClick(){
        if self.cancelBtnBlock != nil {
            self.cancelBtnBlock!()
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
