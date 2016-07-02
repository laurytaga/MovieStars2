//
//  DetailSeenVC.swift
//  peliculas
//
//  Created by Laura on 22/6/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Haneke

class DetailSeenVC: UIViewController {

    
    var data: Pelicula = Pelicula()
    var pulsado = false
    var color:UIColor = UIColor()
    
    //MARK: -OUTLETS
    
    @IBOutlet var view22: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var rating: UITextField!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var duraccion: UILabel!
    @IBOutlet weak var generos: UILabel!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var trailer: UIWebView!
    @IBOutlet weak var coment: UITextView!
    
    
    
    //MARK: -ACTIONS
    
    //CAMBIAR LA URL Y MIRAR PHP
    
    @IBAction func addPending(sender: AnyObject) {
        
        let urlInsertar:NSURL = NSURL(string: "http://lgadevelopment.esy.es/MovieLibrary/PeliculasPendientes/insertarPeliculaPendienteBD.php")!
        let user = NSUserDefaults.standardUserDefaults().stringForKey("userMovies")
        
        // create some JSON data and configure the request
        let json1 = "{\"runtime\": \"\(data.duration!)\", \"genre\": \"\(data.genres!)\", \"rating\": \"\(data.rating!)\", \"title\":\"\(data.title!)\", \"fanart\": \"\(data.fanart!)\", \"id\": \"\(data.id!)\", \"trailer\":\"\(data.trailer!)\", \"poster\": \"\(data.poster!)\", \"comment\": \"\(data.comment!)\", \"overview\":\"\(data.overview!)\", \"user\":\"\(user!)\", \"year\":\"\(data.year!)\"}"
        
        
        
        //Preparamos la url
        
        let request = NSMutableURLRequest(URL: urlInsertar)
        //Preparamos el metodo de envio
        request.HTTPMethod = "POST"
        //Preparamos los headers
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Preparamos el body que vamos a enviar
        request.HTTPBody = json1.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Comienza el envio de datos
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data:NSData?, response:NSURLResponse?, error:NSError?) in
            //Si hay algun error
            if error != nil{
                print("error=\(error)")
                return
            }
            
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                    print("Not a Dictionary")
                    return
                }
                
                let resultValue = JSONDictionary["estado"] as! Int!
                if(resultValue==1){
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let alertController = UIAlertController(title: "Movie: \(self.data.title!)", message: "The movie was add to pending movies", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    })
                    
                }else if(resultValue==3){
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Movie: \(self.data.title!)", message: "The movie is already in pending list", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    })
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Movie: \(self.data.title!)", message: "Error!", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    })
                    
                }
                
                
            }
            catch let JSONError as NSError {
                print("\(JSONError)")
            }
            
            
            
        }
        
        
        task.resume()

    }
   
    @IBAction func edit(sender: AnyObject) {
        
        if pulsado == false {
            rating.enabled = true
            coment.editable = true
            coment.backgroundColor = UIColor(colorLiteralRed: 199.0, green: 79.0, blue: 00.0, alpha: 1.0)
            pulsado = true
        }else{
            rating.enabled = false
            coment.editable = false
            coment.backgroundColor = color
            pulsado = false
            
            let urlEditar:NSURL = NSURL(string: "http://lgadevelopment.esy.es/MovieLibrary/PeliculasVistas/actualizarPeliculaVista.php")!
            let user = NSUserDefaults.standardUserDefaults().stringForKey("userMovies")
            
            let rating2 = rating.text?.stringByReplacingOccurrencesOfString(",", withString: ".")
            
            // create some JSON data and configure the request
            let json1 = "{\"rating\": \"\(rating2!)\", \"title\":\"\(data.title!)\", \"comment\": \"\(coment.text!)\", \"user\":\"\(user!)\"}"
            
            //Preparamos la url
            
            let request = NSMutableURLRequest(URL: urlEditar)
            //Preparamos el metodo de envio
            request.HTTPMethod = "POST"
            //Preparamos los headers
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //Preparamos el body que vamos a enviar
            request.HTTPBody = json1.dataUsingEncoding(NSUTF8StringEncoding)
            
            //Comienza el envio de datos
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
                (data:NSData?, response:NSURLResponse?, error:NSError?) in
                //Si hay algun error
                if error != nil{
                    print("error=\(error)")
                    return
                }
                
                
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                    guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                        print("Not a Dictionary")
                        return
                    }
                    
                    
                    let resultValue = JSONDictionary["estado"] as! Int!
                    if(resultValue==1){
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let alertController = UIAlertController(title: "Movie: \(self.data.title!)", message: "The movie was update", preferredStyle: .Alert)
                            
                            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                                
                            }
                            alertController.addAction(OKAction)
                            
                            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                        })
                        self.data.comment = self.coment.text
                        self.data.rating = self.rating.text
                        
                    }else if(resultValue==3){
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = UIAlertController(title: "Movie: \(self.data.title!)", message: "The movie was not update", preferredStyle: .Alert)
                            
                            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                               
                                
                            }
                            alertController.addAction(OKAction)
                            
                            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                        })
                        
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = UIAlertController(title: "Movie: \(self.data.title!)", message: "Error!", preferredStyle: .Alert)
                            
                            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                                
                                
                            }
                            alertController.addAction(OKAction)
                            
                            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                        })
                        
                    }
                    
                    
                }
                catch let JSONError as NSError {
                    print("\(JSONError)")
                }
                
                
                
            }
            
            
            task.resume()

            
            
        }
    }
    
    @IBAction func deleteSeen(sender: AnyObject) {
        let json1 = "{\"title\": \"\(data.title!)\", \"user\":\"\(data.user!)\"}"
        
        //Preparamos la url
        
        let urlDelete:NSURL = NSURL(string: "http://lgadevelopment.esy.es/MovieLibrary/PeliculasVistas/eliminarPeliculaVista.php")!
        
        let request = NSMutableURLRequest(URL: urlDelete)
        //Preparamos el metodo de envio
        request.HTTPMethod = "POST"
        //Preparamos los headers
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Preparamos el body que vamos a enviar
        request.HTTPBody = json1.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Comienza el envio de datos
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data:NSData?, response:NSURLResponse?, error:NSError?) in
            //Si hay algun error
            if error != nil{
                print("error=\(error)")
                return
            }
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                    print("Not a Dictionary")
                    return
                }
                

                let resultValue = JSONDictionary["estado"] as! Int!
                if(resultValue==1){
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let alertController = UIAlertController(title: "Movie: \(self.data.title!)", message: "The movie was remove", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                        
                    })
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Movie: \(self.data.title!)", message: "Error!", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    })
                    
                }
                
            }
            catch let JSONError as NSError {
                print("\(JSONError)")
            }
            
            
            
        }
        
        
        task.resume()

    }
    
    @IBAction func traducirSP(sender: AnyObject) {
        
        let headers = ["trakt-api-version":"2","trakt-api-key":"2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf"]
        let urlString = "https://api-v2launch.trakt.tv/movies/\(data.id!)/translations/es"
        Alamofire.request(Method.GET, urlString, headers: headers).responseJSON{ response in
            if (response.result.value != nil) {
                let swiftyJSON = JSON(response.result.value!)
                self.parseMovieJSONTranslate(swiftyJSON)
            }else{
                print("error")
            }
        }
        
    }
    
    func parseMovieJSONTranslate(json:SwiftyJSON.JSON) {
        if let moviesArray = json.array {
            for movie in moviesArray {
                if let title = movie["title"].string{
                    titulo.text = title
                }
                if let overview = movie["overview"].string{
                    self.overview.text = overview
                    
                }
            }
        }
        
    }

    
    @IBAction func traducirEN(sender: AnyObject) {
        let headers = ["trakt-api-version":"2","trakt-api-key":"2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf"]
        let urlString = "https://api-v2launch.trakt.tv/movies/\(data.id!)/translations/en"
        Alamofire.request(Method.GET, urlString, headers: headers).responseJSON{ response in
            if (response.result.value != nil) {
                let swiftyJSON = JSON(response.result.value!)
                self.parseMovieJSONTranslate(swiftyJSON)
            }else{
                print("error")
            }
        }

    }
    
    @IBAction func share(sender: AnyObject) {
        
        let textToShare = "Check out this movie: \(data.title!)"
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        //New Excluded Activities Code
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        
        
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        color = coment.backgroundColor!
        
        let urlFanart:NSURL = NSURL(string: data.fanart!)!
        if data.fanart! != "nil"{
            let dato:NSData = NSData(contentsOfURL: urlFanart)!
            logo.image = UIImage(data: dato)
            
        }
        
        
        titulo.text = data.title
        
        if Double(data.rating!)! < 5  {
            rating.textColor = UIColor.redColor()
        }else if Double(data.rating!)! >= 5 && Double(data.rating!)! < 7 {
            rating.textColor = UIColor.orangeColor()
        }else if Double(data.rating!)! >= 7 && Double(data.rating!)! <= 9 {
            rating.textColor = UIColor(hue: 47/360, saturation: 100/100, brightness: 91/100, alpha: 1.0)
        }else{
            rating.textColor = UIColor.greenColor()
        }
        
        rating.text = data.rating
        
        year.text = data.year
        duraccion.text = data.duration
        generos.text = data.genres
        overview.textAlignment = NSTextAlignment.Justified
        overview.font = overview.font?.fontWithSize(17)
        overview.text = data.overview
        if data.comment == "" {
            coment.text = "No comments"
        }else{
            coment.text = data.comment
        }
        
        if data.trailer != nil {
            
            //Note: use the "embed" address instead of the "watch" address.
            //let myURLRequest : NSURLRequest = NSURLRequest(URL: myVideoURL!)
            //trailer.loadRequest(myURLRequest)
            
            let trailer2 = data.trailer?.stringByReplacingOccurrencesOfString("http://youtube.com/watch?v=", withString: "")
            
            let youtubeLink:String = "http://www.youtube.com/embed/\(trailer2!)"
            
            let height = 160
            let frame = 0
            let Code:NSString = "<iframe width=\(view22.frame.width) height=\(height) src=\(youtubeLink) frameborder=\(frame) allowfullscreen></iframe>"
            
            
            self.trailer.loadHTMLString(Code as String, baseURL: nil)
            
            trailer.scrollView.scrollEnabled = false;
            trailer.scrollView.bounces = false;
        }else{
            print("No video")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}
