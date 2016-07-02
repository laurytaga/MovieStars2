//
//  ViewController.swift
//  peliculas
//
//  Created by Laura on 4/2/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    
    //MARK: -VARIABLES GLOBALES
    let urlLogin = "http://lgadevelopment.esy.es/MovieLibrary/login.php"
    var respuesta:String?
    
    //MARK: -OUTLETS
    
    @IBOutlet weak var UserNameTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    //MARK: -ACTIONS
    
    //Comprobar si el usuario y contraseña corresponden a algun usuario si:
    //SI: acceder a la app : mostrar loading mientras que consulta
    //NO: toast dicciendo que si: mostrar loading mientras que consulta
    //La contraseña no es correcta: Contraseña incorrecta
    //Si el usuario no existe: Este usuario no existe
    @IBAction func acces(sender: AnyObject) {
        
        //loading
        loading.hidden = false
        loading.startAnimating()
        
        var isLogged:Bool = false
        let user = UserNameTF.text!
        let password = passwordTF.text!
        
        if(user.isEmpty || password.isEmpty){
            loading.hidden = true;
            loading.stopAnimating()
            displayAlertMessage("All fields are required")
            return;
        }
        
        
        //Comprobar si existe
        let request = NSMutableURLRequest(URL: NSURL(string: urlLogin)!)
        let postString = "user=\(user)&password=\(password)"
        request.HTTPMethod = "POST"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data:NSData?, response:NSURLResponse?, error:NSError?) in
            if error != nil{
                print("error=\(error)")
                return
            }
            
            
            //COMPROBAR LA RESPUESTA DEL JSON!
            //SI ES 1  ESTA LOGUEADO SINO SACAR EL MENSAJE!
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                    print("Not a Dictionary")
                    // put in function
                    return
                }
  
                
                let resultValue = JSONDictionary["success"] as! Int
                
                if(resultValue==1){
                    isLogged = true
                    
                    //guardar en localstorage eL userName
                    let localStorage = NSUserDefaults.standardUserDefaults()
                    localStorage.setObject(user, forKey: "userMovies")
                    
                   
                    
                }
                
                var message:String = JSONDictionary["message"] as! String!
            
                
                if(!isLogged){
                    message = JSONDictionary["message"] as! String
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let myAlert = UIAlertController(title: "Login", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ action in
                        if isLogged{

                            let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("contenedor"))! as UIViewController
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
        loading.stopAnimating()
        task.resume()


        
        

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //EVENTO PARA ESCONDER EL TECLADO
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(LoginController.dismissKeyBoard));
        self.view.addGestureRecognizer(tapGesture);
    }
    
    
    
    //FUNCIONES VARIAS
    
    
    
    func displayAlertMessage(userMessage:String){
        
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
    func dismissKeyBoard(){
        self.UserNameTF.resignFirstResponder();
        self.passwordTF.resignFirstResponder();
    }



}

