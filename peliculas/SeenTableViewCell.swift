//
//  SeenTableViewCell.swift
//  peliculas
//
//  Created by Laura on 10/6/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit

class SeenTableViewCell: UITableViewCell {
    
    
    //MARK: VARIABLES GLOBALES
    var id:String = ""
    var title:String = ""
    let pending = "pending"
    
    let user = NSUserDefaults.standardUserDefaults().stringForKey("userMovies")
    var delegate: UIViewController?
    //MARK: -IBOUTLETS
    
    
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var scoreLBL: UILabel!
    @IBOutlet weak var genresLBL: UILabel!
    
    
    
    //MARK: -ACTIONS
    
    
    @IBAction func deleteSeen(sender: AnyObject) {
        SeenViewController().deletePeliculaVista(title, user: user!)
    }
    
    @IBAction func addToPending(sender: AnyObject) {
        SeenViewController().getPelicula(title)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

