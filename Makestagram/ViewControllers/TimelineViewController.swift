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
import Crashlytics

class TimelineViewController: UIViewController, TimelineComponentTarget {

    @IBOutlet weak var tableView: UITableView!
    var photoTakingHelper: PhotoTakingHelper?
    let defaultRange = 0...4
    let additionalRangeSize = 5
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    var pickedCell: PostTableViewCell?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
        timelineComponent.loadInitialIfRequired()
        self.tableView.registerNib(UINib(nibName: "PostSectionHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PostSectionHeaderFooterView")

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        weak var weakSelf = self
        photoTakingHelper =
            PhotoTakingHelper(senderView: self.tabBarController!.tabBar, viewController: self.tabBarController!) { (image: UIImage?) in
                let post = Post()
                // 1
                post.image.value = image!
                post.uploadPost()
                weakSelf?.timelineComponent.insertObject(post)
                weakSelf?.tableView?.beginUpdates()
                weakSelf?.tableView?.insertSections(NSIndexSet(index: 0), withRowAnimation: .Top)
                weakSelf?.tableView?.endUpdates()
        }
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        if ParseHelper.isThisUserSuspended(PFUser.currentUser()!) {
            let label = UILabel()
            label.text = NSLocalizedString("Your account was suspended. Contact us for more details: easyverzilla@gmail.com.", comment: "Message when suspended account.")
            label.numberOfLines = 0
            label.textAlignment = .Center
            self.tableView.backgroundView = label
            return
        }
        // 1
        ParseHelper.timelineRequestForCurrentUser(range) {
            (result: [PFObject]?, error: NSError?) -> Void in
            // 2
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
            
            if posts.isEmpty && range.startIndex == 0 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let label = UILabel()
                    label.text = NSLocalizedString("Your timeline is empty right now. Try to find someone and follow them or upload your own photo!", comment: "Empty timeline message")
                    label.numberOfLines = 0
                    label.textAlignment = .Center
                    self.tableView.backgroundView = label
                })
            }
        }
    }
    
    // MARK: UIActionSheets
    
    func showFlagUserAlertView(user: PFUser) {
        let message = NSString(format: NSLocalizedString("Do you want to also flag this user (%@)?", comment: "Flagging user message"), user.username!)
        let alertController = PSTAlertController(title: nil, message: message as String, preferredStyle: .Alert)
        
        let flagUserAction = PSTAlertAction(title: ConstantStrings.yesString, style: .Destructive) {(action) -> Void in
            ParseHelper.removeFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
            ParseHelper.flagUserFromUser(PFUser.currentUser()!, toUser: user)
        }
        alertController.addAction(flagUserAction)
        
        let cancelAction = PSTAlertAction(title: ConstantStrings.noString, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        alertController.showWithSender(nil, controller: self, animated: true, completion: nil)
    }
    
    func showActionSheetForPost(post: Post, cell: PostTableViewCell) {
        let message = NSLocalizedString("What do you want to do with this post?", comment: "Message of alert controller in timeline")
        let editTitle = NSLocalizedString("Edit", comment: "Edit photo in timeline")
        
        let alertController = PSTAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        let editAction = PSTAlertAction(title: editTitle, style: .Default) { (action) -> Void in
            if cell.postImageView.image != nil {
                self.performSegueWithIdentifier("DrawingSegue", sender: cell)
            } else {
                ErrorHandling.defaultErrorHandler(NSLocalizedString("Sorry. There is no image for this post", comment: "No image in post error"))
            }
        }
        alertController.addAction(editAction)
        
        if post.user == PFUser.currentUser() {
            let destroyAction = PSTAlertAction(title: NSLocalizedString("Delete", comment: "Delete title"), style: .Destructive, handler: { (action) -> Void in
                post.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        self.timelineComponent.removeObject(post)
                        if let indexPath = self.tableView?.indexPathForCell(cell) {
                            
                            self.tableView?.beginUpdates()
                            self.tableView?.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Right)
                            self.tableView?.endUpdates()
                        }
                        
                    } else {
                        // restore old state
                        
                        self.tableView?.reloadData()
                    }
                })
            })
            alertController.addAction(destroyAction)
        } else {
            let destroyAction = PSTAlertAction(title: NSLocalizedString("Flag", comment: "Flag title"), style: .Destructive, handler: { (action) -> Void in
                post.flagPost(PFUser.currentUser()!)
                self.timelineComponent.removeObject(post)
                if let indexPath = self.tableView?.indexPathForCell(cell) {
                    
                    self.tableView?.beginUpdates()
                    self.tableView?.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Right)
                    self.tableView?.endUpdates()
                    self.showFlagUserAlertView(post.user!)
                }
            })
            alertController.addAction(destroyAction)
        }
        
        let cancelAction = PSTAlertAction(title: ConstantStrings.cancelString, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.showWithSender(cell.moreButton, arrowDirection: .Any, controller: self, animated: true, completion: nil)
    }
    
    //MARK: Saving drawings
    func updateDrawing(image: UIImage?) {
        if pickedCell != nil {
            pickedCell!.post!.drawingImage.value = image
            pickedCell!.post!.uploadDrawing()
        }
    }

    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "DrawingSegue" {
            if let pickedCell = sender as? PostTableViewCell {
                return pickedCell.postImageView.image != nil
            }
        }
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DrawingSegue" {
            let destViewC = segue.destinationViewController as! DrawingViewController
            pickedCell = sender as? PostTableViewCell
            destViewC.image = pickedCell?.postImageView.image
            destViewC.drawing = pickedCell?.drawingImageView.image
            destViewC.saveDrawingCallback = self.updateDrawing
        }
    }
    

}


// MARK: - Tab Bar Delegate
extension TimelineViewController : UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if ParseHelper.isThisUserSuspended(PFUser.currentUser()!) {
            return false
        }
        else if(viewController is PhotoViewController) {
            takePhoto();
            return false;
        } else {
            return true;
        }
    }
}

//MARK: - Data source

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

//MARK: - UITableViewDelegate
extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let diff = UIScreen.mainScreen().bounds.width - 320
        return 440 + diff //440 is good on iPhone 4 and 5
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("PostSectionHeaderFooterView") as! PostSectionHeaderFooterView
        
        let post = self.timelineComponent.content[section]
        headerCell.post = post
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}