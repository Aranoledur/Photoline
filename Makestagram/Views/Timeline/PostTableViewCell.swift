//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 30.01.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

typealias MoreButtonCallback = (Post, PostTableViewCell) -> Void

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var drawingImageView: UIImageView!    
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    var postDisposable: DisposableType?
    var drawingDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    var moreButtonCallback: MoreButtonCallback?
    
    
    var post:Post? {
        didSet {
            
            postDisposable?.dispose()
            drawingDisposable?.dispose()
            likeDisposable?.dispose()
            // free memory of image stored with post that is no longer displayed
            // 1
            if let oldValue = oldValue where oldValue != post {
                oldValue.image.value = nil
                oldValue.drawingImage.value = nil
            }
            
            if let post = post {
                if let _ = post.image.value { //if already has an image then update
                    postImageView.image = post.image.value
                }
                
                drawingImageView.image = post.drawingImage.value                
                drawingImageView.hidden = post.drawingFile == nil
                
                postDisposable = post.image.bindTo(postImageView.bnd_image)
                drawingDisposable = post.drawingImage.observeNew({ (newImage) -> () in
                    self.drawingImageView.image = newImage
                    self.drawingImageView.hidden = post.drawingFile == nil
                })
                
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    if let value = value {
                        self.likesLabel.text = self.stringFromUserList(value)
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        self.likesIconImageView.hidden = (value.count == 0)
                    } else {
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                }
            }
        }
    }
    
    // Generates a comma separated list of usernames from an array (e.g. "User1, User2")
    func stringFromUserList(userList: [PFUser]) -> String {
        // 1
        let usernameList = userList.map { user in user.username! }
        // 2
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        
        return commaSeparatedUserList
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButtonTapped(sender: UIButton) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    @IBAction func moreButtonTapped(sender: UIButton) {
        self.moreButtonCallback?(post!, self)

    }
}
