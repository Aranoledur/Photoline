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
        let cancelAction = PSTAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)

        alertController.showWithSender(self.senderView, controller: viewController, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        imagePickerController?.allowsEditing = true
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
}

extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, var didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let imageOriginalSize = image.size
        let maxWidth: CGFloat = 1080
        let imageScaleW = maxWidth / imageOriginalSize.width
        let imageScaleH = maxWidth / imageOriginalSize.height
        let imageScale = max(imageScaleW, imageScaleH)
        if imageScale < 1.0 {
            let imageMaxSize = CGSize(width: imageOriginalSize.width * imageScale, height: imageOriginalSize.height * imageScale)
            image = UIImage.imageWithImage(image, scaledToSize: imageMaxSize)
        }
        
        let filterViewController = FilterViewController(image: image)
        filterViewController.delegate = self
        imagePickerController?.presentViewController(filterViewController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePickerController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension PhotoTakingHelper: FilterViewControllerDelegate {
    
    func filterViewController(controller: FilterViewController, selectedImage: UIImage) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        
        callback(selectedImage)
    }
    
    func filterViewControllerCancelled(controller: FilterViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
