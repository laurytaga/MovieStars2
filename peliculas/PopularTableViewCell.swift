//
//  PopularTableViewCell.swift
//  peliculas
//
//  Created by Laura on 19/5/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit

class PopularTableViewCell: UITableViewCell {

    
    //MARK: VARIABLES GLOBALES
    var id:String = ""
    let pending = "pending"
    let seen = "seen"
    var delegate: UIViewController?
    //MARK: -IBOUTLETS
    
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var genresLBL: UILabel!
    @IBOutlet weak var scoreLBL: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    

    
    //MARK: -ACTIONS
    
    @IBAction func addPending(sender: AnyObject) {
        PopularViewController().getPelicula(id, opcion: pending)
    }
    @IBAction func addSeen(sender: AnyObject) {
        PopularViewController().getPelicula(id, opcion: seen)
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
