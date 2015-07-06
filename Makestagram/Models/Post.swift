//
//  Post.swift
//  Makestagram
//
//  Created by Pankaj Khillon on 7/1/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Foundation
import Parse
import Bond

class Post: PFObject, PFSubclassing {
    
    @NSManaged var imageFile : PFFile?
    @NSManaged var user : PFUser?
    
    var image: Dynamic<UIImage?> = Dynamic(nil)
    var likes =  Dynamic<[PFUser]?>(nil)
    
    var photoUploadTask : UIBackgroundTaskIdentifier?
    
    func uploadPost() {
        let imageData = UIImageJPEGRepresentation(image.value, 0.8)
        let imageFile = PFFile(data: imageData)
        
        // 1
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        // 2
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            // 3
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        // any uploaded post should be associated with the current user
        user = PFUser.currentUser()
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil)
    }
    
    func downloadImage() {
        if (image.value == nil) { // if image has not yet been downloaded
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in //background thread
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    // 3
                    self.image.value = image //update image.value with downloaded image
                }
            }
        }
    }

    func fetchLikes() {
        // if no likes have been loaded
        if (likes.value != nil) {
            return // if a value has been stored, skip this, since if you don't have any likes,
                    // you'll want to load them first anyway.
        }
        
        // 2
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            // this line filters out the array so you only have elements that match your search
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            //
            self.likes.value = likes?.map { like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    } // end function
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return contains(likes, user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    // MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Post"
    }
    
    // MARK: Pure Boilerplate code
    
    //copy these two init and initialize functions into any custom Parse class you create
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}