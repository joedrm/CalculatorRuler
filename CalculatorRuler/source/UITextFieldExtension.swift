//
//  UITextFieldExtension.swift
//  PaydayLoan
//
//  Created by 张霄男 on 8/31/16.
//  Copyright © 2016 QianShengQian, Inc. All rights reserved.
//

import UIKit

extension UITextField {
    
    /**
     只能输入数字(添加到 EditingChanged)
     
     - parameter eg: addTarget(self, action: #selector(textFieldChange), forControlEvents: .EditingChanged)
     */
    public func numberOnly() {
        let number = self.text!
        if number.count > 0 {
            let text = number.filter({ (c) -> Bool in
                if "0123456789".contains(String(c)) {
                    return true
                } else {
                    return false
                }
            })
            self.text! = String(text)
        }
    }
    
    /**
     UItextField text 的最大长度
     
     - parameter length: 长度
     - parameter eg: addTarget(self, action: #selector(textFieldChange), forControlEvents: .EditingChanged)
     
     */
    public func maxText(length: Int) {
        let text = self.text!
        if text.count > length {
            let startIndex = text.startIndex
            let maxIndex = text.index(startIndex, offsetBy: length)
            self.text = String(text.prefix(upTo: maxIndex))
        }
    }
    
    public func parseString(spaceStr: String?, numArray: NSArray) -> String? {// 添加空格
        if spaceStr == nil {
            return nil
        }
        let mStr = NSMutableString(string: spaceStr!.replacingOccurrences(of: " ", with: ""))
        // 遍历数组间隔位数
        for space in numArray {
            if mStr.length > Int(truncating: space as! NSNumber) {
                mStr.insert(" ", at: Int(truncating: space as! NSNumber))
            }
        }
        return mStr as String
    }
    
    // 限制输入框 不能输入 空格
    public func formatterLimitSpace(_ range: NSRange, string: String) -> Bool {
        let text = (self.text! as NSString).replacingCharacters(in: range, with: string)
        let textRange = (text as NSString).range(of: " ")
        if textRange.length > 0 {
            return false
        }
        return true
    }
    
    // 限制小数点只能输入后两位
    public func formatterDecimal(_ range: NSRange, string: String, numLength: Int) -> Bool {
        let text = (self.text! as NSString).replacingCharacters(in: range, with: string)
        if text == "." {
            self.text = "0."
            return false
        } else if text == "00" {
            return false
        }
        var firstIndex = ""
        if text.count > 0 {
            firstIndex = (text as NSString).substring(to: 1)
        }
        var secondIndex = ""
        if text.count > 1 {
            secondIndex = (text as NSString).substring(with: NSRange(location: 1, length: 1))
        }
        if firstIndex == "0" {
            if secondIndex.count > 0 && secondIndex != "0" && secondIndex != "."{
                self.text = secondIndex
                return false
            }
        }
        let stringArray = text.components(separatedBy: ".")
        if stringArray.count == 1 {
            let str = stringArray[0]
            if str.count > numLength {
                return false
            }
        } else if stringArray.count == 2 {
            let str = stringArray[1]
            if str.count > 2 {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    public func limitTextFieldText(text: String, string: String) -> Bool {// 限制输入框输入内容
        let character = CharacterSet(charactersIn: text).inverted
        let filter = string.components(separatedBy: character) as NSArray
        let bTest = string.isEqual(filter.componentsJoined(by: ""))
        return bTest
    }
    
    public func changeEditingTextFieldText(range: NSRange, string: String, count: Int) -> Bool {// 限制输入框输入位数
        if range.location >= count || string.count > count {
            return false
        }
        
        let textFieldLength = NSString(string: self.text!).length
        let replacementTextLength = NSString(string: string).length
        if replacementTextLength + textFieldLength > count{
            return false
        }
        
        // 限制输入框只能输入阿拉伯数字
        let limit = self.limitTextFieldText(text: "0123456789", string: string)
        return limit
    }
    
    public func allowSpaceEditingTextFieldText(_ range: NSRange, string: String, count: Int) -> Bool {// 限制输入框加空格
        if range.location >= count || string.count > count {
            return false
        }
        
        let textFieldLength = NSString(string: self.text!).length
        let replacementTextLength = NSString(string: string).length
        if replacementTextLength + textFieldLength > count{
            return false
        }
        
        // 限制输入框输入阿拉伯数字+空格
        let limit = self.limitTextFieldText(text: "0123456789 ", string: string)
        return limit
    }
    
    public func formatterNumber(range: NSRange, string: String, numArray: NSArray) -> Bool {// 输入框输入添加间隔
        if let _ = self.text {
            let text = self.text
            if string == "" {
                if range.length == 1 {// 删除一位
                    if range.location == text!.count - 1 {// 从最后删除，遇到空格，多删除一位
                        if String((text! as NSString).character(at: text!.count - 1)) == " " {
                            self.deleteBackward()
                        }
                        return true
                    } else {// 从中间删除
                        var offSet = range.location
                        if range.location < text!.count && String((text! as NSString).character(at: range.location)) == " " && self.selectedTextRange!.isEmpty {
                            self.deleteBackward()
                            offSet -= 1
                        }
                        self.deleteBackward()
                        self.text = parseString(spaceStr: self.text, numArray: numArray)
                        let currentPosi = self.position(from: self.beginningOfDocument, offset: offSet)
                        self.selectedTextRange = self.textRange(from: currentPosi!, to: currentPosi!)
                        return false
                    }
                }
                else if range.length > 1 {
                    var isLast = false
                    if (range.location + range.length) == self.text?.count {
                        isLast = true
                    }
                    self.deleteBackward()
                    self.text = parseString(spaceStr: self.text, numArray: numArray)
                    var offSet = range.location
                    
                    // 遍历数组间隔位数
                    for space in numArray {
                        if range.location == Int(truncating: space as! NSNumber) {
                            offSet += 1
                        }
                    }
                    if !isLast {
                        let newPosi = self.position(from: self.beginningOfDocument, offset: offSet)
                        self.selectedTextRange = self.textRange(from: newPosi!, to: newPosi!)
                    }
                    return false
                }
                else {
                    return true
                }
            }
            else if string.count > 0 {
                self.insertText(string)
                self.text = parseString(spaceStr: self.text, numArray: numArray)
                var offSet = range.location + string.count
                // 遍历数组间隔位数
                for space in numArray {
                    if range.location == Int(truncating: space as! NSNumber) {
                        offSet += 1
                    }
                }
                let newPosi = self.position(from: self.beginningOfDocument, offset: offSet)
                if let _ = newPosi {
                    self.selectedTextRange = self.textRange(from: newPosi!, to: newPosi!)
                    return false
                }
            }
            else {
                return true
            }
        }
        return true
    }
}
