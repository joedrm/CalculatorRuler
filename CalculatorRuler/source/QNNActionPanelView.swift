//
//  QNNActionPanelView.swift
//  QNN
//
//  Created by joewang on 2018/12/17.
//  Copyright © 2018 qianshengqian. All rights reserved.
//

import Foundation
import UIKit

/// 底部弹起浮层，一般用于交互操作比较复杂的父类，如：
/// - 滑尺计算器：QNNCalculatorRulerView
/// - 验证码浮层：QNNSendSMSView
/// - 交易密码浮层：QNNTradePasswordView
/// - 选择银行卡浮层：QNNSelectBankCardView

class QNNActionPanelView: QNNActionSheetView {
    
    weak var titleLabel : UILabel!
    weak var closeBtn : UIButton!
    weak var lineView : UIView!
    
    public var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text ?? ""
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        _ = UIControl().then({ (c) in
            bodyView.addSubview(c)
            c.snp.makeConstraints({ (make) in
                make.top.bottom.left.right.equalTo(0)
            })
            c.addTarget(self, action: #selector(resignKeyBoard), for: .touchUpInside)
        })
        
        
        let titleHeight: CGFloat = 44.0
        originHeight += titleHeight
        
        titleLabel = UILabel().then { (v) in
            bodyView.addSubview(v)
            v.textColor = UIColor(hexadecimalString: "333333")
            v.font = QNNFontt(size: 16)
            v.textAlignment = .center
            v.snp.makeConstraints({ (make) in
                make.height.equalTo(titleHeight)
                make.top.left.right.equalTo(bodyView)
            })
        }
        
        lineView = UIView().then { (v) in
            bodyView.addSubview(v)
            v.backgroundColor = UIColor(hexadecimalString: "EEEEEE")
            v.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom)
                make.left.right.equalTo(bodyView)
                make.height.equalTo(0.5)
            })
        }
        originHeight += 0.5
        
        closeBtn = UIButton(type: .system).then({ (b) in
            bodyView.addSubview(b)
            let img = UIImage(named: "Lending_close")?.withRenderingMode(.alwaysOriginal)
            b.setImage(img, for: .normal)
            b.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            b.snp.makeConstraints({ (make) in
                make.right.top.equalTo(bodyView)
                make.size.equalTo(CGSize(width: titleHeight, height: titleHeight))
            })
        })
        
        self.bodyView.snp.remakeConstraints({ (make) in
            make.bottom.equalTo(closeBtn.snp.bottom).offset(10)
            make.left.right.equalTo(0)
            make.top.equalTo(ScreenHeight)
        })
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}

extension QNNActionPanelView {
    @objc func closeAction() {
        closeView()
    }
}
