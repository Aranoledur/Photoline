//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 30.01.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = UIImage? -> Void

class PhotoTakingHelper: NSObject {
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    weak var senderView: UIView!
    
    init(senderView:UIView, viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.senderView = senderView
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoSourceSelection()
    }
    
    func pushModalViewController(newViewController: UIViewController) {
        imagePickerController!.presentViewController(newViewController, animated: true, completion: nil)
    }
    
    func popModalViewController() {
        imagePickerController!.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func showPhotoSourceSelection() {
        let alertController = PSTAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
        let cancelAction = PSTAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = PSTAlertAction(title: "Photo from Library", style: .Default) { (action) in
            self.showImagePickerController(.PhotoLibrary);
        }
        alertController.addAction(photoLibraryAction)
        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
            let cameraAction = PSTAlertAction(title: "Photo from Camera", style: .Default) { (action) in
                self.showImagePickerController(.Camera);
            }
            
            alertController.addAction(cameraAction)
        }
        
        alertController.showWithSender(self.senderView, controller: viewController, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
}

extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let filterViewController = FilterViewController(image: image)
        filterViewController.delegate = self
        imagePickerController?.presentViewController(filterViewController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension PhotoTakingHelper: FilterViewControllerDelegate {
    
    func filterViewController(controller: FilterViewController, selectedImage: UIImage) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        
        callback(selectedImage)
    }
    
    func filterViewControllerCancelled(controller: FilterViewController) {
        imagePickerController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
