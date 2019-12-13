//
//  QNNActionSheetView.swift
//  QNN
//
//  Created by joewang on 2018/11/9.
//  Copyright © 2018 qianshengqian. All rights reserved.
//

import UIKit
import Then
import SnapKit

private let ActionSheetViewBgColor = UIColor(hexadecimalString: "000000", alpha: 0.7)

/// 底部弹框视图父类，子类继承，在bodyView添加子控件

class QNNActionSheetView: UIView {

    weak var coverView: UIView!
    weak var bodyView: UIView!
    
    var originHeight : CGFloat = 0
    
    public var bgColor : UIColor? {
        set {
            coverView.backgroundColor = newValue
        }
        
        get {
            if coverView != nil {
                return coverView.backgroundColor
            }
            return ActionSheetViewBgColor
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        coverView = UIView().then({ (v) in
            addSubview(v)
            v.backgroundColor = bgColor
            v.alpha = 0
            v.tapActionsGesture(action: { [weak self] in
                self?.closeView()
            })
            v.snp.makeConstraints({ (make) in
                make.left.right.top.bottom.equalTo(self)
            })
        })
        
        /// 默认高度，子类重写 setupUI() 时需要重新计算
        let bodyViewH = (ScreenHeight*0.4).joe_round()
        let bodyView = UIView(frame: CGRect(x: 0, y: bodyViewH, width: ScreenWidth, height: 0))
        addSubview(bodyView)
        bodyView.backgroundColor = UIColor.white
        self.bodyView = bodyView
        
        self.bodyView.snp.makeConstraints({ (make) in
            make.height.equalTo(bodyViewH)
            make.left.right.equalTo(0)
            make.top.equalTo(ScreenHeight)
        })
        
        /// 此处更新布局，为了在做显示动画时可以拿到 bodyView 的高度
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    
    /// 子类重写
    func openView() {
        openViewWithCallBack(nil)
    }
    
    /// 子类重写
    @objc func closeView() {
        closeViewWithBlock(nil)
    }
    
    /// 子类重写
    func showView() {
        showViewWithCallBack(nil)
    }
    
    /// 子类重写
    func hideView() {
        hiddenViewWithCallBack(nil)
    }
}



extension QNNActionSheetView {
    
    class func actionSheet() -> QNNActionSheetView {
        return QNNActionSheetView.init(frame: CGRect.zero)
    }
    
    /// 子类调用
    func openViewWithCallBack(_ completion:(()->())?) {
        QNNWindow?.addSubview(self)
        UIView.SpringAnimator(duration: 0.4)
            .damping(0.9)
            .velocity(0.7)
            .options(.curveEaseInOut)
            .animations {
                self.coverView.alpha = 1.0
                self.bodyView.transform = CGAffineTransform(translationX: 0, y: -self.bodyView.height)
            }.completion({ (finished) in
                if let callBack = completion {
                    callBack()
                }
            }).animate()
    }
    
    /// 子类调用
    @objc func closeViewWithBlock(_ completion:(()->())? ) {
        UIView.SpringAnimator(duration: 0.4)
            .damping(0.9)
            .velocity(0.7)
            .options(.curveEaseInOut)
            .animations {
                self.coverView.alpha = 0.0
                self.bodyView.transform = CGAffineTransform.identity
            }.completion({ (finished) in
                self.removeFromSuperview()
                if let callBack = completion {
                    callBack()
                }
            }).animate()
    }
    
    /// 子类调用
    func showViewWithCallBack(_ completion:(()->())?) {
        self.isHidden = false
        UIView.SpringAnimator(duration: 0.4)
            .damping(0.9)
            .velocity(0.7)
            .options(.curveEaseInOut)
            .animations {
                self.coverView.alpha = 1.0
                self.bodyView.transform = CGAffineTransform(translationX: 0, y: -self.bodyView.height)
            }.completion({ (finished) in
                if let callBack = completion {
                    callBack()
                }
            }).animate()
    }
    
    /// 子类调用
    func hiddenViewWithCallBack(_ completion:(()->())?) {
        UIView.SpringAnimator(duration: 0.4)
            .damping(0.9)
            .velocity(0.7)
            .options(.curveEaseInOut)
            .animations {
                self.coverView.alpha = 0.0
                self.bodyView.transform = CGAffineTransform.identity
            }.completion({ (finished) in
                self.isHidden = true
                if let callBack = completion {
                    callBack()
                }
            }).animate()
    }
    
    /// 子类调用
    @objc func resignKeyBoard() {
        QNNWindow?.endEditing(true)
    }
}
