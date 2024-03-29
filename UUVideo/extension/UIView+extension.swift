//
//  UIView+extension.swift
//  InsuranceDemo
//
//  Created by liuqingyuan on 2019/12/25.
//  Copyright © 2019 qykj. All rights reserved.
//

import UIKit

enum QYBorderPosition {
    case All
    case Top
    case Left
    case Right
    case Bottom
}

extension UIView{
    
    func addBorderLine(position:Array<QYBorderPosition>, borderColor:UIColor, borderWidth:CGFloat){
        
        for item in position{
            if item == .All {
                layer.borderWidth = borderWidth
                layer.borderColor = borderColor.cgColor
            }
            print(frame.size.width, frame.size.height)
            if item == .Left{
                layer.addSublayer(addLine(originPoint: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: 0, y: frame.size.height), color: borderColor, borderWidth: borderWidth))
            }
            
            if item == .Right{
                layer.addSublayer(addLine(originPoint: CGPoint(x: frame.size.width, y: 0), toPoint: CGPoint(x: frame.size.width, y: frame.size.height), color: borderColor, borderWidth: borderWidth))
            }
            
            if item == .Top{
                layer.addSublayer(addLine(originPoint: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: frame.size.width, y: 0), color: borderColor, borderWidth: borderWidth))
            }
            
            if item == .Bottom{
                layer.addSublayer(addLine(originPoint: CGPoint(x: 0, y: frame.size.height), toPoint: CGPoint(x: frame.size.width, y: frame.size.height), color: borderColor, borderWidth: borderWidth))
            }
        }
        
        
    }
    
    func addLine(originPoint:CGPoint,toPoint:CGPoint,color:UIColor,borderWidth:CGFloat)->CAShapeLayer{
        let bezierPath = UIBezierPath.init()
        bezierPath.move(to: originPoint)
        bezierPath.addLine(to: toPoint)
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineWidth = borderWidth
        return shapeLayer
    }
    

}
