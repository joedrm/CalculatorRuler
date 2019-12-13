//
//  AppDelegate.swift
//  CalculatorRuler
//
//  Created by wdy on 2019/12/9.
//  Copyright © 2019 joe. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.white
        
        self.window?.rootViewController = ViewController()
        
        return true
    }

}

