//
//  TabVCTemplate.swift
//  peliculas
//
//  Created by Laura on 20/4/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit

class TabVCTemplate: UIViewController {

    // placeholder for the tab's index
    var selectedTab = 0
    
    override func viewDidLoad() {
        
        // Sent from LeftMenu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabVCTemplate.openPushWindow), name: "openPushWindow", object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSNotificationCenter.defaultCenter().postNotificationName("closeMenuViaNotification", object: nil)
        view.endEditing(true)
    }
    
    func openPushWindow(){
        if tabBarController?.selectedIndex == selectedTab {
            performSegueWithIdentifier("openPushWindow", sender: nil)
        }
    }

}
