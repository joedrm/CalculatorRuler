//
//  StringExtension.swift
//  QNN
//
//  Created by zhenyu on 17/3/27.
//  Copyright © 2017年 qianshengqian. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /**
     截取超出部分字符串
     - parameter max : 要截取的位数
     - returns: 截取之后的长度
     */
    public mutating func stringCutWithMaxLength(_ max: Int) {
        if self.count < max {
            return
        }
        self.replaceSubrange(self.index(self.startIndex, offsetBy: max)..<self.endIndex, with: "")
    }
    
    /**
     字符串长度
     - returns: 字符串长度,包括空格等
     */
    public var length: Int {
        return count
    }
    
    /**
     去除字符串中的空格
     - returns: 去除字符串中的空格之后的字符
     */
    public func trimSpace() -> String {
        let newSharacters = filter { (c) -> Bool in
            return c == " " ? false : true
        }
        
        var newStr = ""
        for c in newSharacters {
            newStr = newStr + String(c)
        }
        return newStr
    }
    
    /**
     将编码后的url转换回原始的url
     */
    public func URLDecode() -> String? {
        return self.removingPercentEncoding
    }
    
    /**
     编码url
     */
    public func URLEncode() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn: "!*'\"();:@&=+$,/?%#[]% ").inverted)
    }
    
    /**
     根据字体获取宽度
     */
    public func sizeWith(font: UIFont) -> CGSize {
        let text = self as NSString
		let size = text.size(withAttributes: [NSAttributedString.Key.font : font])
        return size
    }
    
    /**
     * 获取attrbuteTexts富文本
     */
    public func attrbuteTexts(text: String ..., color: UIColor, font: UIFont) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString(string: self)
        // 中间变量 可变 text, 解决当传入的text有相同元素的时候，定位Range
        var mutiText = self
        
        for t in text {
            if mutiText.contains(t) {
                let range = (mutiText as NSString).range(of: t)
                
                // mutiText
                var repalceStr = ""
                for _ in 0..<(range.length) {
                    repalceStr = repalceStr + " "
                }
                mutiText = (mutiText as NSString).replacingCharacters(in: range, with: repalceStr)
                
                
                let c = color
                let f = font
                
                attr.addAttributes([NSAttributedString.Key.foregroundColor: c, NSAttributedString.Key.font: f], range: range)
            }
        }
        return attr
    }
    
    /**
     限制输入框输入内容
     如果string字符集每一个字符都是text字符集的子集，返回true，否则返回false
     eg: let limit = String.limitInputText("0123456789Xx", string: "3cf5")
     limit = false
     - parameter text     :字符集
     - parameter string   :等待校验的字符集
     - returns: 校验结果
     */
    public static func limitInputText(_ text: String, string: String) -> Bool {
        let character = CharacterSet(charactersIn: text).inverted
        let filter = string.components(separatedBy: character) as NSArray
        let bTest = string.isEqual(filter.componentsJoined(by: ""))
        
        return bTest
    }
    
    public func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
//    public func split(_ splitChars: Character...) -> [String] {
//        return split(whereSeparator: { (c: Character) -> Bool in
//            return splitChars.any { s in
//                return s == c
//            }
//        }).map { String($0) }
//    }

}

extension String {
    // String类型转换
    public var intValue: Int32 {
        return (self as NSString).intValue
    }
    public var integerValue: NSInteger {
        return (self as NSString).integerValue
    }
    public var floatValue: Float {
        return (self as NSString).floatValue
    }
    public var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    public var boolValue: Bool {
        return (self as NSString).boolValue
    }
    // 匹配字符串，拿到range
    public func rangeOfString(str: String) -> NSRange {
        return (self as NSString).range(of: str)
    }
    // 根据str替换
    public func replaceStr(ofStr: String, withStr: String) -> String {
        return (self as NSString).replacingOccurrences(of: ofStr, with: withStr)
    }
    // 据range替换
    public func replaceRange(inRange: NSRange, withStr: String) -> String {
        return (self as NSString).replacingCharacters(in: inRange, with: withStr)
    }
    // 字符串去空格
    public func deleteSpace() -> String {
        return self.replaceStr(ofStr: " ", withStr: "")
    }
}

// MARK: - HTML
extension String {
    public var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8),
                                          options: [.documentType: NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey(rawValue: "CharacterEncoding"): String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return nil
        }
    }
}

// MARK: - 翻转字符串
extension String {
    // 逐字翻转字符串(ab cd ef fg => ba dc fe gf)
    public func reverseWords() -> String{
        var chars = [Character](self)
        // 翻转每个单词中的字符
        var startIndex = 0
        for endIndex in 0 ..< chars.count {
            if endIndex == chars.count - 1 || chars[endIndex + 1] == " " {
                reverseStr(&chars, startIndex, endIndex)
                startIndex = endIndex + 2
            }
        }
        return String(chars)
    }

    // 翻转指定范围的字符
    private func reverseStr( _ chars:inout [Character], _ startIndex:Int, _ endIndex:Int){
        var startIndex = startIndex
        var endIndex = endIndex
        if startIndex <= endIndex {
            let tempChar = chars[endIndex]
            chars[endIndex] = chars[startIndex]
            chars[startIndex] = tempChar

            startIndex += 1
            endIndex -= 1
            reverseStr(&chars,startIndex,endIndex)
        }
    }
}

