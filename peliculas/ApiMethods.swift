//
//  ApiMethods.swift
//  peliculas
//
//  Created by Laura on 18/5/16.
//  Copyright © 2016 Laura. All rights reserved.
//


import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import Haneke


class ApiMethods{
    
    //MARK: -METODOS DE LA API
    //Coger todas las peliculas populares
    
    
    func getPopular2(){
        let urlString = "https://api-v2launch.trakt.tv/movies/popular?limit=50&extended=full,images"
    
        let headers = ["trakt-api-version":"2","trakt-api-key":"2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf"]
        
        //Alamofire.request(Method.GET, urlString,headers: headers).responseJSON {
            //(_,_,result) -> Void in
        Alamofire.request(Method.GET, urlString, parameters: ["pelis": "peli"], headers: headers).responseJSON{ response in
            
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON2 = response.result.value {
                let swiftyJSON = JSON(response.result.value!)
                print("JSON: \(JSON2)")
                
                print("swifty: \(swiftyJSON)")
                
            }else{
                print("error")
            }
            
        
        }
    }
    
    func parseMovieJson(json:SwiftyJSON.JSON){
        var movies = [Pelicula]()
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
                            //let xrating = rating as NSNumber
                            //let rating2: String = xrating.stringValue
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

                
                
                movies.append(movieClass)
            }
        }

        PopularViewController().tablePopular.reloadData()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func getPopular(completionHandler: (pelis:[Pelicula])->()){
        var lista:[Pelicula]=[];
        var json: Array<AnyObject>!;
        
        let requestUrl: NSURL = NSURL(string: "https://api-v2launch.trakt.tv/movies/popular?limit=50&extended=full,images")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("2", forHTTPHeaderField: "trakt-api-version")
        urlRequest.addValue("2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf", forHTTPHeaderField: "trakt-api-key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
            
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode==200){
                
                do{
                    
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! Array<AnyObject>
                    lista = self.parsear(json);
                    completionHandler(pelis: lista)
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
                
                
            }else{
                print("Error with the connection")
                return;
            }
        }
        
        task.resume()
        
    }
    
    //Coge una pelicula X
    func getPelicula(id:String, completionHandler: (pelis:[Pelicula])->()){
        var lista:[Pelicula]=[];
        var json: Array<AnyObject>!;
        
        let requestUrl: NSURL = NSURL(string: "https://api-v2launch.trakt.tv/movies/"+"\(id)"+"?extended=full,images")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("2", forHTTPHeaderField: "trakt-api-version")
        urlRequest.addValue("2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf", forHTTPHeaderField: "trakt-api-key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
            
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode==200){
                
                do{
                    
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! Array<AnyObject>
                    lista = self.parsear(json);
                    completionHandler(pelis: lista)
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
                
                
            }else{
                print("Error with the connection")
                return;
            }
        }
        
        task.resume()
        
    }
    
    
    //Traduce una pelicula X
    func getPeliculaTranslate(id:String, language:String, completionHandler: (pelis:[Pelicula])->()){
        var lista:[Pelicula]=[];
        var json: Array<AnyObject>!;
        
        let requestUrl: NSURL = NSURL(string: "https://api-v2launch.trakt.tv/movies/"+"\(id)"+"/translations/"+"\(language)")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("2", forHTTPHeaderField: "trakt-api-version")
        urlRequest.addValue("2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf", forHTTPHeaderField: "trakt-api-key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
            
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode==200){
                
                do{
                    
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! Array<AnyObject>
                    lista = self.parsear(json);
                    completionHandler(pelis: lista)
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
                
                
            }else{
                print("Error with the connection")
                return;
            }
        }
        
        task.resume()
        
    }
    
    //Buscar una pelicula X
    func buscarPelicula(query:String, completionHandler: (pelis:[Pelicula])->()){
        var lista:[Pelicula]=[];
        var json: Array<AnyObject>!;
        
        let requestUrl: NSURL = NSURL(string: "https://api-v2launch.trakt.tv/search?limit=30&query="+"\(query)"+"&type=movie")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("2", forHTTPHeaderField: "trakt-api-version")
        urlRequest.addValue("2a87c0a50ef88e8d79cb05973bc6c1fa9826b75f88e01cbc19ff38f8c56c4acf", forHTTPHeaderField: "trakt-api-key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
            
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode==200){
                
                do{
                    
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! Array<AnyObject>
                    lista = self.parsear(json);
                    completionHandler(pelis: lista)
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
                
                
            }else{
                print("Error with the connection")
                return;
            }
        }
        
        task.resume()
        
    }


    
    
    
    
    
    
    
    //MARK: -METODO PARSEAR
    func parsear(json: Array<AnyObject>)->[Pelicula]{
        var listaPeliculas:[Pelicula] = [];
        var movie:Pelicula?;
        
        for var i = 0; i < json.count; i++ {
            
            if let peliculas = json[i] as? [String: AnyObject] {
                
                movie = Pelicula()
                
                if let title = peliculas["title"] as? String{
                    movie?.title = title
                }
                if let year = peliculas["year"] as? String{
                    movie?.year = year
                }
                if let ids = peliculas["ids"] as? [String: AnyObject]{
                    if let slug = ids["slug"] as? String{
                        movie?.id = slug
                    }
                }
                if let overview = peliculas["overview"] as? String{
                    movie?.overview = overview
                }
                if let runtime = peliculas["runtime"] as? String{
                    movie?.duration = runtime
                }
                if let trailer = peliculas["trailer"] as? String{
                    movie?.trailer = trailer
                    print(trailer)
                }
                
                if let score = peliculas["rating"] as? Double{
                    let temp = String.localizedStringWithFormat("%.2f", score)
                    movie?.rating = temp
                    
                }
                if let genres = peliculas["genres"] as? Array<String>{
                    let temp:String = String(genres)
                    let temp2:String = temp.stringByReplacingOccurrencesOfString("[", withString: "")
                    let temp3 = temp2.stringByReplacingOccurrencesOfString("\"", withString: "")
                    let temp4 = temp3.stringByReplacingOccurrencesOfString("]", withString: "")
                    movie?.genres = temp4
                }
                if let images = peliculas["images"] as? [String: AnyObject]{
                    if let poster = images["poster"] as? [String: AnyObject]{
                        if let thumb = poster["thumb"] as? String{
                            movie?.poster = thumb
                        }
                    }
                    if let fanart = images["fanart"] as? [String:AnyObject]{
                        if let thumbFanart = fanart["thumb"] as? String{
                            movie?.fanart = thumbFanart
                        }
                    }
                }
                

                listaPeliculas.append(movie!)
            }
            
            
        }
        return listaPeliculas;
        
    }
    
}