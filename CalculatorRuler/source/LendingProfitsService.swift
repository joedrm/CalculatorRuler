//
//  LendingProfitsService.swift
//  QNN
//
//  Created by Smalla on 2018/8/8.
//  Copyright © 2018年 qianshengqian. All rights reserved.
//

import Foundation

/// 出借收益计算
struct LendingProfitsService {
    
    /// 产品锁定期
    var productDays: Int = 0
    /// 产品收益率
    var productRate: Double = 0
    /// 产品用于计算每天收益的总天数
    var productYearDays: Int = 0
    /// 产品加息利率
    var productAddProfitRate: Double = 0
    
    init(_ days: Int,
         rate: Double,
         yearDays: Int,
         addRate: Double) {
        
        self.productDays = days
        self.productRate = rate
        self.productYearDays = yearDays
        self.productAddProfitRate = addRate
    }
    
    /// 计算本金收益
    func getLendingAmountProfits(_ lendMoney: Double) -> Double {
        guard productRate > 0 else {
            return 0
        }
        // 当前产品每天收益 乘以100倍,以分为单位
        let everyDayProfit = (lendMoney * 100 * productRate) / Double(productYearDays)
        // 向下取整
        let floorProfit = floor(everyDayProfit * 100) / 100
        // 计算锁定期总收益，以分为单位
        let daysProfits = Int(floorProfit * Double(productDays))
        
        // 除以100，以元为单位
        return Double(daysProfits) / 100
    }
}
