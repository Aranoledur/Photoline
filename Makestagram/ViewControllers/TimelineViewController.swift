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
        var alertController: UIAlertController!
        if (post.user == PFUser.currentUser()) {
            alertController = showDeleteActionSheetForPost(post)
        } else {
            alertController = showFlagActionSheetForPost(post)
        }
        
        let editAction = UIAlertAction(title: NSLocalizedString("Edit", comment: "Edit photo in timeline"), style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier("DrawingSegue", sender: cell)
        }
        alertController.addAction(editAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showDeleteActionSheetForPost(post: Post) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: "Do you want to delete this post?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
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
        alertController.addAction(destroyAction)
        
        return alertController
    }
    
    func showFlagActionSheetForPost(post: Post) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: "Do you want to flag this post?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Flag", style: .Destructive) { (action) in
            post.flagPost(PFUser.currentUser()!)
        }
        
        alertController.addAction(destroyAction)
        
        return alertController
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DrawingSegue" {
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