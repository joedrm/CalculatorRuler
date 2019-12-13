//
//  ViewController.swift
//  CalculatorRuler
//
//  Created by wdy on 2019/12/9.
//  Copyright © 2019 joe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let _ = UIButton(type: .custom).then { (v) in
            view.addSubview(v)
            v.setBackgroundImage(UIImage.imageWithColor(UIColor.orange), for: .normal)
            v.setTitle("开始计算", for: .normal)
            v.addTarget(self, action: #selector(click), for: .touchUpInside)
            v.snp.makeConstraints { (make) in
                make.centerX.equalTo(view.snp.centerX)
                make.centerY.equalTo(view.snp.centerY)
                make.width.equalTo(100)
                make.height.equalTo(50)
            }
        }
        
    }

    @objc func click() {
        
        let path = Bundle.main.path(forResource: "data", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: url)
            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let dict = jsonData as! [AnyHashable : Any]
            
            QNNCalculatorRulerView.showCalculatorView(dict, callBack: { (model) in
                print("结果为：\(model.value)")
            }) {
                
            }
            
        } catch let error as Error {
            print("读取本地数据出现错误!",error)
        }
    }

}

