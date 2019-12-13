//
//  QNNCalculatorWarningView.swift
//  QNN
//
//  Created by joewang on 2018/11/15.
//  Copyright © 2018 qianshengqian. All rights reserved.
//

import UIKit

class QNNCalculatorWarningView: UIView {

    weak var titleLabel : UILabel!
    private let shapeLayer = CAShapeLayer()
    private var drawPath = UIBezierPath()
    
    public var title : String {
        set{
            if let label = titleLabel {
                label.text = newValue
            }
        }
        
        get{
            if let label = titleLabel {
                return label.text ?? ""
            }
            return ""
        }
    }
    
    public var bgColor : UIColor {
        set{
            shapeLayer.fillColor = newValue.cgColor
        }
        
        get{
            return UIColor(cgColor: shapeLayer.fillColor ?? UIColor(hexadecimalString: "333333") as! CGColor)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupUI() {
        
        backgroundColor = UIColor.clear
        
        shapeLayer.fillColor = bgColor.cgColor
        self.layer.addSublayer(shapeLayer)
        
        titleLabel = UILabel.init().then { (v) in
            addSubview(v)
            v.textAlignment = .center
            v.font = UIFont.systemFont(ofSize: 14)~
            v.textColor = UIColor(hexadecimalString: "FFFFFF")
            v.snp.makeConstraints({ (make) in
                make.left.top.right.equalTo(0)
                make.bottom.equalTo(-4)
            })
        }
    }

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawShapLayer(rect)
    }
    
    func drawShapLayer(_ rect: CGRect) {
        
        shapeLayer.path = UIBezierPath().cgPath
        drawPath = UIBezierPath()
        
        let arrowHeight : CGFloat   = 4  // 小三角的高度
        let arrowWidth : CGFloat    = 8*0.5  // 小三角的一半的宽度
        let width : CGFloat         = rect.width
        let height : CGFloat        = rect.height - arrowHeight
        let corner : CGFloat        = 2  // 圆角
        let pi : CGFloat            = CGFloat(Double.pi)
        
        drawPath.addArc(withCenter: CGPoint(x: corner, y: corner), radius: corner, startAngle: pi, endAngle: pi*1.5, clockwise: true)
        drawPath.move(to: CGPoint(x: corner, y: 0))
        drawPath.addLine(to: CGPoint(x: width - corner, y: 0))
        
        drawPath.addArc(withCenter: CGPoint(x: width - corner, y: corner), radius: corner, startAngle: pi*1.5, endAngle: 0, clockwise: true)
        drawPath.addLine(to: CGPoint(x: width, y: height - corner))
        
        drawPath.addArc(withCenter: CGPoint(x: width - corner, y: height - corner), radius: corner, startAngle: 0, endAngle: pi*0.5, clockwise: true)
        //drawPath.move(to: CGPoint(x: width - corner, y: height))
        drawPath.addLine(to: CGPoint(x: width/2 + arrowWidth, y: height))
        drawPath.addLine(to: CGPoint(x: width/2, y: height + arrowHeight))
        drawPath.addLine(to: CGPoint(x: width/2 - arrowWidth, y: height))
        drawPath.addLine(to: CGPoint(x: corner, y: height))
        
        drawPath.addArc(withCenter: CGPoint(x: corner, y: height - corner), radius: corner, startAngle: pi*0.5, endAngle: pi, clockwise: true)
        drawPath.addLine(to: CGPoint(x: 0, y: corner))
        
        drawPath.close()
        
        shapeLayer.path = drawPath.cgPath
    }
    
    func showWarningView() {
        
        drawShapLayer(self.frame)
        
        guard self.isHidden else {
            return
        }
        
        self.isHidden = false
        UIView.SpringAnimator(duration: 0.5)
            .damping(0.9)
            .velocity(0.7)
            .options(.curveEaseInOut)
            .animations {
                self.alpha = 1
            }.completion({ (finished) in
            }).animate()
    }
    
    func hideWarningView() {
        
        guard !self.isHidden else {
            return
        }
        
        UIView.SpringAnimator(duration: 0.5)
            .damping(0.9)
            .velocity(0.7)
            .options(.curveEaseInOut)
            .animations {
                self.alpha = 0
            }.completion({ (finished) in
                self.isHidden = true
            }).animate()
    }
}
