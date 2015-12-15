//
//  ImgurImage.swift
//  ImgurGallerySwift
//
//  Copyright © 2015 3Pillar Global. All rights reserved.
//

import Foundation
import UIKit

class ImgurImage: NSObject {
    private static let imgurImageBaseURL = "https://i.imgur.com"
    private static let imgurBaseURL = "https://imgur.com"
    
    enum ThumbnailType {
        case SmallSquare, BigSquare, SmallThumbnail, MediumThumbnail, LargeThumbnail, HugeThumbnail
    }
    
    let internalDictionary: [String: AnyObject]
    
    init(withDictionary: [String: AnyObject]) {
        self.internalDictionary = withDictionary
    }
    
    func notSafeForWork() -> Bool {
        if let isNotSafeForWork:Bool = self.internalDictionary["nsfw"] as? Bool {
            return isNotSafeForWork
        } else {
            return true
        }
    }
    
    func ID() -> String? {
        return self.internalDictionary["id"] as! String?
    }
    
    func title() -> String? {
        return self.internalDictionary["title"] as! String?
    }
    
    // MARK: - URLs
    
    func imgurImageURL() -> NSURL? {
        let link: String? = self.internalDictionary["link"] as! String?
        return NSURL(string: link!)
    }
    
    func imgurURL() -> NSURL? {
        if let imageID = self.ID() {
            return NSURL(string: "\(ImgurImage.imgurBaseURL)/\(imageID)")
        }
        return nil
    }
    
    func thumbnailImageURL() -> NSURL? {
        var thumbnailType: ThumbnailType
        if (UIScreen.mainScreen().scale < 3) {
            thumbnailType = .MediumThumbnail
        } else {
            thumbnailType = .SmallThumbnail
        }
        return self.thumbnailImageURL(forType: thumbnailType)
    }
    
    func thumbnailImageURL(forType type: ThumbnailType) -> NSURL? {
        
        return NSURL(string: "\(ImgurImage.imgurImageBaseURL)/\(self.ID()!)\(self.thumbnailSuffix(forType: type)).jpg")
    }
    
    // MARK: - URL Handling
    
    private func thumbnailSuffix(forType type: ThumbnailType) -> String {
        switch type {
        case .SmallSquare:
            return "s"
        case .BigSquare:
            return "b"
        case .SmallThumbnail:
            return "t"
        case .MediumThumbnail:
            return "m"
        case .LargeThumbnail:
            return "l"
        case .HugeThumbnail:
            return "h"
        }
    }
}
