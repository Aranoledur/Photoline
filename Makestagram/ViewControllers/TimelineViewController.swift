//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 30.01.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController, TimelineComponentTarget {

    @IBOutlet weak var tableView: UITableView!
    var photoTakingHelper: PhotoTakingHelper?
    let defaultRange = 0...4
    let additionalRangeSize = 5
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
         timelineComponent.loadInitialIfRequired()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper =
            PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
                let post = Post()
                // 1
                post.image.value = image!
                post.uploadPost()
        }
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        // 1
        ParseHelper.timelineRequestForCurrentUser(range) {
            (result: [AnyObject]?, error: NSError?) -> Void in
            // 2
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
        }
    }
    
    // MARK: UIActionSheets
    
    func showActionSheetForPost(post: Post, cell: PostTableViewCell) {
        let message = NSLocalizedString("What you want to do with this post?", comment: "Message of alert controller in timeline")
        let editTitle = NSLocalizedString("Edit", comment: "Edit photo in timeline")
        if #available(iOS 8.0, *) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
            
            let editAction = UIAlertAction(title: editTitle, style: .Default) { (action) -> Void in
                self.performSegueWithIdentifier("DrawingSegue", sender: cell)
            }
            alertController.addAction(editAction)
            
            if (post.user == PFUser.currentUser()) {
                alertController.addAction(deleteActionSheetForPost(post))
            } else {
                alertController.addAction(flagActionSheetForPost(post))
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            
            let alertController = PSTAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
            let editAction = PSTAlertAction(title: editTitle, style: .Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("DrawingSegue", sender: cell)
            })
            alertController.addAction(editAction)
            
            if post.user == PFUser.currentUser() {
                let destroyAction = PSTAlertAction(title: NSLocalizedString("Delete", comment: "Delete title"), style: .Destructive, handler: { (action) -> Void in
                    post.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            self.timelineComponent.removeObject(post)
                        } else {
                            // restore old state
                            
                            self.tableView.reloadData()
                        }
                    })
                })
                alertController.addAction(destroyAction)
            } else {
                let destroyAction = PSTAlertAction(title: NSLocalizedString("Flag", comment: "Flag title"), style: .Destructive, handler: { (action) -> Void in
                    post.flagPost(PFUser.currentUser()!)
                })
                alertController.addAction(destroyAction)
            }
            
            let cancelAction = PSTAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel title"), style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
        }
    }
    
    @available(iOS 8.0, *)
    func deleteActionSheetForPost(post: Post) -> UIAlertAction {
        
        let destroyAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            post.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if (success) {
                    self.timelineComponent.removeObject(post)
                } else {
                    // restore old state
                    
                    self.tableView.reloadData()
                }
            })
        }
        return destroyAction
    }
    
    @available(iOS 8.0, *)
    func flagActionSheetForPost(post: Post) -> UIAlertAction {
        
        let destroyAction = UIAlertAction(title: "Flag", style: .Destructive) { (action) in
            post.flagPost(PFUser.currentUser()!)
        }
        
        return destroyAction
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DrawingSegue" {
//            let navigationC = segue.destinationViewController as! UINavigationController
//            let destViewC = navigationC.topViewController as! DrawingViewController
            let destViewC = segue.destinationViewController as! DrawingViewController
            let pickedCell = sender as! PostTableViewCell
            destViewC.image = pickedCell.postImageView.image
        }
    }
    

}


// MARK: - Tab Bar Delegate
extension TimelineViewController : UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if(viewController is PhotoViewController) {
            takePhoto();
            return false;
        } else {
            return true;
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.section]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        cell.moreButtonCallback = showActionSheetForPost
        
        return cell
    }
    
}

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
        
        let post = self.timelineComponent.content[section]
        headerCell.post = post
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}