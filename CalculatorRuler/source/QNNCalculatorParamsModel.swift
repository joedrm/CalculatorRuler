//
//  QNNCalculatorParamsModel.swift
//  QNN
//
//  Created by joewang on 2018/11/19.
//  Copyright © 2018 qianshengqian. All rights reserved.
//

import UIKit

@objcMembers
class QNNCalculatorParamsModel: NSObject {
    
    @objcMembers
    class RulerConfig: NSObject {
        var init_num : Double = 0.0
        var min_num : Double = 0.0
        var max_num : Double = 0.0
        var step_num : Double = 0.0
        var min_money : Double = 0.0
    }
    
    @objcMembers
    class RateMessage: NSObject {
        var min : Double = 0.0
        var max : Double = 0.0
        var msg = ""
    }
    
    @objcMembers
    class ButtonConfig: NSObject {
        var color = ""
        var text = ""
        var type = ""
        var tips = ""
        var enable = true
    }
    
    var num_counter = RulerConfig()
    var tip_message = "网贷有风险,出借需谨慎"
    var rate_message = [RateMessage]()
    var button_type = ButtonConfig()
    var sub_title = "出借本金（元）" // 出借金额
    var cal_desc = ""
    var type = 0  // 10
    var interest_formula = "" // amount * days * 10.00 / 36000
    var interest_decs = ""  // 据协议约定利率可得
    var rate_range = [Any]()
    var service_fee_rate = "" // 0.02
    var service_fee_desc = ""  // 转让变现手续费,
    var calculator_title = ""  // 利息计算器
    var money_title = "" // 出借金额
    var money_placeholder = "" // 您想出借多少钱?
    var pid = "" // 产品的ID
    
    var value : Double = 0.0
    
    
    var min_money : Double = 0.0
    var days : Int = 0
    var product_percent : Double = 0.0 // 历史年化
    var product_year : Int = 0 // 每年天数
    
    
    func setupMappingObjectClass() -> [String : AnyClass] {
        return [
            "num_counter": RulerConfig.self,
            "button_type": ButtonConfig.self
        ]
    }
    
    func setupMappingElementClass() -> [String : AnyClass] {
        return [
            "rate_message": RateMessage.self
        ]
    }
}
