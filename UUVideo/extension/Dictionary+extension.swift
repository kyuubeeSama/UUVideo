//
//  Dictionary+extension.swift
//  InsuranceDemo
//
//  Created by liuqingyuan on 2019/12/12.
//  Copyright © 2019 qykj. All rights reserved.
//

import UIKit
import Foundation

extension Dictionary {
    // 向字典中加入新字典
    mutating func addKeyValue(dictionary:Dictionary) {
        for (key,value) in dictionary {
            self.updateValue(value, forKey: key)
        }
    }
    
    // MARK: 字典转字符串
    func dicValueString(_ dic:[String : Any]) -> String?{
        let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
        let str = String(data: data!, encoding: String.Encoding.utf8)
        return str
    }
    
    // MARK: 字符串转字典
    func stringValueDic(_ str: String) -> [String : Any]?{
        let data = str.data(using: String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
            return dict
        }
        return nil
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
}
