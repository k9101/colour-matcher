//
//  FlickrService.swift
//  UIKitTest
//
//  Created by Kris Penney on 2015-10-13.
//  Copyright © 2015 Kris Penney. All rights reserved.
//

import Foundation


class FlickrService: NSObject{
    
    struct Keys {
        static let METHOD = "method"
        static let API_KEY = "api_key"
        static let GALLERY_ID = "gallery_id"
        static let EXTRAS = "extras"
        static let FORMAT = "format"
        static let JSONCB = "nojsoncallback"
        static let SORT = "sort"
        static let TEXT = "text"
    }
    
    struct Constants {
        
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME_GET = "flickr.galleries.getPhotos"
        static let METHOD_NAME_SEARCH = "flickr.photos.search"
        static let GALLERY_ID = "5704-72157622566655097"
        static let EXTRAS = "url_m"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let SORT_RELEVANCE = "relevance"
    }
    
    
    func searchForImageFromFlickr(params: [String: AnyObject], completionHandler: (NSData?, String?) -> Void){
        var methodArguments: [String : AnyObject] = [
            Keys.API_KEY: APIKey.API_KEY,
            Keys.EXTRAS: Constants.EXTRAS,
            Keys.FORMAT: Constants.DATA_FORMAT,
            Keys.JSONCB: Constants.NO_JSON_CALLBACK,
        ]
        
        methodArguments += params
       
        //Build URL
        let session = NSURLSession.sharedSession()
        let urlString = Constants.BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) { data, response, error -> Void in
            if let error = error {
                print("Could not complete the request.  Error: \(error)")
            }else{
                do{
                    //Parse Returned JSON
                    let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    if let photosDictionary = parsedResult.valueForKey("photos") as? [String : AnyObject] {
                        if let numPerPage = photosDictionary["perpage"] as? Int {
                            if let photoArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                                let pageCount = (numPerPage > photoArray.count) ? photoArray.count : numPerPage
                                //Get a random photo from the set
                                let random = Int(arc4random_uniform(UInt32(pageCount)))
                                let photo = photoArray[random]

                                // Get image data and return to callback
                                if let photo_url = photo["url_m"] as? String, imageURL = NSURL(string: photo_url), photo_title = photo["title"] as? String{
                                    
                                    if let imageData = NSData(contentsOfURL: imageURL) {
                                        completionHandler(imageData, photo_title)
                                    }else{
                                        print("Image does not exist at \(imageURL)")
                                        completionHandler(nil, nil)
                                        
                                    }
                                }else{
                                    completionHandler(nil, nil)
                                }

                                
                            }
                        }
                        
                    }else{
                        print("Cant find key 'photos' in \(parsedResult)")
                    }
                    
                    
                }catch let error{
                    print(error)
                }
            }
            
        }
        
        task.resume()
    }
    
    //Encode parameters for url
    private func escapedParameters(params: [String : AnyObject]) -> String{
        var urlVars = [String]()
        
        for (key, value) in params {
            let stringVal = "\(value)"
            let escapedValue = stringVal.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            urlVars.append(key + "=" + "\(escapedValue!)")
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}