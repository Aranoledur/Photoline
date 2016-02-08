//
//  DrawingViewController.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 06.02.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Color_Picker_for_iOS

typealias SaveCallback = UIImage? -> Void

class DrawingViewController: UIViewController {
    
    struct RingAndButton {
        weak var button: UIButton?
        weak var ringImageView: UIImageView?
    }

    @IBOutlet weak var drawingView: SmoothedBIView!
    weak var image: UIImage?
    weak var drawing: UIImage?
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet var customColorButtons: [UIButton]!
    @IBOutlet weak var baseImageView: UIImageView!
    @IBOutlet weak var moreColorsButton: UIButton!
    
    var saveDrawingCallback: SaveCallback?
    var ringImageView: UIImageView!
    var ringImagePair: RingAndButton = RingAndButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseImageView.image = self.image
        drawingView.currentColor = self.image!.areaAverage()
        drawingView.incrementalImage = self.drawing
        let newImage = colorButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
        colorButton.setImage(newImage, forState: .Normal)
        colorButton.tintColor = drawingView.currentColor
        

        var colorsArray = [UIColor]()
        colorsArray.append(UIColor(colorLiteralRed: 134/255.0, green: 103/255.0, blue: 172/255.0, alpha: 1.0))
        colorsArray.append(UIColor(colorLiteralRed: 101/255.0, green: 174/255.0, blue: 195/255.0, alpha: 1.0))
        colorsArray.append(UIColor(colorLiteralRed: 115/255.0, green: 200/255.0, blue: 175/255.0, alpha: 1.0))
        colorsArray.append(UIColor(colorLiteralRed: 240/255.0, green: 185/255.0, blue: 72/255.0, alpha: 1.0))
        colorsArray.append(UIColor(colorLiteralRed: 242/255.0, green: 108/255.0, blue: 76/255.0, alpha: 1.0))
        for (index, button) in customColorButtons.enumerate() {
            let newImage = colorButton.imageView!.image!.imageWithRenderingMode(.AlwaysTemplate)
            button.setImage(newImage, forState: .Normal)
            button.tintColor = colorsArray[index]
        }
        
        self.ringImageView = UIImageView(frame: colorButton.frame)
        self.ringImageView.image = UIImage(named: "ring")
        self.view.addSubview(self.ringImageView)
        
        self.ringImagePair.button = colorButton
        self.ringImagePair.ringImageView = self.ringImageView
        let newBackImage = moreColorsButton.backgroundImageForState(.Selected)?.imageWithRenderingMode(.AlwaysTemplate)
        moreColorsButton.setBackgroundImage(newBackImage, forState: .Selected)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let bCenter = self.ringImagePair.button?.center {
            self.ringImagePair.ringImageView?.center = bCenter
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Saving
    
    func saveImage() -> UIImage? {
        if let resultDrawing = drawingView.incrementalImage {
            UIGraphicsBeginImageContextWithOptions(drawingView.bounds.size, false, 0.0)
            resultDrawing.drawAtPoint(CGPointZero)
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resultImage
        }
        return nil
    }
    
    //MARK: Actions
    
    @IBAction func backButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func simpleColorButtonTapped(sender: UIButton) {
        self.drawingView.currentColor = sender.tintColor
        self.drawingView.lineWidth = 2.0
        self.ringImagePair.button = sender
        self.ringImageView.center = sender.center
        moreColorsButton.selected = false
    }

    @IBAction func moreColorsButtonTapped(sender: UIButton) {
    }
    
    @IBAction func eraserButtonTapped(sender: AnyObject) {
        self.drawingView.currentColor = UIColor.clearColor()
        self.drawingView.lineWidth = 10.0
    }
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
        self.drawingView.clearDrawing()
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        saveDrawingCallback?(self.saveImage())
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let colorPickerController = segue.destinationViewController as? ColorPickerViewController where segue.identifier == "PickColor" {
            colorPickerController.startColor = drawingView.currentColor
            colorPickerController.delegate = self
        }
    }
    

}

//MARK: extension ColorPickerDelegate

extension DrawingViewController: ColorPickerDelegate {
    func colorViewController(controller: UIViewController, didSelectColor: UIColor) {
        self.drawingView.currentColor = didSelectColor
        moreColorsButton.selected = true
        moreColorsButton.tintColor = didSelectColor
        
        self.ringImagePair.button = moreColorsButton
        self.ringImageView.center = moreColorsButton.center
    }
    
    func colorViewControllerDidCancel(controller: UIViewController) {
        //do nothing
    }
}