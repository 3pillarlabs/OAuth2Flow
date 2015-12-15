//
//  ImagesViewController.swift
//  OAuth2FlowDemo
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

import UIKit
import OAuth2Flow

class ImagesViewController: UITableViewController, OAFViewControllerDelegate {
    
    private var authHandler: OAFAuthHandler? {
        didSet {
            if self.authHandler != nil {
                self.navigationItem.rightBarButtonItem = nil;
            }
        }
    }
    private var authConf: OAFAuthConfiguration?
    private var images: Array<ImgurImage> = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let
            detailVC = segue.destinationViewController as? ImageDetailViewController,
            cell = sender as? UITableViewCell,
            index = self.tableView.indexPathForCell(cell)?.row else {
                return
        }
        detailVC.image = self.images[index]
    }
    
    // MARK: - Button Actions
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        self.authConf = OAFAuthConfiguration()
        self.authConf?.baseURL = "https://api.imgur.com"
        self.authConf?.authorizeURL = "https://api.imgur.com/oauth2/authorize"
        self.authConf?.requestTokenURL = "https://api.imgur.com/oauth2/token"
        self.authConf?.consumerKey = "YOUR_CONSUMER_KEY" // replace with your own
        self.authConf?.consumerSecret = "YOUR_CONSUMER_SECRET" // replace with your own
        self.authConf?.callbackURL = "CALLBACK_USED_AT_APPLICATION_REGISTRATION" // replace with your own
        
        if let authVC: OAFViewController = OAFViewController(configuration: self.authConf!) {
            authVC.delegate = self
            authVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelLogin")
            let navigationController = UINavigationController(rootViewController: authVC)
            navigationController.navigationBar.barStyle = .Black
            navigationController.navigationBar.barTintColor = UIColor.lightGrayColor()
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
            
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    func cancelLogin() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:DashboardCell = tableView.dequeueReusableCellWithIdentifier("TableViewReuseIdentifier") as! DashboardCell
        let image = self.images[indexPath.row]
        cell.imageTitle.text = image.title()
        return cell
    }
    
    // MARK: - OAFViewControllerDelegate
    
    func viewController(viewController: OAFViewController, didFinishAuthFlow authHandler: OAFAuthHandler) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.authHandler = authHandler
        self.requestViralImages()
    }
    
    func requestViralImages() {
        let request = self.authHandler?.requestWithRelativeURL("3/gallery/hot/viral/0.json")
        request?.configureRequestWithBlock({ (mutableRequest: NSMutableURLRequest) -> Void in
            if let clientID: String = self.authConf?.consumerKey {
                mutableRequest.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
            }
        })
        request?.startWithJSONBlockReponse({ (json: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                return
            }
            if let dictionary:NSDictionary = json as? NSDictionary {
                if let objects: Array<[String: AnyObject]> = dictionary["data"] as? Array<[String: AnyObject]> {
                    var images: Array<ImgurImage> = []
                    for dictionary in objects {
                        let image = ImgurImage(withDictionary: dictionary)
                        images.append(image)
                    }
                    let filteredImages = images.filter({ (image:ImgurImage) -> Bool in
                        return !image.notSafeForWork()
                    })
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.images = filteredImages
                    })
                }
            }
        })
    }

}
