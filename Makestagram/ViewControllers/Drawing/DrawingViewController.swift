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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        drawingView.baseImage = self.image
        let newImage = colorButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
        colorButton.setImage(newImage, forState: .Normal)
        colorButton.tintColor = drawingView.currentColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func colorsButtonTapped(sender: UIButton) {
        let colorPickerController = NEOColorPickerViewController()
        colorPickerController.delegate = self
        colorPickerController.selectedColor = drawingView.currentColor
        colorPickerController.title = NSLocalizedString("Pick a color!", comment: "Picking color title")
        
        let navigationController = UINavigationController(rootViewController: colorPickerController)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
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
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func colorPickerViewControllerDidCancel(controller: NEOColorPickerBaseViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)

    }
}