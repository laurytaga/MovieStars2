//
//  RegistroViewController.swift
//  peliculas
//
//  Created by Laura on 4/2/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit

class RegistroViewController: UIViewController {

    
    //MARK: -VARIABLES GLOBALES
    let urlRegistrar = "http://lgadevelopment.esy.es/MovieLibrary/registro.php"
    var respuesta:String?
    
    
    
    //MARK: -OUTLETS
    
    @IBOutlet weak var userNameLbl: UITextField!
    
    @IBOutlet weak var emailLbl: UITextField!
    
    @IBOutlet weak var passwordLbl: UITextField!
    
    @IBOutlet weak var repitPasswordLbl: UITextField!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    //MARK: -LIFE FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        //EVENTO PARA ESCONDER EL TECLADO
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(RegistroViewController.dismissKeyBoard));
        self.view.addGestureRecognizer(tapGesture);
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: -ACTIONS

    @IBAction func registerAction(sender: AnyObject) {
        
        //loading
        loading.hidden = false
        
        var isRegistered:Bool = false
        
        //Preparamos las variables
        let userName = userNameLbl.text!
        let email = emailLbl.text!
        let password = passwordLbl.text!
        let repitPassword = repitPasswordLbl.text!
        
        let lengthPwd = passwordLbl.text?.characters.count
        
        //Comprobaciones
        //1) Campos vacios
        
        if(userName.isEmpty || email.isEmpty || password.isEmpty || repitPassword.isEmpty){
            
            displayAlertMessage("All fields are required")
            loading.hidden = true;
            loading.stopAnimating()
            return;
            
        }
        //2) Contraseñas mayores o iguales de 6 carácteres e iguales
        if (lengthPwd<4){
            displayAlertMessage("You need 4 characters at least in password field")
            loading.hidden = true;
            return;
        }
        if(password != repitPassword){
            displayAlertMessage("The passwords don't match")
            loading.hidden = true;
            return;
            
        }
        //3) Email con un @
        if(!(email.containsString("@"))){
            displayAlertMessage("Wrong email")
            loading.hidden = true;
            return;
        }
        
        //Guardar datos php
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlRegistrar)!)
        let postString = "user=\(userName)&password=\(password)&email=\(email)"
        request.HTTPMethod = "POST"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data:NSData?, response:NSURLResponse?, error:NSError?) in
            if error != nil{
                print("error=\(error)")
                return
            }
        
            
            //COMPROBAR LA RESPUESTA DEL JSON!
            //SI ES 1  ESTA REGISTRADO SINO SACAR EL MENSAJE!
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                    print("Not a Dictionary")
                    // put in function
                    return
                }
                
                let resultValue = JSONDictionary["success"] as! Int
                
                
                
                if(resultValue==1){
                    isRegistered = true
                    
                    //guardar en localstorage ek userName
                    let localStorage = NSUserDefaults.standardUserDefaults()
                    localStorage.setObject(userName, forKey: "userMovies")
                
             
                    
                }
                var message:String = JSONDictionary["message"] as! String!
                if(!isRegistered){
                    message = JSONDictionary["message"] as! String
                }
                    
                dispatch_async(dispatch_get_main_queue(), {
                        
                    let myAlert = UIAlertController(title: "Register", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ action in
                        if isRegistered{
                            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("contenedor") as! ContainerVC
                            self.presentViewController(vc, animated: true, completion: nil)
                            
                        }
                        else{
                           self.dismissViewControllerAnimated(true, completion: nil) 
                        }
                    }
                        
                    myAlert.addAction(okAction)
                    self.presentViewController(myAlert, animated: true, completion: nil)
                })
           
            }
            catch let JSONError as NSError {
                print("\(JSONError)")
            }
            
        }
        loading.hidden = true;
        task.resume()
        
        
    }
    
    
    //FUNCIONES VARIAS
    

    
    func displayAlertMessage(userMessage:String){
        
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
    func dismissKeyBoard(){
        self.userNameLbl.resignFirstResponder();
        self.passwordLbl.resignFirstResponder();
        self.emailLbl.resignFirstResponder();
        self.repitPasswordLbl.resignFirstResponder();
    }
    
    
    
}
