//
//  UIViewExtension.swift
//  QSQ
//
//  Created by wdy on 2019/9/5.
//  Copyright © 2019 joe. All rights reserved.
//

import UIKit


extension UIView {
    
    public var x: CGFloat {
        get {
            return self.frame.origin.x
        } set(value) {
            self.frame = CGRect(x: value, y: self.y, width: self.width, height: self.height)
        }
    }
    
    public var y: CGFloat {
        get {
            return self.frame.origin.y
        } set(value) {
            self.frame = CGRect(x: self.x, y: value, width: self.width, height: self.height)
        }
    }
    
    public var width: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: value, height: self.height)
        }
    }
    
    public var height: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: value)
        }
    }
    
    public var left: CGFloat {
        get {
            return self.x
        } set(value) {
            self.x = value
        }
    }
    
    public var right: CGFloat {
        get {
            return self.x + self.width
        } set(value) {
            self.x = value - self.width
        }
    }
    
    public var top: CGFloat {
        get {
            return self.y
        } set(value) {
            self.y = value
        }
    }
    
    public var bottom: CGFloat {
        get {
            return self.y + self.height
        } set(value) {
            self.y = value - self.height
        }
    }
    
    public var origin: CGPoint {
        get {
            return self.frame.origin
        } set(value) {
            self.frame = CGRect(origin: value, size: self.frame.size)
        }
    }
    
    /// View的中心X值
    public var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    
    /// View的中心Y值
    public var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }
    
//    public func toast(string: String, position:String = CSToastPositionCenter ) {
//        self.makeToast(string, duration: 1.2, position: position)
//    }
//    
//    public class func nib() -> UINib {
//        return UINib(nibName: self.readableClassName(), bundle: .none)
//    }
//    
//    public class func loadFromNib<T: UIView>() -> T {
//        let nib = UINib(nibName: T.readableClassName(), bundle: Bundle(for: T.self))
//        let vs = nib.instantiate(withOwner: .none, options: .none)
//        return vs[0] as! T
//    }
//    
//    public func loadFromNib<T: UIView>() -> T {
//        let nib = UINib(nibName: type(of: self).readableClassName(), bundle: Bundle(for: type(of: self)))
//        let vs = nib.instantiate(withOwner: self, options: .none)
//        return vs[0] as! T
//    }
}

// MARK: Corner
extension UIView {
    /// Should the corner be as circle
    public var circleCorner: Bool {
        get {
            return min(bounds.size.height, bounds.size.width) / 2 == cornerRadius
        }
        set {
            cornerRadius = newValue ? min(bounds.size.height, bounds.size.width) / 2 : cornerRadius
        }
    }
    
    /// Corner radius of view
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = circleCorner ? min(bounds.size.height, bounds.size.width) / 2 : newValue
        }
    }
}

// MARK: SubView
extension UIView {
    public func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

/// Gesture
var blockActionDict : [String : ( () -> () )] = [:]
public extension UIView{
    
    /// 返回所在控制器
    public func viewController() -> UIViewController? {
        var next = self.next
        while((next) != nil){
            if(next!.isKind(of: UIViewController.self)){
                let rootVc = next as! UIViewController
                return rootVc
            }
            next = next?.next
        }
        return nil
    }
    
    /// view以及其子类的block点击方法
    public func tapActionsGesture(action:@escaping ( () -> Void )){
        addBlock(block: action)//添加点击block
        whenTouchOne()//点击block
    }
    
    /// 创建唯一标示  方便在点击的时候取出
    private func addBlock(block:@escaping ()->()){
        blockActionDict[String(self.hashValue)] = block
    }
    
    private func whenTouchOne(){
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(tapActions))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapActions(){
        blockActionDict[String(self.hashValue)]!()
    }
}


//  TODO: UIView Extension
public extension UIView {
    //  上边线
    func addTopLine(lineColor: UIColor = UIColor(hexadecimalString: "#E3E3E3")) {
        _ = UIView().then({ (v) in
            addSubview(v)
            v.backgroundColor = lineColor
            v.snp.makeConstraints({ (make) in
                make.left.right.top.equalTo(0)
                make.height.equalTo(0.5)
            })
        })
    }
    
    //  底部线
    func addBottomline(lineColor: UIColor = UIColor(hexadecimalString: "#E3E3E3")) {
        _ = UIView().then { (v) in
            addSubview(v)
            v.backgroundColor = lineColor
            v.snp.makeConstraints({ (make) in
                make.left.right.bottom.equalTo(0)
                make.height.equalTo(0.5)
            })
        }
    }
    
    //  左边线
    func addLeftLine(lineColor: UIColor = UIColor(hexadecimalString: "#E3E3E3")) {
        _ = UIView().then { (v) in
            addSubview(v)
            v.backgroundColor = lineColor
            v.snp.makeConstraints({ (make) in
                make.top.bottom.left.equalTo(0)
                make.width.equalTo(0.5)
            })
        }
    }
    
    //  右边线
    func addRightLine(lineColor: UIColor = UIColor(hexadecimalString: "#E3E3E3")) {
        _ = UIView().then { (v) in
            addSubview(v)
            v.backgroundColor = lineColor
            v.snp.makeConstraints({ (make) in
                make.top.right.bottom.equalTo(0)
                make.width.equalTo(0.5)
            })
        }
    }
}
