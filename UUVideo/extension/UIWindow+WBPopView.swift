//
//  UIWindow+WBPopView.swift
//  UUVideo
//
//  Created by Galaxy on 2021/8/24.
//  Copyright © 2021 qykj. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

enum WBPopStyle {
    case top
    case center
    case bottom
    case left
    case right
}

struct AssociatedKeys {
    static var hasPopViewKey: Bool = false
    static var popContentViewKey:UIView = UIView.init()
}

extension UIWindow {
    static var popview_animationTime = 0.25
    public var hasPopView:Bool? {
        get{
            objc_getAssociatedObject(self, &AssociatedKeys.hasPopViewKey) as? Bool
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.hasPopViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    public var popContentView:UIView? {
        get{
            objc_getAssociatedObject(self, &AssociatedKeys.popContentViewKey) as? UIView
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.popContentViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func QY_ShowPopView(popStyle:WBPopStyle,popView:UIView,offset:CGPoint,dismissWhenClickCoverView:Bool,isBlur:Bool,alpha:Float) {
        addCoverView(dismissWhenClickCoverView: dismissWhenClickCoverView, popStyle: popStyle, isBlur: isBlur, alpha: alpha)
        addSubview(popView)
        popContentView = popView
        let width = popView.frame.size.width
        let height = popView.frame.size.height
        switch popStyle {
        case .top:
            popView.frame = CGRect(x: 0, y: -height, width: width, height: height)
            popView.center = CGPoint(x: screenW/2+offset.x, y: popView.center.y);
            UIView.animate(withDuration: UIWindow.popview_animationTime) {
                WBPopCoverBackgroundView.instance.alpha = 1
                popView.frame = CGRect(x: popView.frame.origin.x, y: offset.y, width: width, height: height)
            }
            break
        case .center:
            popView.snp.makeConstraints { make in
                make.centerX.centerY.equalTo(self)
                make.size.equalTo(CGSize(width: width, height: height))
            }
            popView.center = CGPoint(x: screenW/2-offset.x, y: screenH/2-offset.y)
            popView.transform = CGAffineTransform.identity.scaledBy(x: CGFloat.leastNormalMagnitude,y: CGFloat.leastNormalMagnitude)
            UIView.animate(withDuration: UIWindow.popview_animationTime) {
                popView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            } completion: { finished in
                UIView.animate(withDuration: UIWindow.popview_animationTime) {
                    popView.transform = CGAffineTransform.identity
                    WBPopCoverBackgroundView.instance.alpha = 1
                }
            }
            break
        case .right:
            popView.frame = CGRect(x: screenW, y: 0, width: popView.frame.width, height: popView.frame.height)
            UIView.animate(withDuration: UIWindow.popview_animationTime) {
                WBPopCoverBackgroundView.instance.alpha = 1
                var beginX = screenW-width
                if  beginX < 0{
                    beginX = 0
                }
                popView.frame = CGRect(x: beginX, y: 0, width: width, height: height)
            }
            break
        case .left:
            popView.frame = CGRect(x: -width, y: 0, width: width, height: height)
            UIView.animate(withDuration: UIWindow.popview_animationTime) {
                WBPopCoverBackgroundView.instance.alpha = 1
                popView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            };
            break
        default:
            popView.frame = CGRect(x: 0, y: screenH, width: width, height: height)
            UIView.animate(withDuration: UIWindow.popview_animationTime) {
                WBPopCoverBackgroundView.instance.alpha = 1
                popView.frame = CGRect(x: 0, y: screenH-height, width: width, height: height)
            }
            break
        }
    }
    
    func wb_dismissPopView(popStyle:WBPopStyle,completion:@escaping()->()){
        if !hasPopView! {
            return;
        }
        hasPopView = false
        let width = popContentView?.frame.size.width
        let height = popContentView?.frame.size.height
        let x = popContentView?.frame.origin.x
        UIView.animate(withDuration: UIWindow.popview_animationTime) {
            switch popStyle {
            case .top:
                self.popContentView?.frame = CGRect(x: x!, y: -height!, width: width!, height: height!)
                break;
            case .center:
                self.popContentView?.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
                break;
            case .left:
                self.popContentView?.frame = CGRect(x: -width!, y: 0, width: width!, height: height!)
                break;
            case .right:
                self.popContentView?.frame = CGRect(x: width!, y: 0, width: width!, height: height!)
                break;
            default:
                self.popContentView?.frame = CGRect(x: x!, y: height!, width: width!, height: height!)
                break;
            }
            WBPopCoverBackgroundView.instance.alpha = popStyle == .center ? 1 : 0
            
        } completion: { finished in
            if popStyle == .center{
                UIView.animate(withDuration: UIWindow.popview_animationTime) {
                    self.popContentView?.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
                    WBPopCoverBackgroundView.instance.alpha = 0
                }completion: { finished in
                    if finished {
                        self.clear()
                        completion()
                    }
                }
            }else{
                if finished {
                    self.clear()
                    completion()
                }
            }
        };
    }
    
    func addCoverView(dismissWhenClickCoverView:Bool,popStyle:WBPopStyle,isBlur:Bool,alpha:Float){
        let popCoverView = WBPopCoverBackgroundView.instance
        popCoverView.clickCoverViewCallBack = {
            self.wb_dismissPopView(popStyle: popStyle) {}
        }
        popCoverView.isDismissPopView = dismissWhenClickCoverView
        popCoverView.isBlur = isBlur
        popCoverView.coverAlpha = alpha
        popCoverView.removeFromSuperview()
        addSubview(popCoverView)
        hasPopView = true
    }
    
    func clear() {
        WBPopCoverBackgroundView.instance.clickCoverViewCallBack = nil;
        WBPopCoverBackgroundView.instance.removeFromSuperview()
        hasPopView = false
        popContentView!.removeFromSuperview()
    }
}
