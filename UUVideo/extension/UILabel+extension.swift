//
//  UILabel+extension.swift
//  UUVideo
//
//  Created by Galaxy on 2021/3/15.
//  Copyright © 2021 qykj. All rights reserved.
//

import UIKit

extension UILabel{
    func alignTop(){
        let text = text! as NSString
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font!])
        let rect = text.boundingRect(with: CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        numberOfLines = 0
        var newLineToPad = (frame.size.height-rect.size.height)/size.height
        if newLineToPad < 2 {
            newLineToPad = 0
        }else{
            newLineToPad -= 1
        }
        for _ in 0...Int(newLineToPad) {
            self.text! += "\n "
        }
        lineBreakMode = .byClipping
    }
    
    func alignBottom() {
        let text = text! as NSString
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font!])
        let rect = text.boundingRect(with: CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        numberOfLines = 0
        var newLineToPad = (frame.size.height-rect.size.height)/size.height
        if newLineToPad < 2 {
            newLineToPad = 0
        }else{
            newLineToPad -= 1
        }
        for _ in 0...Int(newLineToPad) {
            self.text = "\n "+self.text!
        }
    }
}
