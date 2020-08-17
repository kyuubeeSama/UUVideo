//
//  CategoryChooseView.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/17.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit

class CategoryChooseConfig:NSObject{
    enum categoryType {
        case equalWidth
        case freeSize
    }
    /// 背景色
    var backColor:UIColor = .white
    ///按钮选中颜色
    var highLightColor:UIColor = .white
    ///按钮字体颜色
    var titleColor:UIColor = .black
    ///按钮选中字体颜色
    var choosedColor:UIColor = .red
    ///按钮底部横线颜色
    var bottomLineColor:UIColor = .red
    ///按钮类型
    var type:categoryType = .equalWidth
    ///按钮数组
    var listArr:[String] = []
}

class CategoryChooseView: UIView {
    var backScrollView = UIScrollView.init()
    var widthArr:[CGFloat] = []
    var config:CategoryChooseConfig?{
        didSet{
            //创建界面
            switch config?.type {
            case .equalWidth:
                let backView = UIView.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
                self.addSubview(backView)
                backView.backgroundColor = config?.backColor
                for (index,item) in config!.listArr.enumerated() {
                    let button = UIButton.init(type: .custom)
                    backView.addSubview(button)
                    let btnWidth:CGFloat = frame.size.width/CGFloat((config?.listArr.count)!)
                    button.frame = CGRect(x: btnWidth*CGFloat(index), y: 0, width: btnWidth, height: frame.size.height-1)
                    button.setTitle(item, for: .normal)
                    button.tag = 4400+index
                    button.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
                    if index == 0 {
                        button.setTitleColor(config?.choosedColor, for: .normal)
                    }else{
                        button.setTitleColor(config?.titleColor, for: .normal)
                    }
                    button.backgroundColor = config?.highLightColor
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                }
                break
            case .freeSize:
                backScrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
                self.addSubview(self.backScrollView)
                var scrollWidth:CGFloat = 0
                for (index,item) in config!.listArr.enumerated() {
                    let button = UIButton.init(type: .custom)
                    self.backScrollView.addSubview(button)
                    button.setTitle(item, for: .normal)
                    let size = item .getStringSize(font: UIFont.systemFont(ofSize: 15), size: CGSize(width: Double(MAXFLOAT), height: 15.0))
                    button.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
                    button.frame = CGRect(x: scrollWidth, y: 0, width: size.width, height: 15)
                    widthArr[index] = scrollWidth
                    if index == 0 {
                        button.setTitleColor(config?.choosedColor, for: .normal)
                    }else{
                        button.setTitleColor(config?.titleColor, for: .normal)
                    }
                    button.tag = 4400+index
                    scrollWidth = scrollWidth+size.width+40
                    backScrollView.contentSize = CGSize(width: scrollWidth, height: frame.size.height)
                    button.backgroundColor = config?.highLightColor
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                }
                break
            default:
            break
            }
        }
    }
    var index:Int?{
        didSet{
            // 重新定位
//            for (int i= 0; i<self.titleArr.count; i++) {
//                CategoryButton *btn = [self viewWithTag:4400+i];
//                [btn setTitleColor:self.btnTitleColor forState:UIControlStateNormal];
//                btn.backgroundColor = self.btnBackgroundColor;
//                btn.bottomLineView.hidden = YES;
//            }
//            CategoryButton *button = [self viewWithTag:4400+index];
//            [button setTitleColor:self.clickColor forState:UIControlStateNormal];
//            button.backgroundColor = self.hightLightColor;
//            button.bottomLineView.hidden = NO;
//            if(self.chooseBlock){
//                self.chooseBlock(index);
//            }
            for (index,_) in config!.listArr.enumerated() {
                let btn:UIButton = self.viewWithTag(4400+index)! as! UIButton
                btn.setTitleColor(config?.titleColor, for: .normal)
                btn.backgroundColor = config?.backColor
            }
            let button:UIButton = self.viewWithTag(4400+index!)! as! UIButton
            button.setTitleColor(config?.choosedColor, for: .normal)
            button.backgroundColor = config?.highLightColor
            if self.chooseBlock != nil {
                self.chooseBlock!(index!)
            }
            self.moveToIndex(index: index!)
        }
    }

    func moveToIndex(index:Int){
        if config?.type == .freeSize {
            let scrollWidth = widthArr[index]
            if(scrollWidth < screenW/2){
                self.backScrollView.contentOffset = CGPoint(x: 0, y: 0)
            }else if(self.backScrollView.contentSize.width-scrollWidth>screenW){
                let size = config?.listArr[index] .getStringSize(font: UIFont.systemFont(ofSize: 15), size: CGSize(width: Double(MAXFLOAT), height: 15.0))
                let offsetX = scrollWidth-(screenW-size!.width-40)/2
                self.backScrollView.contentOffset = CGPoint(x: offsetX, y: 0)
            } else{
                self.backScrollView.contentOffset = CGPoint(x: self.backScrollView.contentSize.width-screenW, y: 0)
            }
        }
    }
    
    var chooseBlock:((_ index:Int)->())?
    
    @objc func buttonClick(button:UIButton){
//        for (int i= 0; i<self.titleArr.count; i++) {
//            CategoryButton *btn = [self viewWithTag:4400+i];
//            [btn setTitleColor:self.btnTitleColor forState:UIControlStateNormal];
//            btn.backgroundColor = self.btnBackgroundColor;
//            btn.bottomLineView.hidden = YES;
//        }
//        [button setTitleColor:self.clickColor forState:UIControlStateNormal];
//        button.backgroundColor = self.hightLightColor;
//        button.bottomLineView.hidden = NO;
//        if(self.chooseBlock){
//            self.chooseBlock((int)button.tag-4400);
//        }
//        [self moveToIndex:button.tag-4400];
        self.index = button.tag-4400
    }
        
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
