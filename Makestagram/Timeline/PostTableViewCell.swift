//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Pankaj Khillon on 7/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {

    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    var post:Post? {
        didSet {
            if let post = post {
                // bind the image of the post to the 'postImage' view
                post.image ->> postImageView
                
                // bind the likeBond that we defined earlier, to update like label and button when likes change
                post.likes ->> likeBond
            }
        }
    }
    
    var likeBond: Bond<[PFUser]?>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Generates a comma separated list of usernames from an array (e.g. "User1, User2")
    func stringFromUserList(userList: [PFUser]) -> String {
        // 1
        let usernameList = userList.map { user in user.username! }
        // 2
        let commaSeparatedUserList = ", ".join(usernameList)
        
        return commaSeparatedUserList
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 1
        likeBond = Bond<[PFUser]?>() { [unowned self] likeList in
            // 2
            if let likeList = likeList {
                // 3
                self.likesLabel.text = self.stringFromUserList(likeList)
                // 4
                self.likesButton.selected = contains(likeList, PFUser.currentUser()!)
                // 5
                self.likesIconImageView.hidden = (likeList.count == 0)
            } else {
                // 6
                // if there is no list of users that like this post, reset everything
                self.likesLabel.text = ""
                self.likesButton.selected = false
                self.likesIconImageView.hidden = true
            }
        }
    }

}

extension PFObject : Equatable {
    
}

public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}