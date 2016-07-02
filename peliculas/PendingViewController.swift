//
//  PendingViewController.swift
//  peliculas
//
//  Created by Laura on 20/4/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Haneke

class PendingViewController: UIViewController, UISearchBarDelegate{
    
    //MARK: -VARIABLES
    var movies = [Pelicula]()
    var filtered = [Pelicula]()
    var moviesBuscadas = [Pelicula]()
    
    var searchActive : Bool = false
    var getPoster : Bool = false
    var isRefreshing : Bool = false
    
    var refreshControl: UIRefreshControl!
    
    let user = NSUserDefaults.standardUserDefaults().stringForKey("userMovies")
    
    let headers = ["trakt-api-version":"2","trakt-api-key":"2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf"]
    
    let urlInsertar:NSURL = NSURL(string: "http://lgadevelopment.esy.es/MovieLibrary/PeliculasVistas/insertarPeliculaVistaBD.php")!
    
    //MARK: -OUTLETS
    
    @IBOutlet weak var search: UISearchBar!

    @IBOutlet weak var pendingTable: UITableView!
    
    
    @IBAction func information(sender: AnyObject) {
        let information : informationVC = self.storyboard?.instantiateViewControllerWithIdentifier("information") as! informationVC
        
        navigationController?.pushViewController(information, animated: true)
    }
    
    
    //refresh
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pendingTable.delegate = self
        pendingTable.dataSource = self
        search.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(PopularViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        pendingTable.addSubview(refreshControl)
        
        //AQUI SERIA A UN PENDINGMOVIES()
        pendingMovies()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PendingViewController.orderTable(_:)), name: "reload", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PendingViewController.orderTableByRating(_:)), name: "reload2", object: nil)
    }
    override func viewWillAppear(animated: Bool) {
        pendingMovies()
    }
    func refresh(sender:AnyObject) {
        isRefreshing = true
        pendingMovies()
    }
    
    
    //AQUI IRIA EL PENDING MOVIES
    func pendingMovies(){
        let urlString = "http://lgadevelopment.esy.es/MovieLibrary/PeliculasPendientes/obtenerPeliculasPendientes.php?user=\(user!)"
        Alamofire.request(Method.GET, urlString).responseJSON{ response in
            if (response.result.value != nil) {
                self.movies.removeAll()
                let swiftyJSON = JSON(response.result.value!)
                self.parseMovieJson(swiftyJSON)
            }else{
                print("error")
            }
        }
        
    }
    
    //PARA LAS FUNCIONES DE LOS BOTONES
    func getPelicula(title: String) {
        var peliculaX:Pelicula = Pelicula()
        
        let urlString : String = "http://lgadevelopment.esy.es/MovieLibrary/PeliculasPendientes/detallePeliculaPendiente.php?title=\(title)&user=\(user!)"
        
        let urlString2 = urlString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        Alamofire.request(Method.GET, urlString2).responseJSON{ response in
            
            if (response.result.value != nil) {
                self.movies.removeAll()
                let swiftyJSON = JSON(response.result.value!)
                peliculaX = self.parseMovieJsonPeliX(swiftyJSON)
                self.insertarPeliculaVista(peliculaX)
                
            }else{
                print("error")
            }
        }
        
    }
    
    
    //FUNCION INSERTAR PELICULA PENDIENTE
    
    func insertarPeliculaVista(peliculaX:Pelicula) {
        
        
        // create some JSON data and configure the request
        let json1 = "{\"runtime\": \"\(peliculaX.duration!)\", \"genre\": \"\(peliculaX.genres!)\", \"rating\": \"\(peliculaX.rating!)\", \"title\":\"\(peliculaX.title!)\", \"fanart\": \"\(peliculaX.fanart!)\", \"id\": \"\(peliculaX.id!)\", \"trailer\":\"\(peliculaX.trailer!)\", \"poster\": \"\(peliculaX.poster!)\", \"overview\":\"\(peliculaX.overview!)\", \"user\":\"\(user!)\", \"year\":\"\(peliculaX.year!)\", \"comment\":\"\(peliculaX.comment!)\"}"
        
        
        
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
                        
                        let alertController = UIAlertController(title: "Movie: \(peliculaX.title!)", message: "The movie was add to seen movies", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    })
                    
                    self.eliminarPeliculaPendiente(peliculaX.title!, user: self.user!)
                    
                    
                }else if(resultValue==3){
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Movie: \(peliculaX.title!)", message: "The movie is already in seen list", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    })
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Movie: \(peliculaX.title!)", message: "Error!", preferredStyle: .Alert)
                        
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

    func eliminarPeliculaPendiente(title:String, user:String){
        let json1 = "{\"title\": \"\(title)\", \"user\":\"\(user)\"}"
        
        //Preparamos la url
        
        let urlDelete:NSURL = NSURL(string: "http://lgadevelopment.esy.es/MovieLibrary/PeliculasPendientes/eliminarPeliculaPendiente.php")!
        
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
                        
                        let alertController = UIAlertController(title: "Movie: \(title)", message: "The movie was remove", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                        
                    })
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Movie: \(title)", message: "Error!", preferredStyle: .Alert)
                        
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

    
    
    //MARK: -ACTIONS
    
    @IBAction func toggleMenu(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
        
    }
    
    @IBAction func addSeen(sender: AnyObject) {
    }
    
    
    
    func orderTable(notification: NSNotification) {
        movies.sortInPlace({
            $0.title < $1.title
        })
        pendingTable.reloadData()
    }
    
    func orderTableByRating(notification: NSNotification) {
        movies.sortInPlace({
            $0.rating > $1.rating
        })
        pendingTable.reloadData()
    }
    
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    //Esto no hace nada
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        //doSearch(searchBar)
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = movies.filter({ movie in
            return (movie.title?.lowercaseString.containsString(searchText.lowercaseString))!
        })
        
        if filtered.count == 0 {
            searchActive = false
        }else{
            searchActive = true
        }
    pendingTable.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Parse una pelicula normal
    //Parse una pelicula normal
    func parseMovieJson(json:SwiftyJSON.JSON){
        
        for peliculaVista in json["peliculaPendiente"].arrayValue {
            let movieClass = Pelicula()
            
            if let title = peliculaVista["title"].string{
                movieClass.title = title
                
            }
            if let year = peliculaVista["year"].string{
                movieClass.year = year
            }
            if let ids = peliculaVista["id"].string {
                movieClass.id = ids
            }
            if let user = peliculaVista["user"].string {
                movieClass.user = user
            }
            if let overview = peliculaVista["overview"].string{
                movieClass.overview = overview
            }
            if let runtime = peliculaVista["runtime"].string{
                movieClass.duration = runtime
            }
            if let trailer = peliculaVista["trailer"].string {
                movieClass.trailer = trailer
            }
            if let rating = peliculaVista["rating"].string{
                movieClass.rating = rating
            }
            if let genres = peliculaVista["genre"].string{
                movieClass.genres = genres
            }
            if let fanart = peliculaVista["fanart"].string {
                movieClass.fanart = fanart
            }
            if let poster = peliculaVista["poster"].string {
                movieClass.poster = poster
            }
            if let comment = peliculaVista["comment"].string{
                movieClass.comment = comment
            }
            
            self.movies.append(movieClass)
        }
        self.pendingTable.reloadData()
        if isRefreshing {
            refreshControl?.endRefreshing()
        }
    }
    
    

    
    //Parsear pelicula X
    func parseMovieJsonPeliX(json:SwiftyJSON.JSON)->Pelicula{
        let movie = json
        let movieClass = Pelicula()
        
        if let title = movie["title"].string{
            movieClass.title = title
            
        }
        if let id = movie["id"].string{
            movieClass.id = id
            
        }
        if let rating = movie["rating"].string{
            movieClass.rating = rating
        }
        if let genres = movie["genre"].string{
            movieClass.genres = genres
        }
        if let poster = movie["poster"].string {
            movieClass.poster = poster
        }
        
        if let fanart = movie["fanart"].string {
            movieClass.fanart = fanart
        }
        
        if let runtime = movie["runtime"].string {
            movieClass.duration = runtime
        }
        
        if let overview = movie["overview"].string {
            movieClass.overview = overview
        }
        
        if let year = movie["year"].string {
            movieClass.year = year
        }
        
        if let trailer = movie["trailer"].string {
            movieClass.trailer = trailer
        }
        
        if let comment = movie["comment"].string {
            movieClass.comment = comment
        }
        
        
        return movieClass
    }
    
}



//MARK: -FUNCIONES TABLE

extension PendingViewController : UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive {
            return filtered.count
        }else{
            return movies.count
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:PendingTableViewCell = tableView.dequeueReusableCellWithIdentifier("CellPending", forIndexPath: indexPath) as! PendingTableViewCell
        
        let peli:Pelicula
        
        
        if searchActive == true{
            peli = filtered[indexPath.row];
        }else{
            peli = movies[indexPath.row];
        }
        
        cell.titleLBL.text = peli.title
        cell.scoreLBL.text = peli.rating
        cell.genresLBL.text = peli.genres
        
        cell.scoreLBL.font = UIFont.boldSystemFontOfSize(15.0)
        
        if Double(peli.rating!)! < 5  {
            cell.scoreLBL.textColor = UIColor.redColor()
        }else if Double(peli.rating!)! >= 5 && Double(peli.rating!)! < 7 {
            cell.scoreLBL.textColor = UIColor.orangeColor()
        }else if Double(peli.rating!)! >= 7 && Double(peli.rating!)! <= 9 {
            cell.scoreLBL.textColor = UIColor(hue: 47/360, saturation: 100/100, brightness: 91/100, alpha: 1.0)
        }else{
            cell.scoreLBL.textColor = UIColor.greenColor()
        }
        
        
        
        //MONTAR IMAGEN DESDE UNA URL
        /*if let url = peli.poster {
         cell.posterImage.hnk_setImageFromURL((NSURL(string:url)!), placeholder: UIImage(named: "placeholder.png"))
         }*/
        
        if peli.poster != nil{
            if let urlPoster:NSURL = NSURL(string: peli.poster!)!{
                let data:NSData
                if NSData(contentsOfURL: urlPoster) == nil{
                    cell.posterImage.image = UIImage(named: "no.png")
                }else{
                    data = NSData(contentsOfURL: urlPoster)!
                    cell.posterImage.image = UIImage(data: data)
                }
                
                
            }
        }else{
            
            cell.posterImage.image = UIImage(named: "no.png")
        }
        
        cell.title = peli.title!
        return cell
    }
}





extension PendingViewController : UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // cell selected code here
        let myDetail : DetailPendingVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailPending") as! DetailPendingVC
         
         myDetail.data = movies[indexPath.row]
         
         navigationController?.pushViewController(myDetail, animated: true)
        
    }
}


