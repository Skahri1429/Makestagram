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
    
    // MARK: Navigation
    
    /**
    Fetches all users that the provided user is following.
    
    :param: user The user whose followees you want to retrieve
    :param: completionBlock The completion block that is called when the query completes
    */
    
    static func getFollowingUsersForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
    Establishes a follow relationship between two users.
    
    :param: user    The user that is following
    :param: toUser  The user that is being followed
    */
    
    static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFObject(className: ParseFollowClass)
        
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        
        followObject.saveInBackgroundWithBlock(nil)
    }
    
    
    /**
    Deletes a follow relationship between two users.
    
    :param: user    The user that is following
    :param: toUser  The user that is being followed
    */
    
    static func deleteFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFQuery(className: ParseFollowClass)
        followObject.whereKey(ParseFollowFromUser, equalTo: user)
        followObject.whereKey(ParseFollowToUser, equalTo: toUser)
        
        followObject.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]?, error: NSError?) -> Void in
            // delete likes
            if let results = results as? [PFObject] {
                for follow in results {
                    follow.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    
    // MARK: Users
    
    /**
    Fetch all users, except the one that's currently signed in.
    Limits the amount of users returned to 20.
    
    :param: completionBlock The completion block that is called when the query completes
    
    :returns: The generated PFQuery
    */
    
    static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = PFUser.query()! // forcibly unwrapping optional, guaranteeing that not nil value
        
        // excluding current user from search
        query.whereKey(ParseHelper.ParseUserUsername,
            notEqualTo: PFUser.currentUser()!.username!)
        
        //return in ascending order
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        return query
    }
    
    /**
    Fetch users whose usernames match the provided search term.
    
    :param: searchText The text that should be used to search for users
    :param: completionBlock The completion block that is called when the query completes
    
    :returns: The generated PFQuery
    */
    
    static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock) -> PFQuery {
        
        /*
        NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
        Regex can be slow on large datasets. For large amount of data it's better to store
        lowercased username in a separate column and perform a regular string compare.
        */
        let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername,
            matchesRegex: searchText, modifiers: "i") // see above for explanation
        
        query.whereKey(ParseHelper.ParseUserUsername,
            notEqualTo: PFUser.currentUser()!.username!)
        
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    
}
