//
//  Parse.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 30.01.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond
import ConvenienceKit

// 1
class Post : PFObject, PFSubclassing {
    
    var image: Observable<UIImage?> = Observable(nil)
    var drawingImage: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    var drawingUploadTask: UIBackgroundTaskIdentifier?
    var likes: Observable<[PFUser]?> = Observable(nil)
    static var imageCache: NSCacheSwift<String, UIImage>!
    
    // 2
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    @NSManaged var drawingFile: PFFile?
    
    func uploadPost() {
        //TODO: table for drawings
        self.ACL?.publicWriteAccess = true

        if let image = image.value {
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { [unowned self]
                () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let imageFile = PFFile(data: imageData!)
            imageFile!.saveInBackgroundWithBlock(nil)
            
            user = PFUser.currentUser()
            self.imageFile = imageFile
            self.likes.value = []
            saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
    func uploadDrawing() {
        
        if let drawingImage = drawingImage.value {
            drawingUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({[unowned self] () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.drawingUploadTask!)
            })
            
            let drawingData = UIImagePNGRepresentation(drawingImage)
            let drawingFile = PFFile(data: drawingData!)
            drawingFile!.saveInBackgroundWithBlock(nil)
            
            self.drawingFile = drawingFile
            saveInBackgroundWithBlock({ (success, error) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.drawingUploadTask!)
            })
        } else {
            self.drawingFile = nil
            saveInBackground()
        }
        
    }
    
    private func downloadImage(imageFile:PFFile, inout imageObs: Observable<UIImage?>) {
        imageObs.value = Post.imageCache[imageFile.name]
        
        if imageObs.value == nil {
            imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                
                if let data = data {
                    let image = UIImage(data: data)
                    imageObs.value = image
                    Post.imageCache[imageFile.name] = image
                }
            })
        }
    }
    
    func downloadImage() {
        if let imageFile = imageFile where image.value == nil {
            downloadImage(imageFile, imageObs: &image)
        }
        if let drawingFile = drawingFile where drawingImage.value == nil {
            downloadImage(drawingFile, imageObs: &drawingImage)
        }
    }
    
    func fetchLikes() {
        // 1
        if (likes.value != nil) {
            return
        }
        
        // 2
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [PFObject]?, error: NSError?) -> Void in
            // 3
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // 4
            self.likes.value = likes?.map { like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if image is liked, unlike it now
            // 1
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this image is not liked yet, like it now
            // 2
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    //MARK: Flagging
    
    func flagPost(user: PFUser) {
        ParseHelper.flagPost(user, post: self)
    }
    
    //MARK: PFSubclassing Protocol
    
    // 3
    static func parseClassName() -> String {
        return "Post"
    }
    
    // 4
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
            // 1
            Post.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
    
}