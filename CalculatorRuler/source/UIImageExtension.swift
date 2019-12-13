//
//  UIImageExtension.swift
//  CalculatorWidget
//
//  Created by wdy on 2019/9/6.
//  Copyright © 2019 joe. All rights reserved.
//

import UIKit

extension UIImage {
    public class func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
     缩放图片
     */
    public func imageWithSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let currentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return currentImage!
    }

    
    public class func snapshot(_ view: UIView) -> UIImage? {
        if !Thread.isMainThread {
            assert(false, "UIImage.\(#function) must be called from main thread only.")
        }
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
