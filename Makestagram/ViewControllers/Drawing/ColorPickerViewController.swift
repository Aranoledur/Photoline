//
//  ColorPickerViewController.swift
//  Makestagram
//
//  Created by Nikolay Ischuk on 06.02.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Color_Picker_for_iOS

protocol ColorPickerDelegate: NSObjectProtocol {
    func colorViewController(controller: UIViewController, didSelectColor: UIColor)
    func colorViewControllerDidCancel(controller: UIViewController)
}

class ColorPickerViewController: UIViewController {

    @IBOutlet weak var colorPickerView: HRColorPickerView!
    weak var startColor: UIColor?
    weak var delegate: ColorPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        colorPickerView.color = self.startColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        delegate?.colorViewControllerDidCancel(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func chooseColorTapped(sender: AnyObject) {
        delegate?.colorViewController(self, didSelectColor: colorPickerView.color)
        self.dismissViewControllerAnimated(true, completion: nil)
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
