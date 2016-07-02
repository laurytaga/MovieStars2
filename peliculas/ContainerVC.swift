//
//  ContainerVC.swift
//  peliculas
//
//  Created by Laura on 20/4/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit

class ContainerVC: UIViewController {
    
    // This value matches the left menu's width in the Storyboard
    let leftMenuWidth:CGFloat = 260
    
    // OUTLET DEL SCROLLVIEW
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        // Initially close menu programmatically.  This needs to be done on the main thread initially in order to work.
        dispatch_async(dispatch_get_main_queue()) {
            self.closeMenu(false)
        }
        
        // Tab bar controller's child pages have a top-left button toggles the menu
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerVC.toggleMenu), name: "toggleMenu", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerVC.closeMenuViaNotification), name: "closeMenuViaNotification", object: nil)
        
    }

    // Cleanup notifications added in viewDidLoad
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func toggleMenu(){
        scrollView.contentOffset.x == 0  ? closeMenu() : openMenu()
    }
    
    // This wrapper function is necessary because
    // closeMenu params do not match up with Notification
    func closeMenuViaNotification(){
        closeMenu()
    }
    
    // Use scrollview content offset-x to slide the menu.
    func closeMenu(animated:Bool = true){
        scrollView.setContentOffset(CGPoint(x: leftMenuWidth, y: 0), animated: animated)
    }
    
    // Open is the natural state of the menu because of how the storyboard is setup.
    func openMenu(){
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    
}

extension ContainerVC : UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.pagingEnabled = true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollView.pagingEnabled = false
    }

}
