//
//  QNNCalculatorRulerView.swift
//  QNN
//
//  Created by joewang on 2018/11/9.
//  Copyright © 2018 qianshengqian. All rights reserved.
//

import Foundation
import UIKit


protocol QNNCalculatorRulerViewDelegate: class {
    func sliderRulerView(ruler: UIView, rulervalue: CGFloat)
}

class QNNCalculatorRulerView: QNNActionPanelView {
    
    weak var delegate: QNNCalculatorRulerViewDelegate?
    private weak var rulerScrollView : QNNCalculatorScrollView!
    private weak var valueTextView: QNNNumberTextField!
    private weak var projectLabel : UILabel! // 项目名
    private weak var interestResultLabel : UILabel! // 计算出来的利息
    private weak var markLabel : UILabel! // 网贷有风险，出借需谨慎
    private weak var unitLabel : UILabel!
    private weak var commitBtn : UIButton!
    private weak var warningPopView : QNNCalculatorWarningView!
    private weak var messagePopView : QNNCalculatorMessageView!

    private var interestResultMaxY : CGFloat = 0
    private var isUpdateLayout : Bool = false
    private var isDragging : Bool = false
    
    private var paramsModel : QNNCalculatorParamsModel!
    var lendProfitsService: LendingProfitsService!
    
    public var commitCallBack: ((QNNCalculatorParamsModel) -> ())?
    public var animateCompleted: (() -> ())?
    
    var rulerHeight: CGFloat = 50.0 {
        didSet {
            rulerScrollView.frame = CGRect(x: 0, y: frame.size.height - rulerHeight, width: frame.size.width, height: rulerHeight)
            rulerScrollView.drawRuler()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
    }
    
    
    class func showCalculatorView(_ params: [AnyHashable: Any], callBack : ((QNNCalculatorParamsModel) -> ())?, animateCompleted : (() -> ())?) {
        let v = QNNCalculatorRulerView.init(frame: CGRect.zero)
        v.commitCallBack = callBack
        let paramsModel = Reflect<QNNCalculatorParamsModel>.mapObject(json: params)
        v.animateCompleted = animateCompleted
        v.setData(paramsModel)
    }
    
    func setData(_ param : QNNCalculatorParamsModel) {
        paramsModel = param
        
        title = paramsModel.calculator_title
        unitLabel.text = paramsModel.sub_title
        valueTextView.text = "\(Int(paramsModel.num_counter.init_num))"
        projectLabel.text = paramsModel.interest_decs
        messagePopView.title = ""
        markLabel.text = paramsModel.tip_message
        commitBtn.setTitle(paramsModel.button_type.text, for: .normal)
        commitBtnEnable(paramsModel.button_type.enable)
        
        if paramsModel.button_type.enable {
            commitBtn.setBackgroundImage(UIImage.imageWithColor(UIColor(hexadecimalString: paramsModel.button_type.color)), for: .normal)
            commitBtn.setBackgroundImage(UIImage.imageWithColor(UIColor(hexadecimalString: paramsModel.button_type.color)), for: .highlighted)
        }else{
            commitBtn.setBackgroundImage(UIImage.imageWithColor(UIColor(hexadecimalString: paramsModel.button_type.color)), for: .disabled)
        }
        
        lendProfitsService = LendingProfitsService(param.days, rate: param.product_percent, yearDays: param.product_year, addRate: 0)
        changeEditing()
        
        let max_num = paramsModel.num_counter.max_num
        let min_num = 0.0//paramsModel.num_counter.min_num
        let step_num = paramsModel.num_counter.step_num
        let init_num = paramsModel.num_counter.init_num
        
        if step_num == 0 || max_num == 0 {
            debugPrintOnly("max_num 或者 step_num 为 0，无法打开计算器")
//            if QNN_ENVTest {
//                QNNWindow?.toast(string: "最大值 或者 步长 为 0，无法打开计算器")
//            }
            return
        }
        
        rulerScrollView.maxValue = CGFloat(max_num / step_num)
        rulerScrollView.minValue = 0//CGFloat(min_num / step_num)
        rulerScrollView.rulerAverage = CGFloat(step_num)
        rulerScrollView.rulerValue = CGFloat(init_num - min_num)
        
        paramsModel.value = Double(rulerScrollView.rulerValue)
        
        openViewWithCallBack {
            if let anim = self.animateCompleted {
                anim()
            }
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        unitLabel = UILabel.init().then { (v) in
            bodyView.addSubview(v)
            v.text = "出借本金(元)"
            v.textAlignment = .center
            v.font = UIFont.systemFont(ofSize: 14)~
            v.textColor = UIColor(hexadecimalString: "999999")
            v.snp.makeConstraints({ (make) in
                make.top.equalTo(lineView.snp.bottom)
                make.left.right.equalTo(0)
                make.height.equalTo(44~)
            })
        }
        
        originHeight += 44~
        
        warningPopView = QNNCalculatorWarningView().then({ (v) in
            bodyView.addSubview(v)
            v.frame = CGRect(x: 0, y: 0, width: 145, height: 44)
            v.isHidden = true
            v.snp.makeConstraints({ (make) in
                make.width.equalTo(145~)
                make.height.equalTo(30~)
                make.centerX.equalTo(bodyView.snp.centerX)
                make.centerY.equalTo(unitLabel.snp.centerY).offset(5)
            })
        })
        
        valueTextView = QNNNumberTextField(type: .hundredth).then { (v) in
            bodyView.addSubview(v)
            v.clearButtonMode = .never
            v.keyboardType = .numberPad
            v.textAlignment = .center
            v.font = UIFont.boldSystemFont(ofSize: 32)~
            v.textColor = UIColor(hexadecimalString: "333333")
            v.tintColor = UIColor(hexadecimalString: "4A4A4A")
            v.numberLength = 10
            v.delegate = self
            
            v.sureBtnCallBack = { [weak self] in
                self?.sureCallBack()
            }
            v.inputHandle = { [weak self] (text, reText) in
                self?.changeEditing()
            }
            v.willInputHandle = {(textView) in
                let inputAmount: String = textView.text ?? ""
                if inputAmount == "0" || inputAmount == "00" {
                    textView.text = ""
                }
            }
            v.endInputHandle = { [weak self] (textView) in
                self?.sureCallBack()
            }
            v.addTarget(self, action: #selector(changeEditing), for: .editingChanged)
            v.snp.makeConstraints({ (make) in
                make.top.equalTo(unitLabel.snp.bottom)
                make.left.right.equalTo(0)
                make.height.equalTo(45~)
            })
            
            let dottedLineLayerW: CGFloat = 108~
            let dottedLineLayerH: CGFloat = 1
            let dottedLineLayerX: CGFloat = (ScreenWidth - dottedLineLayerW) * 0.5
            let dottedLineLayerY: CGFloat = 45~ - dottedLineLayerH - 3
            let dottedLineLayer : CAShapeLayer = CAShapeLayer()
            dottedLineLayer.fillColor = UIColor.clear.cgColor
            dottedLineLayer.strokeColor = UIColor(hexadecimalString: "EEE2E2").cgColor
            dottedLineLayer.lineWidth = dottedLineLayerH
            dottedLineLayer.lineJoin = CAShapeLayerLineJoin.round
            let arr :NSArray = NSArray(array: [6, 4])
            dottedLineLayer.lineDashPhase = 1.0
            dottedLineLayer.lineDashPattern = arr as? [NSNumber]
            dottedLineLayer.anchorPoint = CGPoint(x: 0, y: 0)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: dottedLineLayerX, y: dottedLineLayerY))
            path.addLine(to: CGPoint(x: dottedLineLayerX + dottedLineLayerW, y: dottedLineLayerY))
            dottedLineLayer.path = path
            v.layer.addSublayer(dottedLineLayer)
        }
        
        
        originHeight += 45~
        
        // 滑尺上的指针
        let cursor = UIImageView.init().then({ (v) in
            bodyView.addSubview(v)
            v.image = UIImage(named: "global_calculator_cursor")
            v.snp.makeConstraints({ (make) in
                make.height.equalTo(54~)
                make.top.equalTo(valueTextView.snp.bottom)
                make.centerX.equalTo(bodyView.snp.centerX)
            })
        })
        
        originHeight += 54~
        
        rulerScrollView = QNNCalculatorScrollView.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: rulerHeight)).then({ (v) in
            bodyView.insertSubview(v, belowSubview: cursor)
            v.delegate = self
            v.showsHorizontalScrollIndicator = false
            v.shortSymbolColor = UIColor(hexadecimalString: "E2E2E2")
            v.longSymbolColor = UIColor(hexadecimalString: "E2E2E2")
            v.snp.makeConstraints({ (make) in
                make.bottom.equalTo(cursor.snp.bottom)
                make.left.right.equalTo(0)
                make.height.equalTo(35~)
            })
        })
        
        // 分割线
        let _ = UIView().then { (v) in
            v.backgroundColor = UIColor(hexadecimalString: "E2E2E2")
            bodyView.addSubview(v)
            v.snp.makeConstraints({ (make) in
                make.top.equalTo(rulerScrollView.snp.bottom)
                make.left.right.equalTo(0)
                make.height.equalTo(1)
            })
        }
        
        projectLabel = UILabel().then({ (v) in
            bodyView.addSubview(v)
            v.textAlignment = .center
            v.font = UIFont.systemFont(ofSize: 14)~
            v.textColor = UIColor(hexadecimalString: "999999")
            v.sizeToFit()
            v.snp.makeConstraints({ (make) in
                make.top.equalTo(rulerScrollView.snp.bottom).offset(20~)
                make.left.right.equalTo(0)
                make.height.equalTo(20~)
            })
        })
        
        originHeight += 20 + 20~
        
        
        interestResultLabel = UILabel().then({ (v) in
            bodyView.addSubview(v)
            v.textAlignment = .center
            v.font = UIFont.systemFont(ofSize: 24)~
            v.textColor = UIColor(hexadecimalString: "FF4343")
            v.snp.makeConstraints({ (make) in
                make.top.equalTo(projectLabel.snp.bottom)
                make.left.right.equalTo(0)
                make.height.equalTo(45~)
            })
        })
        
        originHeight += 45~
        
        messagePopView = QNNCalculatorMessageView().then({ (v) in
            bodyView.addSubview(v)
            v.snp.makeConstraints({ (make) in
                make.top.equalTo(interestResultLabel.snp.bottom)
                make.centerX.equalTo(bodyView.snp.centerX)
                make.width.equalTo(bodyView.snp.width).multipliedBy(0.6)
                make.height.equalTo(46~)
            })
        })
        
        originHeight += 46~
        
        let markLabelText = "网贷有风险，出借需谨慎"
        let markLabelFont = UIFont.systemFont(ofSize: 12)~
        let markLabelHeight = markLabelText.sizeWith(font: UIFont.systemFont(ofSize: 12)~).height
        markLabel = UILabel().then({ (v) in
            bodyView.addSubview(v)
            v.text = markLabelText
            v.font = markLabelFont
            v.textAlignment = .center
            v.textColor = UIColor(hexadecimalString: "D8D8D8")
            v.snp.makeConstraints({ (make) in
                make.top.equalTo(messagePopView.snp.bottom).offset(30)
                make.left.right.equalTo(0)
                make.height.equalTo(markLabelHeight)
            })
        })
        
        originHeight += 30 + markLabelHeight
        
        commitBtn = UIButton(type: .custom).then({ (v) in
            bodyView.addSubview(v)
            v.isEnabled = true
            v.layer.cornerRadius = 2.0
            v.clipsToBounds = true
            v.setTitle("确定", for: .normal)
            v.setTitleColor(UIColor.white, for: .normal)
            v.setTitleColor(UIColor.white, for: .normal)
            v.titleLabel?.font = UIFont.systemFont(ofSize: 18)~
            v.setBackgroundImage(UIImage.imageWithColor(UIColor(hexadecimalString: "DDDDDD")), for: .disabled)
            v.setBackgroundImage(UIImage.imageWithColor(UIColor(hexadecimalString: "FF4343")), for: .normal)
            v.setBackgroundImage(UIImage.imageWithColor(UIColor(hexadecimalString: "FF4343")), for: .highlighted)
            v.addTarget(self, action: #selector(commitAction), for: .touchUpInside)
            v.snp.makeConstraints({ (make) in
                make.bottom.equalTo(bodyView.snp.bottom).offset(-15-iphoneXSafeAreaInsets.bottom)
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.height.equalTo(50~)
            })
        })
        
        originHeight += 15 + 50~ + 15 + iphoneXSafeAreaInsets.bottom
        
        bodyView.backgroundColor = UIColor.white
        bodyView.snp.remakeConstraints({ (make) in
            make.height.equalTo(originHeight)
            make.left.right.equalTo(0)
            make.top.equalTo(ScreenHeight)
        })
        
        setNeedsLayout()
        layoutIfNeeded()
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let _ = rulerScrollView, !isUpdateLayout{
            rulerScrollView.drawRuler()
            isUpdateLayout = false
        }
        
        if let _ = interestResultLabel {
            interestResultMaxY = interestResultLabel.frame.maxY
        }
    }
    
    override func closeView() {
        resignKeyBoard()
        closeViewWithBlock(nil)
    }
}



extension QNNCalculatorRulerView {
    
    func sureCallBack() {
        resignKeyBoard()
        let inputAmount: String = valueTextView.text ?? ""
        if inputAmount.length == 0 {
            valueTextView.text = "0"
            showWarningView(0.0)
            _ = isInCorrectRange(0.0)
            showInterestResult(0.0)
            showTipMessage(0.0)
            paramsModel.value = 0.0
        }
    }
    
    @objc func changeEditing(){
        
        guard paramsModel != nil else {
            return
        }
        
        let inputAmount: String = valueTextView.text ?? ""
        if inputAmount.length == 0  {
            valueTextView.text = "0"
            valueTextView.currentStr = ""
        }
        
        var amount = inputAmount.length > 0 ? inputAmount.doubleValue : 0.0
        var tempAmount = amount
        
        // 提示和按钮是否可点击
        showWarningView(amount)
        _ = isInCorrectRange(amount)
        
        // 计算利息结果显示
        if tempAmount > paramsModel.num_counter.max_num {
            tempAmount = paramsModel.num_counter.max_num
        }
        if tempAmount < paramsModel.min_money {
            tempAmount = 0.0
        }
        showInterestResult(tempAmount)
        
        // 滚动滑尺的位置
        if amount > paramsModel.num_counter.max_num {
            amount = paramsModel.num_counter.max_num
        }
        
        if amount < 0.0 {
            amount = 0.0
        }
        rulerScrollView.rulerValue = CGFloat(amount)
        isDragging = false
        rulerScrollView.setScrollView()
        
        // 情感化文字提示
        showTipMessage(amount)
        paramsModel.value = amount
    }
    
    @objc func commitAction() {
        resignKeyBoard()
        if let callBack = commitCallBack {
            closeView()
            callBack(paramsModel)
        }
    }
}


extension QNNCalculatorRulerView {
    
    func keyboardShowOrHiden(_ isShow : Bool) {
        let commitBtnHeight = isShow ? valueTextView.numberTextFieldDefualtHeight() : iphoneXSafeAreaInsets.bottom
        let bodyHeight = isShow ? interestResultMaxY + valueTextView.numberTextFieldDefualtHeight() + commitBtn.height + 15 : originHeight
        commitBtn.snp.updateConstraints { (make) in
            make.bottom.equalTo(-15 - commitBtnHeight)
        }
        bodyView.snp.updateConstraints({ (make) in
            make.height.equalTo(bodyHeight)
        })
        isUpdateLayout = true
        self.needsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        UIView.Animator
            .init(duration: 0.3)
            .animations {
                self.messagePopView.alpha = isShow ? 0 : 1
                self.markLabel.alpha = isShow ? 0 : 1
                self.bodyView.transform = CGAffineTransform(translationX: 0, y: -bodyHeight)
                self.layoutIfNeeded()
            }.animate()
    }
    
    func updateWarningView(_ title : String) {
        
        guard title.length > 0 else {
            return
        }
        warningPopView.title = title
        let width = title.sizeWith(font: warningPopView.titleLabel.font).width + 10
        let height = title.sizeWith(font: warningPopView.titleLabel.font).height + 14
        warningPopView.width = width
        warningPopView.height = height
        warningPopView.snp.updateConstraints { (make) in
            make.width.equalTo(width)
        }
        warningPopView.showWarningView()
    }
    
    
    func commitBtnEnable(_ enable : Bool) {
        if !paramsModel.button_type.enable {
            commitBtn.isEnabled = paramsModel.button_type.enable
            return
        }
        commitBtn.isEnabled = enable
    }
    
    func showWarningView(_ value : Double) {
        guard paramsModel != nil else {
            return
        }
        if value > paramsModel.num_counter.max_num {
            updateWarningView("最高出借金额\(Int(paramsModel.num_counter.max_num))元")
            return
        }
        
        if value < paramsModel.min_money {
            updateWarningView("最低出借金额\(Int(paramsModel.min_money))元")
            return
        }
        
        // 是否为100的整数倍
        if Int(value)%100 != 0{
            updateWarningView("请输入100整数倍")
            return
        }
        
        warningPopView.title = ""
        warningPopView.hideWarningView()
    }
    
    func isInCorrectRange(_ value : Double) -> Bool {
        guard paramsModel != nil else {
            return false
        }
        if value > paramsModel.num_counter.max_num {
            commitBtnEnable(false)
            return false
        }
        if value < paramsModel.min_money {
            commitBtnEnable(false)
            return false
        }
        
        if Int(value)%100 != 0{
            commitBtnEnable(false)
            return false
        }
        
        if valueTextView.text?.length ?? 0 <= 0 {
            commitBtnEnable(false)
            return false
        }
        
        commitBtnEnable(true)
        return true
    }
    
    func showTipMessage(_ value : Double) {
        guard paramsModel != nil else {
            return
        }
        let investResult = caculateInvestment(value).doubleValue
        for (_, item) in paramsModel.rate_message.enumerated() {
            if investResult >= item.min && investResult <= item.max {
                messagePopView.title = item.msg
            }else if ((item.max == 0) && (investResult >= item.min)) {
                messagePopView.title = item.msg
            }else {
                //messagePopView.title = ""
            }
        }
    }
    
    func animationRebound() {
        let offSetX = rulerScrollView.contentOffset.x + bounds.width / 2 - DISTANCELEFTANDRIGHT
        var oX = (offSetX / DISTANCEVALUE) * rulerScrollView.rulerAverage
        oX = CGFloat(roundf(Float(oX / rulerScrollView.rulerAverage))) * rulerScrollView.rulerAverage
        var offX = (oX / rulerScrollView.rulerAverage) * DISTANCEVALUE + DISTANCELEFTANDRIGHT - frame.size.width / 2
        offX = CGFloat(roundf(Float(offX)))
        isDragging = true
        rulerScrollView.setContentOffset(CGPoint(x: offX, y: 0), animated: true)
    }
}


extension QNNCalculatorRulerView {
    
    func showInterestResult(_ amount : Double)  {
        if amount > paramsModel.num_counter.max_num {
            interestResultLabel.text = "0.00"
            return
        }
        interestResultLabel.text = caculateInvestment(amount)
    }
    
    func caculateInvestment(_ amount : Double) -> String {
        guard paramsModel != nil else {
            return ""
        }
        let value = String(format: "%.2f", lendProfitsService.getLendingAmountProfits(amount))
        return "\(value)"
    }

    /// 升息宝以外的出借收益收益计算公式是参数传过来的
    func caculateInvestmentEarning(interestFormula: String, days: Double, money: Double) -> Double {
        let replaceAmount: String = interestFormula.replaceStr(ofStr: "amount", withStr: String(format: "%.2f", money))
        let replaceDays: String = replaceAmount.replaceStr(ofStr: "days", withStr: String(format: "%.2f", days))
        let expression = NSExpression(format: replaceDays)
        let investmentEarningValue = expression.expressionValue(with: nil, context: nil) as? Double ?? 0
        return investmentEarningValue
    }
}


extension QNNCalculatorRulerView : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardShowOrHiden(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        keyboardShowOrHiden(false)
        let value = valueTextView?.text?.doubleValue ?? 0.0
        showWarningView(value)
        showTipMessage(value)
        if !isInCorrectRange(value) {
            return
        }
        rulerScrollView.rulerValue = CGFloat(value)
        rulerScrollView.drawRuler()
    }
}

extension QNNCalculatorRulerView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if paramsModel == nil{
            return
        }
        
        guard isDragging else {
            return
        }
        
        let offSetX = scrollView.contentOffset.x + bounds.size.width / 2 - DISTANCELEFTANDRIGHT
        var oX = (offSetX / DISTANCEVALUE) * rulerScrollView.rulerAverage
        
        // 四舍五入取整
        oX = CGFloat(roundf(Float(oX / rulerScrollView.rulerAverage))) * rulerScrollView.rulerAverage
        // 未四舍五入
        let originX = CGFloat(Float(oX / rulerScrollView.rulerAverage)) * rulerScrollView.rulerAverage
        
        if oX <= 0 {
            let value = Double(rulerScrollView.rulerAverage * rulerScrollView.minValue)
            let valuetext = "\(Int(rulerScrollView.rulerAverage * rulerScrollView.minValue))"
            showWarningView(Double(originX))
            _ = isInCorrectRange(Double(originX))
            showTipMessage(value)
            showInterestResult(value)
            if paramsModel != nil{
                paramsModel.value = value
            }
            if valuetext != valueTextView.text && isDragging {
                valueTextView.text = valuetext
            }
            return
        }
        
        var value = Double(oX + rulerScrollView.rulerAverage * rulerScrollView.minValue)
        if value > paramsModel.num_counter.max_num {
            value = paramsModel.num_counter.max_num
        }
        
        if value < 0.0 {
            value = 0.0
        }
        
        showWarningView(Double(originX))
        _ = isInCorrectRange(Double(originX))
        showTipMessage(value)
        
        paramsModel.value = value
        let valuetext = "\(Int(value))"
        if valuetext != valueTextView.text{
            valueTextView.text = valuetext
        }
        
        if value < paramsModel.min_money {
            value = 0.0
        }
        showInterestResult(value)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animationRebound()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            animationRebound()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
}
