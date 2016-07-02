//
//  PopularViewController.swift
//  peliculas
//
//  Created by Laura on 20/4/16.
//  Copyright © 2016 Laura. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Haneke



class PopularViewController: UIViewController, UISearchBarDelegate{

    //MARK: -VARIABLES
    var movies = [Pelicula]()
    var filtered = [Pelicula]()
    var moviesBuscadas = [Pelicula]()
    
    var searchActive : Bool = false
    var getPoster : Bool = false
    var isRefreshing : Bool = false
    var isAddPending = true
    
    var refreshControl: UIRefreshControl!
    
    let headers = ["trakt-api-version":"2","trakt-api-key":"2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf"]
    
    let urlInsertar:NSURL = NSURL(string: "http://lgadevelopment.esy.es/MovieLibrary/PeliculasPendientes/insertarPeliculaPendiente.php")!
    
    let urlInsertarVista:NSURL = NSURL(string: "http://lgadevelopment.esy.es/MovieLibrary/PeliculasVistas/insertarPeliculaVista.php")!
    
    
    //MARK: -OUTLETS
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tablePopular: UITableView!
    
    
    @IBAction func information(sender: AnyObject) {
        let information : informationVC = self.storyboard?.instantiateViewControllerWithIdentifier("information") as! informationVC
        
        navigationController?.pushViewController(information, animated: true)

    }
    
    
   //MARK: -LIFE CICLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablePopular.delegate = self
        tablePopular.dataSource = self
        search.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(PopularViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tablePopular.addSubview(refreshControl)
        
        popularMovies()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopularViewController.orderTable(_:)), name: "reload", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopularViewController.orderTableByRating(_:)), name: "reload2", object: nil)
    }
    
    
    func refresh(sender:AnyObject) {
        isRefreshing = true
        popularMovies()
    }
    
    
 
    @IBAction func toggleMenu(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
        
    }

    //MARK: -ORDER FUNCTIONS
    func orderTable(notification: NSNotification) {
        movies.sortInPlace({
            $0.title < $1.title
        })
        tablePopular.reloadData()
    }
    
    func orderTableByRating(notification: NSNotification) {
        movies.sortInPlace({
            $0.rating > $1.rating
        })
        tablePopular.reloadData()
    }
    
    
    //MARK: SEARCH FUNCTIONS
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    
    //ME LAS SACA AL DAR DOS INTROS, CADA VEZ QUE SE HACE UNA BUSQUEDA NUEVA HABRIA QUE LIMPIAR EL ARRAY filtered
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        doSearch(searchBar)
        
    }
    
    
    func doSearch(searchBar: UISearchBar){
        let text = search.text!
        let urlString = "https://api-v2launch.trakt.tv/search?limit=30&query=\(text)&type=movie"
        let urlString2 = urlString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        
        //Inicializar loading
        
        Alamofire.request(.GET, urlString2, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .Success(let data):
                
                let swiftyJSON = JSON(data)
                
                self.movies.removeAll()
                self.parseMovieJsonBuscada(swiftyJSON)
                
                
            case .Failure(let error):
                //parar loading
                
                print("Request failed with error: \(error)")
            }
            
        }
        
        
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: -PARSE FUNCTIONS
    //para el getPeliculas!
    func parseMovieJson(json:SwiftyJSON.JSON){
        if let moviesArray = json.array {
            for movie in moviesArray {
                let movieClass = Pelicula()
                
                if let title = movie["title"].string{
                    movieClass.title = title
                }
                if let year = movie["year"].int{
                    let xyear = year as NSNumber
                    let year2: String = xyear.stringValue
                    movieClass.year = year2
                }
                if let ids = movie["ids"].dictionary {
                    if let slug = ids["slug"]!.string{
                        movieClass.id = slug
                    }
                }
                if let overview = movie["overview"].string{
                    movieClass.overview = overview
    
                }
                if let runtime = movie["runtime"].int{
                    let xruntime = runtime as NSNumber
                    let runtime2: String = xruntime.stringValue
                    movieClass.duration = runtime2
                }
                if let trailer = movie["trailer"].string {
                    movieClass.trailer = trailer
                }
                if let rating = movie["rating"].double{
                    let temp = String.localizedStringWithFormat("%.2f", rating)
                    movieClass.rating = temp
                }
                if let genres = movie["genres"].array{
                    let temp:String = String(genres)
                    let temp2:String = temp.stringByReplacingOccurrencesOfString("[", withString: "")
                    let temp3 = temp2.stringByReplacingOccurrencesOfString("\"", withString: "")
                    let temp4 = temp3.stringByReplacingOccurrencesOfString("]", withString: "")
                    movieClass.genres = temp4
                }
                if let imagesDictionary = movie["images"].dictionary {
                    if let fanartDictionary = imagesDictionary["fanart"]!.dictionary {
                        if let fanArtUrl = fanartDictionary["thumb"]!.string {
                            movieClass.fanart = fanArtUrl
                        }
                    }
                }
                
                if let imagesDictionary = movie["images"].dictionary {
                    if let posterDictionary = imagesDictionary["poster"]!.dictionary {
                        if let posterUrl = posterDictionary["thumb"]!.string {
                            movieClass.poster = posterUrl
                        }
                    }
                }
                
                self.movies.append(movieClass)
            }
        }
        self.tablePopular.reloadData()
        if isRefreshing {
            refreshControl?.endRefreshing()
        }
    }
    
    
    
    //PARSE PELICULA BUSCADA
    //Para las peliculas que se estan buscando
    func parseMovieJsonBuscada(json:SwiftyJSON.JSON){
       
        var slug:String = ""
        if let moviesArray = json.array {
            for movie in moviesArray {
                
                var movieBuscada = Pelicula()
                
                
                let principal = movie["movie"]
                
                
                if let imagesDictionary = principal["images"].dictionary {
                    if let posterDictionary = imagesDictionary["poster"]!.dictionary {
                        if posterDictionary["thumb"]!.string != nil {
                            //COMPROBAR LO DEL NIL
                            getPoster = true
                            
                        }else{
                            getPoster = false
                        }
                        
                    }
                }
                
                if getPoster == true {

                    if let ids = principal["ids"].dictionary {
                        slug = ids["slug"]!.string!
                        let urlString = "https://api-v2launch.trakt.tv/movies/\(slug)?extended=full,images"
                        
                        //https://www.raywenderlich.com/121540/alamofire-tutorial-getting-started
                        //SE PONE A HACER LA ASYNC Y SIGUE CON LO SIGUIENTE POR TANTO SE SALE O IGUAL SOLO HAY QUE ESPERAR MUCHO O
                        
                        Alamofire.request(.GET, urlString, headers: headers).validate().responseJSON { response in
                            switch response.result {
                            case .Success(let data):
                                
                                
                                let swiftyJSON = JSON(data)
                            
                                movieBuscada = self.parseMovieJsonPeliX(swiftyJSON)
                                
                            case .Failure(let error):
                                //parar loading
                                
                                print("Request failed with error: \(error)")
                            }
                            self.movies.append(movieBuscada)
                            self.getPoster = false
                            
                            if(self.movies.count == 0){
                                self.searchActive = false;
                                self.tablePopular.reloadData()
                                //parar loading
                                
                            } else {
                                self.searchActive = true;
                                self.tablePopular.reloadData()
                                //parar loading
                                
                            }

                        }
                    }
                    
                }else{
                    print("Pelicula no añadida el poster es null")
                }
                
            }
        }
       
    }
    
    //Parsear pelicula X
    func parseMovieJsonPeliX(json:SwiftyJSON.JSON)->Pelicula{
        let movie = json
                let movieClass = Pelicula()
                if let title = movie["title"].string{
                    movieClass.title = title
                    
                }else{
                    movieClass.title = "nil"
                }
                if let ids = movie["ids"].dictionary {
                    if let slug = ids["slug"]!.string{
                        movieClass.id = slug
                    }else{
                        movieClass.id = "nil"
                    }
                }else{
                    movieClass.id = "nil"
                }
        
                if let year = movie["year"].int{
                    let xyear = year as NSNumber
                    let year2: String = xyear.stringValue
                    movieClass.year = year2
                }else{
                    movieClass.year = "nil"
                }

                if let overview = movie["overview"].string{
                    let overview2 = overview.stringByReplacingOccurrencesOfString("\"", withString: "'")
                    movieClass.overview = overview2
                }else{
                    movieClass.overview = "nil"
                }
        
                if let runtime = movie["runtime"].int{
                    let xruntime = runtime as NSNumber
                    let runtime2: String = xruntime.stringValue
                    movieClass.duration = runtime2
                }else{
                    movieClass.duration = "nil"
                }
        
                if let trailer = movie["trailer"].string {
                    movieClass.trailer = trailer
                }else{
                    movieClass.trailer = "nil"
                }
        
                if let rating = movie["rating"].double{
                    let temp = String.localizedStringWithFormat("%.2f", rating)
                    movieClass.rating = temp
                }else{
                    movieClass.rating = "nil"
                }
                if let genres = movie["genres"].array{
                    let temp:String = String(genres)
                    let temp2:String = temp.stringByReplacingOccurrencesOfString("[", withString: "")
                    let temp3 = temp2.stringByReplacingOccurrencesOfString("\"", withString: "")
                    let temp4 = temp3.stringByReplacingOccurrencesOfString("]", withString: "")
                    movieClass.genres = temp4
                }else{
                    movieClass.genres = "nil"
                }
                if let imagesDictionary = movie["images"].dictionary {
                    if let fanartDictionary = imagesDictionary["fanart"]!.dictionary {
                        if let fanArtUrl = fanartDictionary["thumb"]!.string {
                            movieClass.fanart = fanArtUrl
                        }else{
                            movieClass.fanart = "nil"
                        }
                    }else{
                        movieClass.fanart = "nil"
                    }
                }else{
                    movieClass.fanart = "nil"
                }
        
                if let imagesDictionary = movie["images"].dictionary {
                    if let posterDictionary = imagesDictionary["poster"]!.dictionary {
                        if let posterUrl = posterDictionary["thumb"]!.string {
                            movieClass.poster = posterUrl
                        }else{
                            movieClass.poster = "nil"
                        }
                    }else{
                        movieClass.poster = "nil"
                    }
                }else{
                    movieClass.poster = "nil"
        }
        return movieClass
    }

    //MARK: -FUNCTIONS OF API
    func popularMovies(){
        let urlString = "https://api-v2launch.trakt.tv/movies/popular?limit=50&extended=full,images"
        Alamofire.request(Method.GET, urlString, headers: headers).responseJSON{ response in
            
            if (response.result.value != nil) {
                self.movies.removeAll()
                let swiftyJSON = JSON(response.result.value!)
                self.parseMovieJson(swiftyJSON)
            }else{
                print("error")
            }
        }
        
    }

    func getPelicula(id: String, opcion: String) {
        var peliculaX:Pelicula = Pelicula()
        let urlString : String = "https://api-v2launch.trakt.tv/movies/\(id)?extended=full,images"
        Alamofire.request(Method.GET, urlString, headers: headers).responseJSON{ response in
            
            if (response.result.value != nil) {
                self.movies.removeAll()
                let swiftyJSON = JSON(response.result.value!)
                peliculaX = self.parseMovieJsonPeliX(swiftyJSON)
                if opcion == "pending"{
                    self.insertarPeliculaPendiente(peliculaX)
                }else{
                    self.insertarPeliculaVista(peliculaX)
                }
            }else{
                print("error")
            }
        }
    }
    
    
    func insertarPeliculaPendiente(peliculaX:Pelicula){
   
        let user = NSUserDefaults.standardUserDefaults().stringForKey("userMovies")
        
        // create some JSON data and configure the request
        let json1 = "{\"runtime\": \"\(peliculaX.duration!)\", \"genre\": \"\(peliculaX.genres!)\", \"rating\": \"\(peliculaX.rating!)\", \"title\":\"\(peliculaX.title!)\", \"fanart\": \"\(peliculaX.fanart!)\", \"id\": \"\(peliculaX.id!)\", \"trailer\":\"\(peliculaX.trailer!)\", \"poster\": \"\(peliculaX.poster!)\", \"overview\":\"\(peliculaX.overview!)\", \"user\":\"\(user!)\", \"year\":\"\(peliculaX.year!)\"}"
        
        
        
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
                        
                        let alertController = UIAlertController(title: "Movie: \(peliculaX.title!)", message: "The movie was add to pending movies", preferredStyle: .Alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    })
                    
                }else if(resultValue==3){
                    dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "Movie: \(peliculaX.title!)", message: "The movie is already in pending list", preferredStyle: .Alert)
                    
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
    
    
    
    func insertarPeliculaVista(peliculaX:Pelicula){
        
        let user = NSUserDefaults.standardUserDefaults().stringForKey("userMovies")
        
        // create some JSON data and configure the request
        let json1 = "{\"runtime\": \"\(peliculaX.duration!)\", \"genre\": \"\(peliculaX.genres!)\", \"rating\": \"\(peliculaX.rating!)\", \"title\":\"\(peliculaX.title!)\", \"fanart\": \"\(peliculaX.fanart!)\", \"id\": \"\(peliculaX.id!)\", \"trailer\":\"\(peliculaX.trailer!)\", \"poster\": \"\(peliculaX.poster!)\", \"overview\":\"\(peliculaX.overview!)\", \"user\":\"\(user!)\", \"year\":\"\(peliculaX.year!)\"}"
      
        
        
        //Preparamos la url
        
        let request = NSMutableURLRequest(URL: urlInsertarVista)
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

}
    //MARK: -FUNCIONES TABLE

    extension PopularViewController : UITableViewDataSource{
        
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return movies.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:PopularTableViewCell = tableView.dequeueReusableCellWithIdentifier("CellPeliculas", forIndexPath: indexPath) as! PopularTableViewCell
        
       
        //cell.delegate = self
        
        let peli:Pelicula
        
        
        peli = movies[indexPath.row];
        
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
        
        
        cell.id = peli.id!
        return cell
    }
    }





    extension PopularViewController : UITableViewDelegate{
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // cell selected code here
        let myDetail : DetailPopularVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailPopular") as! DetailPopularVC
        
        myDetail.data = movies[indexPath.row]
        
        navigationController?.pushViewController(myDetail, animated: true)
        }
    }



    