//
//  TabBarController.swift
//  peliculas
//
//  Created by Laura on 10/6/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSForegroundColorAttributeName:UIColor.blackColor()], forState: .Normal)
        
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSForegroundColorAttributeName:UIColor.darkGrayColor()], forState: .Selected)
        
        
        UITabBar.appearance().tintColor = UIColor.darkGrayColor()
        
        let icons = ["video.png", "medical.png", "time.png"]
        
        var i = 0
        for item in self.tabBar.items! as [UITabBarItem] {
            item.image = UIImage(named:icons[i])?.imageWithRenderingMode(.AlwaysOriginal)
            i += 1
        }
    }
}