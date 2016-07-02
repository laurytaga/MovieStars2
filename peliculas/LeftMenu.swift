//
//  LeftMenu.swift
//  peliculas
//
//  Created by Laura on 20/4/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit

class LeftMenu: UITableViewController {

    
    let menuOptions = ["Order by name", "Order by rating", "Logout"]
    
}

// MARK: - UITableViewDelegate methods

extension LeftMenu {
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //QUE HACER EN CADA CASO
        switch indexPath.row {
        case 0:
            
            NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
            PopularViewController()
            // ContainerVC.swift listens for this
            //NSNotificationCenter.defaultCenter().postNotificationName("openPushWindow", object: nil)
            return
        case 1:
            NSNotificationCenter.defaultCenter().postNotificationName("reload2", object: nil)
            PopularViewController()
            // Both FirstViewController and SecondViewController listen for this
            //NSNotificationCenter.defaultCenter().postNotificationName("openPushWindow", object: nil)
            return
        
        case 2:
            NSUserDefaults.standardUserDefaults().removeObjectForKey("userMovies")
            //HACER UN DIALOGOOO???
            
            let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("login"))! as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        default:
            print("indexPath.row:: \(indexPath.row)")
        }
        
        // also close the menu
        NSNotificationCenter.defaultCenter().postNotificationName("closeMenuViaNotification", object: nil)
        
    }
    
}

// MARK: - UITableViewDataSource methods

extension LeftMenu {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(20.0)
        cell.textLabel?.text = menuOptions[indexPath.row]
        return cell
    }

}
