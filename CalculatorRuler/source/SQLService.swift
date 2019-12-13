//
//  SQLService.swift
//  QNN
//
//  Created by Smalla on 2017/9/21.
//  Copyright © 2017年 qianshengqian. All rights reserved.
//

import UIKit

/*
    说明：
 
    奇进偶舍，又称为四舍六入五成双规则、银行进位法，是一种计数保留法，是一种数字修约规则。
    从统计学的角度，“奇进偶舍”比“四舍五入”更为精确：在大量运算时，因为舍入后的结果有的变大，有的变
    小，更使舍入后的结果误差均值趋于零。而不是像四舍五入那样逢五就进位，导致结果偏向大数，使得误差产
    生积累进而产生系统误差。“奇进偶舍”使测量结果受到舍入误差的影响降到最低
 
    四舍六入五成双规则：
 
    1. 被修约的数字小于5时，该数字舍去；
    2. 被修约的数字大于5时，则进位；
    3. 被修约的数字等于5时，要看5前面的数字，若是奇数则进位，若是偶数则将5舍掉，即修约后末尾数字都成为偶数；若5的后面还有不为“0”的任何数，则此时无论5的前面是奇数还是偶数，均应进位。
 
    例如：9.83543
     保留3位有效数字：被修约的数为5；
     保留小数点后2位：被修约的数为5；以下方法是以保留小数点后2位为基准。
 
*/


/// 四舍六入五成双法则（别名：银行进位法、奇进偶舍）
class SQLService: NSObject {
    
    /// 传入原始数据，经过四舍六入五成双法则处理之后，返回最终的数据
    ///
    /// - Parameters:
    ///   - data: 原始数据即需要处理的数据
    ///   - ruleNum: 保留小数点后的位数，默认为保留小数点后2位
    /// - Returns: 满足规则的数据
    static func computeFrom(data: Double, ruleNum: Int = 2) -> String {
        var decimalArr = data.description.components(separatedBy: ".")
        
        guard decimalArr.count > 1 else {
            return roundFormat(multiple: ruleNum, data: data)
        }
        
        guard decimalArr[1].count > ruleNum else {
            return roundFormat(multiple: ruleNum, data: data)
        }
        
        let roundCharacter = (decimalArr[1] as NSString).substring(with: NSRange(location: ruleNum, length: 1))
        
        if roundCharacter.integerValue == 5 {
            let behindStr = (decimalArr[1] as NSString).substring(from: ruleNum + 1)
            let filterArr = behindStr.filter({ character in
                return character.description.integerValue > 0
            })
            if filterArr.count > 0 {
                // 5后面有不为0的数，直接进位
                return roundFormat(multiple: ruleNum, data: data)
                
            } else {
                // 判断数字5前面的奇偶性
                let frontCharacter = (decimalArr[1] as NSString).substring(with: NSRange(location: ruleNum - 1, length: 1))
                
                if (frontCharacter.integerValue % 2) == 0 {
                    // 5前面的数为偶数 9.84543
                    let ruleNumStr = (decimalArr[1] as NSString).substring(to: ruleNum)
                    decimalArr.remove(at: 1)
                    decimalArr.insert(ruleNumStr, at: 1)
                    return decimalArr.joined(separator: ".")
                    
                } else {
                    // 5前面的数为奇数
                    return roundFormat(multiple: ruleNum, data: data)
                }
            }
        
        } else {
            return roundFormat(multiple: ruleNum, data: data)
        }
    }
    
    /// 格式化数据结果
    ///
    /// - Parameters:
    ///   - multiple: 10 的倍数
    ///   - data: 处理完的数据
    /// - Returns: 最终的格式化字符串
    static func roundFormat(multiple: Int, data: Double) -> String {
        let powData = pow(10, Double(multiple))
        let roundResult = round(data * powData) / powData
        return String(format: "%.\(multiple)f", roundResult)
    }
}
