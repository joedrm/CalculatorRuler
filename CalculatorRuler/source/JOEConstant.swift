//
//  JOEConstant.swift
//  CalculatorWidget
//
//  Created by wdy on 2019/9/5.
//  Copyright © 2019 joe. All rights reserved.
//

import UIKit

import Foundation
import UIKit


/// MARK: -PhoneScreen
public let iPhone4 = UIScreen.main.bounds.height == 480
public let iPhone5 = UIScreen.main.bounds.height == 568
public let iPhone6 = UIScreen.main.bounds.height == 667
public let iPhonePlus = UIScreen.main.bounds.height == 736
/// 苹果iPhone X 机型
public let iphoneX = UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? UIScreen.main.currentMode!.size.equalTo(CGSize(width: 1125, height: 2436)) : false
/// 苹果iPhone X 和 iPhone XS 机型
public let iPhoneX_XS = UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? UIScreen.main.currentMode!.size.equalTo(CGSize(width: 1125, height: 2436)) : false
/// 苹果iPhone XR 机型
public let iPhoneXR = UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? UIScreen.main.currentMode!.size.equalTo(CGSize(width: 828, height: 1792)) : false
/// 苹果iPhone XS Max 机型
public let iPhoneXSMax = UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? UIScreen.main.currentMode!.size.equalTo(CGSize(width: 1242, height: 2688)) : false


public let iPhone_4_5 = UIScreen.main.bounds.width == 320 ? true : false
public let ScreenHeight = UIScreen.main.bounds.height
public let ScreenWidth = UIScreen.main.bounds.width

public let kScreenHeightRatio: CGFloat = (ScreenHeight/667.00)
public let kScreenWidthRatio: CGFloat = (ScreenWidth/375.00)

/// Documents 目录：您应该将所有的应用程序数据文件写入到这个目录下。这个目录用于存储用户数据或其它应该定期备份的信息。
public let DocumentPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

/// window
public let QNNWindow = UIApplication.shared.delegate?.window!

/// Application
public let SharedApplication = UIApplication.shared

/// AppDelegate
internal let SharedAppDelegate = UIApplication.shared.delegate

/// Main Window
public let AppMainWindow = UIApplication.shared.delegate?.window

/// Root View Controller
public let RootViewController = UIApplication.shared.delegate?.window??.rootViewController

/// Main Screen
public let AppMainScreen = UIScreen.main

/// Standard UserDefaults
public let StandardUserDefaults = UserDefaults.standard

/// Default Notification Center
public let DefaultNotificationCenter = NotificationCenter.default

/// Default File Manager
public let DefaultFileManager = FileManager.default

/// Main Bundle
public let MainBundle = Bundle.main

/// Status Bar 默认高度
public let StatusBarDefaultHeight: CGFloat = isIPhoneXSeries ? 44.0 : 20.0

/// Navigation Bar 默认高度
public let NavigationBarDefaultHeight: CGFloat = 44.0

/// Top Layout 默认高度
public var TopLayoutDefaultHeight: CGFloat {
    return StatusBarDefaultHeight + NavigationBarDefaultHeight
}

/// Tab Bar 默认高度
public let TabBarDefaultHeight: CGFloat = 49.0

// 取一个像素，一般用于分割线
public let OnePixel = 1 / UIScreen.main.scale

/// 私有库bundle名
public let QNNLibBundle = "QNNLib.bundle"


/// 整型时间戳
public var timeStampInt: Int {
    let date = NSDate().timeIntervalSince1970 * 1000
    let dataInt = Int(date)
    return dataInt
}


/// 是否为iPhone X等全屏手机
public var isIPhoneXSeries: Bool {
    var iPhoneXSeries = false
    if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone {
        return iPhoneXSeries
    }
    
    if #available(iOS 11.0, *)  {
        if let bottom = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom {
            if bottom > CGFloat(0.0) {
                iPhoneXSeries = true
            }
        }
    }
    return iPhoneXSeries
}

/// 获取iPhone X机型的安全区域高度
public var iphoneXSafeAreaInsets: UIEdgeInsets {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    } else {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

public func joe_fitSize(_ value: CGFloat) -> CGFloat {
    return (value~).joe_round()
}


public func joe_fitSize_font(_ value: CGFloat, _ bold: Bool = false) -> UIFont {
    if bold {
        return UIFont.boldSystemFont(ofSize: (value~).joe_round())
    }
    return UIFont.systemFont(ofSize: (value~).joe_round())
}


/// 打印
public func debugPrintOnly(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    debugPrint(items, separator: separator, terminator: terminator)
    #endif
}


/// 适配字体
func QNNFontt(name: String = "", size: CGFloat, bold: Bool = false) -> UIFont {
    var font: UIFont!
    
    // 4、5机型上字体大小缩小两号
    let fontSize = iPhone_4_5 ? size - 2 : size
    
    if name.count > 0 {
        font = UIFont(name: name, size: fontSize)
    } else {
        font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
    }
    return font
}

