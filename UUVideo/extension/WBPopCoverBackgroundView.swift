//
//  WBPopCoverBackgroundView.swift
//  UUVideo
//
//  Created by 刘清元 on 2021/8/25.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit

class WBPopCoverBackgroundView: UIView {
    var clickCoverViewCallBack:(()->())?
    public var isDismissPopView:Bool = false
    public var isBlur:Bool = false{
        didSet{
            if isBlur {
                blurCloverView?.isHidden = false
                self.backgroundColor = .clear
            }else{
                blurCloverView?.isHidden = true
                self.backgroundColor = UIColor.init(white: 0, alpha: 0.65)
            }
        }
    }
    public var coverAlpha:Float = 1{
        didSet{
            self.backgroundColor = UIColor.init(white: 0, alpha: CGFloat(coverAlpha))
        }
    }
    public var blurCloverView:UIView?
    
    static let instance = WBPopCoverBackgroundView.init(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
    private override init(frame: CGRect) {
        super.init(frame: frame)
        if (blurCloverView == nil) {
            self.backgroundColor = .clear
            let blur = UIBlurEffect.init(style: .dark)
            blurCloverView = UIVisualEffectView.init(effect: blur)
            blurCloverView?.frame = UIScreen.main.bounds
            blurCloverView?.isUserInteractionEnabled = true
            self.addSubview(blurCloverView!)
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickCoverView))
            self.addGestureRecognizer(tap)
        }
    }
    
    @objc func clickCoverView(){
        if isDismissPopView && (self.clickCoverViewCallBack != nil) {
            self.clickCoverViewCallBack!()
        }
    }
    
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
