//
//  QNNNumberTextField.swift
//  QSQ
//
//  Created by 鲁小权 on 2016/12/17.
//  Copyright © 2016年 QianShengQian, Inc. All rights reserved.
//

import UIKit
import AudioToolbox

// 记录初始tag标记
let originTag: NSInteger = 250
// 键盘类型
enum BorderType {
    /// 小数点键盘
    case decaimal
    /// 左下角空格
    case blank
    /// 身份证号码 X
    case identity
    /// 左下角 整百 00键盘
    case hundredth
    /// 身份证键盘输入空格
    case spaceX
}

class QNNNumberTextField: UITextField, UIInputViewAudioFeedback {// 自定义数字键盘
    
    weak var numberView: UIView!
    
    // 确定按钮点击回调
    var sureBtnCallBack: (()->())?
    var willInputHandle: ((QNNNumberTextField)->())? // 将要输入
    var inputHandle: ((String?, String) -> Void)?    // 正在输入
    var endInputHandle: ((QNNNumberTextField)->())? // 结束输入
    var numberType: BorderType = .decaimal
    var numberLength: Int = 0// 限制输入框位数
    var currentStr = ""
    weak var sureBtn: UIButton!
    
    var enableInputClicksWhenVisible: Bool {
        get {
            return true
        }
    }
    
    convenience init(type: BorderType, length: Int = 0) {
        self.init()
        numberType = type
        if length > 0 { numberLength = length }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setInputView()
    }
    
    func setInputView() {
        
        numberView = UIView(frame: CGRect(x: 0, y: ScreenWidth - 194, width: ScreenWidth, height: numberTextFieldDefualtHeight())).then { (v) in
            v.backgroundColor = UIColor.white
            inputView = v
        }
        
        var currentColor: UIColor
        if #available(iOS 13.0, *) {
            currentColor = UIColor.label
        } else {
            currentColor = UIColor.black
        }
        
        let space: CGFloat = 0.5
        let btnWidth: CGFloat = (ScreenWidth - 2) / 4
        let btnHeight: CGFloat = 48
        for index in 0..<9 {
            let btnTitle = String(format: "%d", index + 1)
            let button = NormalButton(title: btnTitle, titleColor: currentColor)
            button.addBottomline(lineColor:UIColor(hexadecimalString: "EEEEEE"))
            button.addRightLine(lineColor: UIColor(hexadecimalString: "EEEEEE"))
            if index < 3 {
                button.frame = CGRect(x: CGFloat(index % 3) * btnWidth + space * CGFloat(index + 1), y: space , width: btnWidth, height: btnHeight)
            } else {
                button.frame = CGRect(x: CGFloat(index % 3) * btnWidth + space * CGFloat(index % 3 + 1), y: CGFloat(index / 3) * btnHeight + CGFloat(index / 3 + 1) * space, width: btnWidth, height: btnHeight)
            }
            button.tag = originTag + index + 1
            button.addTarget(self, action: #selector(soundAction(sender:)), for: .touchDown)
            button.addTarget(self, action: #selector(numberAction(sender:)), for: .touchUpInside)
            numberView.addSubview(button)
        }
        var titleStr = ""
        if numberType == .decaimal {
            titleStr = "."
        } else if numberType == .identity || numberType == .spaceX {
            titleStr = "X"
        } else if numberType == .hundredth  {
            titleStr = "00"
        } else { titleStr = "" }
        // 小数点/身份证X/空格键/00键 按钮
        let boardBtn = NormalButton(title: titleStr, titleColor: currentColor)
        boardBtn.addBottomline(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        boardBtn.addRightLine(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        boardBtn.frame = CGRect(x: space, y: btnHeight * 3 + 4 * space, width: btnWidth, height: btnHeight)
        boardBtn.addTarget(self, action: #selector(soundAction(sender:)), for: .touchDown)
        boardBtn.addTarget(self, action: #selector(boardBtnAction(sender:)), for: .touchUpInside)
        numberView.addSubview(boardBtn)
        //数字 0 按钮
        let zeroBtn = NormalButton(title: "0", titleColor: currentColor)
        zeroBtn.frame = CGRect(x: btnWidth + 2 * space, y: btnHeight * 3 + 4 * space, width: btnWidth, height: btnHeight)
        zeroBtn.tag = originTag
        zeroBtn.addBottomline(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        zeroBtn.addRightLine(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        zeroBtn.addTarget(self, action: #selector(soundAction(sender:)), for: .touchDown)
        zeroBtn.addTarget(self, action: #selector(zeroAction(sender:)), for: .touchUpInside)
        numberView.addSubview(zeroBtn)
        // 键盘消失 按钮
        let resignBtn = NormalButton()
        resignBtn.frame = CGRect(x: btnWidth * 2 + 3 * space, y: btnHeight * 3 + 4 * space, width: btnWidth, height: btnHeight)
        resignBtn.addBottomline(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        resignBtn.addRightLine(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        let resignBtnImg = UIImage(named: "global_hiddenKeyboard")?.withRenderingMode(.alwaysOriginal)
        resignBtn.setImage(resignBtnImg, for: .normal)
        resignBtn.addTarget(self, action: #selector(soundAction(sender:)), for: .touchDown)
        resignBtn.addTarget(self, action: #selector(resignAction(sender:)), for: .touchUpInside)
        numberView.addSubview(resignBtn)
        // 删除 按钮
        let deleteBtn = NormalButton()
        deleteBtn.frame = CGRect(x: btnWidth * 3 + 4 * space, y: space, width: btnWidth, height: btnHeight * 2 + space)
        deleteBtn.addBottomline(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        deleteBtn.addRightLine(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        let deleteBtnImg = UIImage(named: "global_deleteKeyboard")?.withRenderingMode(.alwaysOriginal)
        deleteBtn.setImage(deleteBtnImg, for: .normal)
        deleteBtn.addTarget(self, action: #selector(soundAction(sender:)), for: .touchDown)
        deleteBtn.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
        numberView.addSubview(deleteBtn)
        // 确定按钮
        let sureBtn = NormalButton(title: "确定", titleColor: UIColor.white, bgColor: UIColor(hexadecimalString: "FF4343"))
        sureBtn.frame = CGRect(x: btnWidth * 3 + 4 * space, y: deleteBtn.frame.maxY, width: btnWidth, height: btnHeight * 2 + 2 * space)
        sureBtn.addBottomline(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        sureBtn.addRightLine(lineColor: UIColor(hexadecimalString: "EEEEEE"))
        sureBtn.addTarget(self, action: #selector(soundAction(sender:)), for: .touchDown)
        sureBtn.addTarget(self, action: #selector(sureAction(sender:)), for: .touchUpInside)
        numberView.addSubview(sureBtn)
        self.sureBtn = sureBtn
        
        sureBtnStatus(enable: false)
    }
    
    func NormalButton(title: String = "", titleColor: UIColor = UIColor.black, bgColor: UIColor = UIColor.white) -> UIButton {
        
        let button = UIButton(type: .system)
        if title.count > 0 {
            button.setTitle(title, for: .normal)
            button.setTitleColor(titleColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: iPhone_4_5 ? 20 : 24)
        }
        
        if title != "确定" {
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .normal)//QNNImage("global_button_normal")
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .selected)//QNNImage("global_button_selected")
        } else { button.backgroundColor = bgColor }
        return button
    }
    //MARK: -- 输入数字 0~9 时输入框检测
    func setNumberText(number: NSInteger) {
        if let _ = self.text {
            willInputHandle?(self)
            let text = self.limitStringLength(text: "\(number)", numberLength: numberLength)
            if numberType == .decaimal {
                self.text = setDecaimalLimit(text: text.0)
            } else if numberType == .spaceX {
                self.text = setSpaceXLimit(text.0)
            } else if numberType == .hundredth {
                self.text = setDecaimalLimit(text: text.0)
            } else {
                self.text = text.0
            }
            inputHandle?(self.text, text.1)
        }
    }
    
    //MARK: -- 数字 1~9 点击事件 --
    @objc func numberAction(sender: UIButton) {
        setNumberText(number: sender.tag - originTag)
    }
    //MARK: -- 数字 0 点击事件 --
    @objc func zeroAction(sender: UIButton) {
        setNumberText(number: sender.tag - originTag)
    }
    //MARK: -- 小数点 . 点击事件 --
    @objc func boardBtnAction(sender: UIButton) {
        if let _ = self.text {
            willInputHandle?(self)
            switch numberType {
            case .decaimal:
                let decaimalRange = (self.text! as NSString).range(of: ".")
                var inputText = ""
                if decaimalRange.length <= 0 {
                    inputText = self.limitStringLength(text: ".", numberLength: numberLength).0
                } else { inputText = self.text! }
                self.text = setDecaimalLimit(text: inputText)
                inputHandle?(self.text, "")
            case .identity:
                let inputText = self.limitStringLength(text: "X", numberLength: numberLength).0
                self.text = inputText//setDecaimalLimit(inputText)
                inputHandle?(self.text, "")
            case .hundredth:
                let inputText = self.limitStringLength(text: "00", numberLength: numberLength)
                self.text = setDecaimalLimit(text: inputText.0, inputIndex: 2)//inputText.0
                inputHandle?(self.text, inputText.1)
            case .spaceX:
                let inputText = self.limitStringLength(text: "X", numberLength: numberLength).0
                self.text = setSpaceXLimit(inputText)
                inputHandle?(self.text, "")
            default:
                return
            }
        }
    }
    //MARK: -- 键盘消失 点击事件 --
    @objc func resignAction(sender: UIButton) {
        endEditing(true)
        endInputHandle?(self)
    }
    //MARK: -- 删除 点击事件 --
    @objc func deleteAction(sender: UIButton) {
        if let _ = self.text {
            let mutableStr = NSMutableString(string: self.text!)
            guard mutableStr.length > 0 else { return }
            mutableStr.deleteCharacters(in: NSRange(location: mutableStr.length - 1, length: 1))
            let inputText = mutableStr as String
            self.text = inputText
            currentStr = inputText
            inputHandle?(self.text, "")
        }
    }
    //MARK: -- 确定 点击事件 --
    @objc func sureAction(sender: UIButton) {
        endEditing(true)
        sureBtnCallBack?()
    }
    
    func sureBtnStatus(enable: Bool) {
//        if let _ = sureBtn {
//            sureBtn.isEnabled = enable
//            sureBtn.setTitleColor(UIColor(decimalRed: 255, green: 255, blue: 255, alpha: enable ? 1.0 : 0.6), for: .normal)
//        }
    }
    // 设置小数点后只能输入两位
    func setDecaimalLimit(text: String, inputIndex: Int = 1) -> String {
        if let _ = self.text {
            if text.count >= currentStr.count {
                guard text.count >= inputIndex else { return ""}//NSRange(location: text.length - 1, length: 0)
                let compareStr = (text as NSString).substring(from: text.count - inputIndex)
                let decaimalStatus = self.formatterDecimal(range: self.selectedRange(), string: compareStr, numLength: numberLength)
                if !decaimalStatus {
                    return self.text!
                }
            }
            currentStr = text
        }
        return currentStr
    }
    
    func setSpaceXLimit(_ text: String) -> String {
        if let _ = self.text {
            return self.parseString(spaceStr: text, numArray: [6, 15]) ?? ""
        }
        return text
    }
    
    // 调用系统键盘声音
    @objc func soundAction(sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
    }
    
    func numberTextFieldDefualtHeight() -> CGFloat {
        if isIPhoneXSeries {
            return (194 + iphoneXSafeAreaInsets.bottom + 21)
        } else {
            return 194
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

//  TODO: UITextField扩展方法添加
extension UITextField {
    
    func formatterDecimal(range: NSRange, string: String, numLength: Int) -> Bool {// 限制小数点只能输入后两位
        let text = (self.text! as NSString).replacingCharacters(in: range, with: string)
        if text == "." {
            self.text = "0."
            return false
        } else if text == "00" {
            return false
        } else if text == "000" {
            return false
        } else if text == "0000" {
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
    
    // 根据输入字符串 限制输入位数
    func limitStringLength(text: String, numberLength: Int) -> (String, String) {
        
        let text = (self.text! as NSString).replacingCharacters(in: self.selectedRange(), with: text)
        return ((text.count <= numberLength ? text : self.text!), text)
    }
    // 截取当前光标位置
    func selectedRange() -> NSRange {
        let beginPosition = self.beginningOfDocument
        let startPosition = selectedTextRange?.start
        let endPosition = selectedTextRange?.end
        
        let location: NSInteger = self.offset(from: beginPosition, to: startPosition!)
        let length: NSInteger = self.offset(from: startPosition!, to: endPosition!)
        return NSRange(location: location, length: length)
    }
    
    // 限制输入框 不能输入 空格
    func formatterLimitSpace(range: NSRange, string: String) -> Bool {
        let text = (self.text! as NSString).replacingCharacters(in: range, with: string)
        let textRange = (text as NSString).range(of: " ")
        if textRange.length > 0 {
            return false
        }
        return true
    }
}
