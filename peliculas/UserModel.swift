//
//  UserModel.swift
//  peliculas
//
//  Created by Laura on 20/4/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import Foundation

class UserModel: NSObject {
    var user: String?
    var email: String?
    var password: String?
    
    init(user:String, email:String, password:String) {
        self.user = user
        self.email = email
        self.password = password
    }
    
    override init() {
        
    }
}