//
//  ImageDetailViewController.swift
//  ImgurGallerySwift
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var image: ImgurImage? {
        didSet {
            if self.isViewLoaded() {
                self.updateWebURL(self.image?.imgurURL())
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = self.image {
            self.updateWebURL(image.imgurURL())
        }
    }
    
    func updateWebURL(URL: NSURL?) {
        if let validURL = URL {
            self.webView.loadRequest(NSURLRequest(URL: validURL))
        }
    }
}
