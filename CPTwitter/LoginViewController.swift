//
//  ViewController.swift
//  CPTwitter
//
//  Created by Faheem Hussain on 10/27/16.
//  Copyright © 2016 Faheem Hussain. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLoginWithTwitter(_ sender: AnyObject) {
        TwitterClient.shared?.login(success: { 
                print("Logged in")
                self.performSegue(withIdentifier: "LoginAndShowTweets", sender: self)
            }, failure: { (error: Error) in
                print("\(error.localizedDescription)")
        })
    }

}

