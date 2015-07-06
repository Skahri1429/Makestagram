//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Pankaj Khillon on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
        
        // Following Relation
        static let ParseFollowClass       = "Follow"
        static let ParseFollowFromUser    = "fromUser"
        static let ParseFollowToUser      = "toUser"
        
        // Like Relation
        static let ParseLikeClass         = "Like"
        static let ParseLikeToPost        = "toPost"
        static let ParseLikeFromUser      = "fromUser"
        
        // Post Relation
        static let ParsePostUser          = "user"
        static let ParsePostCreatedAt     = "createdAt"
        
        // Flagged Content Relation
        static let ParseFlaggedContentClass    = "FlaggedContent"
        static let ParseFlaggedContentFromUser = "fromUser"
        static let ParseFlaggedContentToPost   = "toPost"
        
        // User Relation
        static let ParseUserUsername      = "username"
        
        // ...

    //
    static func timelineRequestforCurrentUser(range: Range<Int>, completionBlock: PFArrayResultBlock) {
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseLikeFromUser, equalTo:PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        // 2
        query.skip = range.startIndex
        // 3
        query.limit = range.endIndex - range.startIndex
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func likeRequestForCurrentUser(completionBlock: PFArrayResultBlock) {
        let likeQuery = PFQuery(className: ParseLikeClass)
    }
    
    // MARK: Like functionality
    
    static func likePost(user: PFUser, post: Post) {
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, post: Post) {
        // query for likes
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            // delete likes
            if let results = results as? [PFObject] {
                for likes in results {
                    likes.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
   /* static func likesForPost(user: PFUser, post: Post) -> Int { //nice try
        /*
        1) get all queries and set to an array <grr hard part
        2) let totalLikes = array.count
        3) return totalLikes
        */
        
        let likesArray: [Int] = []
        
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let results = results as? [PFObject] {
                for likes in results {
                    
                }
            }
        }
        
        let totalLikes = likesArray.count
        return totalLikes
    } */
    
    // 1
    static func likesForPost(post: Post, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        // 2
        query.includeKey(ParseLikeFromUser)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
}
