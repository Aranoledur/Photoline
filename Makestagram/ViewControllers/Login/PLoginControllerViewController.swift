//
//  PLoginControllerViewController.swift
//  Photoline
//
//  Created by Nikolay Ischuk on 21.02.16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import ParseUI

class PLoginControllerViewController: PFLogInViewController {

    var viewsToUp: [UIView?]!
    var labelTermsMessage: UILabel!
    var buttonTerms: UIButton!
    var labelAnd: UILabel!
    var buttonPrivacy: UIButton!
    
    func insertTermsAndPrivacyButtons() {
        
        buttonTerms = UIButton(type: UIButtonType.System) as UIButton
        buttonTerms.frame = CGRectMake(0, 100, 90, 30)
        buttonTerms.setAttributedTitle(NSAttributedString(string: "terms of use", attributes:[NSUnderlineStyleAttributeName : 1]), forState: .Normal)
        let smallFont = UIFont(name: (buttonTerms.titleLabel?.font?.fontName)!, size: 13)
        buttonTerms.titleLabel?.font = smallFont
        buttonTerms.addTarget(self, action: "termsOfUseButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonTerms)
        
        labelTermsMessage = UILabel(frame: CGRectMake(100, 80, 220, 17))
        labelTermsMessage.font = UIFont(name: (smallFont?.fontName)!, size: 14)
        labelTermsMessage.text = "By signing up, you agree to our"
        self.view.addSubview(labelTermsMessage)
        
        labelAnd = UILabel(frame: CGRectMake(100, 100, 30, 30))
        labelAnd.font = smallFont
        labelAnd.text = "and"
        self.view.addSubview(labelAnd)
        
        buttonPrivacy = UIButton(type: UIButtonType.System) as UIButton
        buttonPrivacy.frame = CGRectMake(133, 100, 100, 30)
        buttonPrivacy.setAttributedTitle(NSAttributedString(string: "privacy policy.", attributes:[NSUnderlineStyleAttributeName : 1]), forState: .Normal)
        buttonPrivacy.titleLabel?.font = smallFont
        buttonPrivacy.addTarget(self, action: "privacyPolicyButtonTapeed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonPrivacy)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let logo = UILabel()
        logo.text = "Photoline"
        logo.textColor = UIColor(red: 91/255, green: 108/255, blue: 119/255, alpha: 1)
        logo.font = UIFont(name: "HelveticaNeue-Light", size: 51)
        logInView?.logo = logo
        
        insertTermsAndPrivacyButtons()
        viewsToUp = [logInView?.facebookButton, logInView?.signUpButton, self.logInView?.usernameField, self.logInView?.passwordField, self.logInView?.logInButton, self.logInView?.passwordForgottenButton, self.logInView?.logo]
        
        logInView?.facebookButton?.removeConstraints((logInView?.facebookButton?.constraints)!)
        logInView?.signUpButton?.removeConstraints((logInView?.signUpButton?.constraints)!)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()

        for view in viewsToUp {
            if let viewInt = view {
                viewInt.center = CGPointMake(viewInt.center.x, viewInt.center.y - 40)
            }
        }

        let sigupBtnFrame = self.logInView!.signUpButton!.frame
        labelTermsMessage.center = CGPointMake(self.logInView!.signUpButton!.center.x, sigupBtnFrame.origin.y + sigupBtnFrame.size.height + 14)
        
        let termsMessageFrame = labelTermsMessage.frame
        labelAnd.center = CGPointMake(termsMessageFrame.origin.x + termsMessageFrame.size.width/2 - 5, termsMessageFrame.origin.y + termsMessageFrame.size.height + 10)
        
        buttonTerms.center = CGPointMake(labelAnd.frame.origin.x - 4 - buttonTerms.frame.size.width/2, labelAnd.center.y)
        buttonPrivacy.frame.origin.x = labelAnd.frame.origin.x + labelAnd.frame.size.width - 4
        buttonPrivacy.center.y = labelAnd.center.y
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    
    @IBAction func termsOfUseButtonTapped(sender: AnyObject) {
        if let privacyPolicyURL = NSURL(string: "https://docs.google.com/document/d/1oajsWLoYEx9Mi9Vzup2s7RI6utAa5mNHgZJssOpSbK0/edit?usp=sharing") {
            UIApplication.sharedApplication().openURL(privacyPolicyURL)
        }
    }
    
    @IBAction func privacyPolicyButtonTapeed(sender: AnyObject) {
        if let privacyPolicyURL = NSURL(string: "https://docs.google.com/document/d/1Hj2rgn-GCm-GFzPGM8i0qVN4ja9VSEfvamxj0hoORPA/edit?usp=sharing") {
            UIApplication.sharedApplication().openURL(privacyPolicyURL)
        }
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
