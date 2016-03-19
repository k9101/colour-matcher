//
//  FlickrViewerViewController.swift
//  UIKitTest
//
//  Created by Kris Penney on 2015-10-13.
//  Copyright © 2015 Kris Penney. All rights reserved.
//

import UIKit
import CoreImage


class FlickrViewerViewController: UIViewController {

    @IBOutlet weak var flickrImage: UIImageView!
    @IBOutlet weak var flickrSearchBar: UISearchBar!
    
    var searchText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
        
        getImage(nil)
    }
    
    //Refresh button clicked, load new image
    func refresh(){
        
        let searchText: String? = (flickrSearchBar.text!.isEmpty) ? nil : flickrSearchBar.text!
        
        getImage(searchText)
    }
    
    
    func getImage(searchText: String?){
        let service = FlickrService()
        
        // Create Loading box
        let strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = "Fetching Photo"
        strLabel.textColor = UIColor.whiteColor()
        let messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        messageFrame.addSubview(activityIndicator)
        
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
        
        // build API params
        var params: [String:AnyObject]
        
        if let searchText = searchText {
            params = [FlickrService.Keys.TEXT : searchText,
                      FlickrService.Keys.SORT : FlickrService.Constants.SORT_RELEVANCE,
                FlickrService.Keys.METHOD : FlickrService.Constants.METHOD_NAME_SEARCH
            ]
        }else{
            params = [FlickrService.Keys.GALLERY_ID : FlickrService.Constants.GALLERY_ID,
                FlickrService.Keys.METHOD : FlickrService.Constants.METHOD_NAME_GET]
        }
        
        service.searchForImageFromFlickr(params) {  data, title -> Void in
            
            if let data = data{ // found image, insert into ui
                dispatch_async(dispatch_get_main_queue()){
                    let image = UIImage(data: data)
                    self.flickrImage.image = image
                    
                    self.navigationItem.title = (title == nil) ? "" : title
                    
                    self.view.backgroundColor = image?.averageColor()
                    
                    messageFrame.removeFromSuperview()
                }
            }else{ // no image, show error
                dispatch_async(dispatch_get_main_queue()){
                    
                    messageFrame.removeFromSuperview()
                    
                    let alert = UIAlertController(title: "No Results Returned", message: "There where no results returned for your query: \(searchText)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }       
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

extension FlickrViewerViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            getImage(searchText)
        }
        
        searchBar.resignFirstResponder()
    }
}
