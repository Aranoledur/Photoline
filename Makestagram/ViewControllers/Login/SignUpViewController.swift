//
//  SignUpViewController.swift
//  Photoline
//
//  Created by Nikolay Ischuk on 24.02.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import ParseUI

class SignUpViewController: PFSignUpViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UILabel()
        logo.text = "Photoline"
        logo.textColor = UIColor(red: 91/255, green: 108/255, blue: 119/255, alpha: 1)
        logo.font = UIFont(name: "HelveticaNeue-Light", size: 51)
        signUpView?.logo = logo
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
