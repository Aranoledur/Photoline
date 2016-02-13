//
//  FilterViewController.swift
//  Makestagram
//
//  Created by Benjamin Encz on 4/9/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import CoreImage
import ConvenienceKit


protocol FilterViewControllerDelegate: class {
    func filterViewController(controller: FilterViewController, selectedImage: UIImage)
    func filterViewControllerCancelled(controller: FilterViewController)
}

class FilterViewController: UIViewController {
    
    var image: UIImage
    var filters = [Filters.NoFilter, Filters.SepiaFilter, Filters.VibranceFilter, Filters.VignetteFilter]
    weak var delegate: FilterViewControllerDelegate?
    var imageCache: NSCacheSwift<Int, UIImage>!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    init(image: UIImage) {
        self.image = image
        
        super.init(nibName: "FilterViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = image
        let cellNib = UINib(nibName: "FilterCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "filterCell")
        collectionView.reloadData()
        imageCache = NSCacheSwift()
    }
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        // the image view stores the image with the latest applied filter
        delegate?.filterViewController(self, selectedImage: self.imageView.image!)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        delegate?.filterViewControllerCancelled(self)
    }
}

extension FilterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as! FilterCollectionViewCell
        
        filterCell.filter = filters[indexPath.row]
        
        return filterCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.imageView!.image = imageCache[indexPath.row] ?? filters[indexPath.row].filterFunction(image)
        if imageCache[indexPath.row] == nil {
            imageCache[indexPath.row] = self.imageView.image
        }
    }
    
}