//
//  DrawingViewController.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 06.02.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Color_Picker_for_iOS

class DrawingViewController: UIViewController {

    @IBOutlet weak var drawingView: SmoothedBIView!
    var image: UIImage?
    var pickerView: HRColorPickerView?
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet var customColorButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        drawingView.baseImage = self.image
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func simpleColorButtonTapped(sender: UIButton) {
        self.drawingView.currentColor = sender.tintColor
        self.drawingView.lineWidth = 2.0
    }

    @IBAction func colorsButtonTapped(sender: UIButton) {
        let colorPickerController = NEOColorPickerViewController()
        colorPickerController.delegate = self
        colorPickerController.selectedColor = drawingView.currentColor
        colorPickerController.title = NSLocalizedString("Pick a color!", comment: "Picking color title")
        
        let navigationController = UINavigationController(rootViewController: colorPickerController)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    @IBAction func eraserButtonTapped(sender: AnyObject) {
        self.drawingView.currentColor = UIColor.clearColor()
        self.drawingView.lineWidth = 10.0
    }
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
        self.drawingView.clearDrawing()
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DrawingViewController: NEOColorPickerViewControllerDelegate {
    func colorPickerViewController(controller: NEOColorPickerBaseViewController!, didSelectColor color: UIColor!) {
        self.drawingView.currentColor = color
        self.drawingView.lineWidth = 2.0

        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func colorPickerViewControllerDidCancel(controller: NEOColorPickerBaseViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)

    }
}