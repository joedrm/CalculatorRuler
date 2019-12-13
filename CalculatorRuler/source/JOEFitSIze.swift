//
//  JOEFitSIze.swift
//  CalculatorWidget
//
//  Created by wdy on 2019/9/6.
//  Copyright © 2019 joe. All rights reserved.
//

import UIKit

fileprivate let ScreenW = UIScreen.main.bounds.width

public final class QNNFitsize {
    static let shared = QNNFitsize()
    private init() { }
    
    // default reference width 375
    private var referenceW: CGFloat = 375
    
    public static func reference(width: CGFloat) {
        QNNFitsize.shared.referenceW = width
    }
    
    fileprivate func fitSize(_ v: CGFloat) -> CGFloat {
        return ScreenW / referenceW * v
    }
}

postfix operator ~

public postfix func ~ (value: CGFloat) -> CGFloat {
    return QNNFitsize.shared.fitSize(value)
}

public postfix func ~ (font: UIFont) -> UIFont {
    return UIFont(name: font.fontName, size: font.pointSize~) ?? font
}

public postfix func ~ (value: Int) -> CGFloat {
    return CGFloat(value)~
}

public postfix func ~ (value: Float) -> CGFloat {
    return CGFloat(value)~
}

public postfix func ~ (value: CGPoint) -> CGPoint {
    return CGPoint(
        x: value.x~,
        y: value.y~
    )
}

public postfix func ~ (value: CGSize) -> CGSize {
    return CGSize(
        width: value.width~,
        height: value.height~
    )
}

public postfix func ~ (value: CGRect) -> CGRect {
    return CGRect(
        x: value.origin.x~,
        y: value.origin.y~,
        width: value.size.width~,
        height: value.size.height~
    )
}


public postfix func ~ (value: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: value.top~, left: value.left~, bottom: value.bottom~, right: value.right~)
}


class Test:  NSObject{
    
    func test()  {
        debugPrint(100~)
        debugPrint(UIFont.systemFont(ofSize: 14)~)
        debugPrint(CGPoint(x: 10, y: 10)~)
        debugPrint(CGRect(x: 10, y: 10, width: 100, height: 100)~)
        debugPrint(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)~)
    }
}

