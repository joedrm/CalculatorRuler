//
//  QNNCalculatorMessageView.swift
//  QNN
//
//  Created by joewang on 2018/11/15.
//  Copyright © 2018 qianshengqian. All rights reserved.
//

import UIKit

private let ArrowHeight : CGFloat   = 6

class QNNCalculatorMessageView: UIView {

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
            return UIColor(cgColor: shapeLayer.fillColor ?? UIColor(hexadecimalString: "FFFFFF") as! CGColor)
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
        
        shapeLayer.fillColor = UIColor(hexadecimalString: "FFFFFF").cgColor
        self.layer.addSublayer(shapeLayer)
        
        titleLabel = UILabel.init().then { (v) in
            addSubview(v)
            v.textAlignment = .center
            v.font = UIFont.systemFont(ofSize: 14)~
            v.textColor = UIColor(hexadecimalString: "333333")
            v.snp.makeConstraints({ (make) in
                make.left.bottom.right.equalTo(0)
                make.top.equalTo(ArrowHeight)
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
        
        let arrowHeight : CGFloat   = ArrowHeight  // 小三角的高度
        let arrowWidth : CGFloat    = 8*0.5  // 小三角的一半的宽度
        let width : CGFloat         = rect.width
        let height : CGFloat        = rect.height
        let corner : CGFloat        = (height - arrowHeight) * 0.5  // 圆角
        let pi : CGFloat            = CGFloat(Double.pi)
        
        drawPath.addArc(withCenter: CGPoint(x: corner, y: corner + arrowHeight), radius: corner, startAngle: pi*0.5, endAngle: pi*1.5, clockwise: true)
        drawPath.move(to: CGPoint(x: corner, y: arrowHeight))
        drawPath.addLine(to: CGPoint(x: width/2 - arrowWidth, y: arrowHeight))
        drawPath.addLine(to: CGPoint(x: width/2, y: 0))
        drawPath.addLine(to: CGPoint(x: width/2 + arrowWidth, y: arrowHeight))
        drawPath.addLine(to: CGPoint(x: width - corner, y: arrowHeight))
        drawPath.addArc(withCenter: CGPoint(x: width - corner, y: corner + arrowHeight), radius: corner, startAngle: pi*1.5, endAngle: pi*0.5, clockwise: true)
        drawPath.addLine(to: CGPoint(x: corner, y: height))
    
        
        drawPath.close()
        
        shapeLayer.shadowPath = drawPath.cgPath
        shapeLayer.shadowColor = UIColor(hexadecimalString: "B0B0B0").cgColor
        shapeLayer.shadowOffset = CGSize.init(width: 0, height: 0)
        shapeLayer.shadowOpacity = 0.40
        shapeLayer.shadowRadius = 5.0
        
        shapeLayer.path = drawPath.cgPath
        
    }
}
