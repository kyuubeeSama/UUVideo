//
//  String+extengsion.swift
//  InsuranceDemo
//
//  Created by liuqingyuan on 2019/11/28.
//  Copyright © 2019 qykj. All rights reserved.
//

import Foundation
import UIKit
extension String {
    /// 判断字符串是否为空
    static func myStringIsNULL(string:String)->Bool{
        if (string == ""){
            return true
        }else if string.trimmingCharacters(in: .whitespaces).count == 0{
            return true
        }else if string == "(null)"||string == "<null>" || string == "null"{
            return true
        }else if string.isEmpty{
            return true
        }else{
            return false
        }
    }

    func sizeWithFont(font:UIFont)->CGSize{
        let att = [NSAttributedString.Key.font:font]
        let text = self as NSString
        return text.size(withAttributes: att)
    }
    
    // 获取文字的大小
    func getStringSize(font:UIFont,size:CGSize) -> CGSize {
        let att = [NSAttributedString.Key.font:font]
        let text = self as NSString
        return text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: att, context: nil).size
    }
    
    // 获取拼音
    func transformToPinYin(yinbiao:Bool)->String{
        let mutableString = NSMutableString(string: self) as CFMutableString
            //把汉字转为拼音
            CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        if yinbiao == false {
            //去掉拼音的音标
            CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        }
        let string = String(mutableString)
        //去掉空格
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    private func isValidateByRegex(regex:String)->Bool{
        let pre:NSPredicate = NSPredicate.init(format: " SELF MATCHES %@", regex)
        return pre.evaluate(with: self)
    }

    func isMobilePhone()->Bool{
        let mobileNoRegex = "^1((3\\d|5[0-9]|8[0-9])\\d|7\\d[0-9]|9\\d[0-9])\\d{7}$"
        let phsRegex = "^0(10|2[0-57-9]|\\d{3})\\d{7,8}$"
        let ret:Bool = isValidateByRegex(regex: mobileNoRegex)
        let ret1:Bool = isValidateByRegex(regex: phsRegex)
        return (ret||ret1)
    }
    // 字符转码Unicode
    func unicodeToUtf8()->String{
        let tempStr1 = self.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        let tempData = tempStr3.data(using: String.Encoding.utf8)
        var returnStr:String = ""
        do {
            returnStr = try PropertyListSerialization.propertyList(from: tempData!, options: [.mutableContainers], format: nil) as! String
        } catch {
            print(error)
        }
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }
    func deleteOtherChar()->String{
        var string = self.replacingOccurrences(of: " ", with: "")
        string = string.replacingOccurrences(of: "\n", with: "")
        string = string.replacingOccurrences(of: "\r", with: "")
        string = string.replacingOccurrences(of: "\t", with: "")
        return string
    }
}
