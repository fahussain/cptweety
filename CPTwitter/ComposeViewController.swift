//
//  ComposeViewController.swift
//  CPTwitter
//
//  Created by Faheem Hussain on 10/30/16.
//  Copyright © 2016 Faheem Hussain. All rights reserved.
//

import UIKit

protocol ComposeDelegate: class {
    func composeFor(tweet: Tweet?)
}

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    
    let maxCharacters = 140
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var charactersRemainingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetTextView: UITextView!
    
    var tweet: Tweet?
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.setImageWith((User.current?.profileUrl)!)
        profileImageView.layer.cornerRadius = 4
        profileImageView.layer.masksToBounds = true
        nameLabel.text = User.current?.name
        screennameLabel.text = "@\(User.current!.screenname!)"
        tweetTextView.delegate = self
        charactersRemainingLabel.text = "\(maxCharacters)"
        if tweet != nil {
            tweetTextView.text = "@\(tweet!.user!.screenname!)"
        }
        tweetTextView.becomeFirstResponder()
    }
    func textViewDidChange(_ textView: UITextView) {
        let tweetText = textView.text
        let charactersRemaining = maxCharacters - (tweetText?.characters.count)!
        charactersRemainingLabel.text = "\(charactersRemaining)"
        if charactersRemaining < 1 {
            let text = textView.text
            textView.text = text?.substring(to: (text?.index((text?.startIndex)!, offsetBy: maxCharacters))!)
            charactersRemainingLabel.text = "0"
        }
        charactersRemainingLabel.textColor = charactersRemaining >= 1 ? UIColor.lightGray : UIColor.red
        //self.adjustScrollViewContentSize()

    }
    @IBAction func onCancelTap(_ sender: AnyObject) {
        dismissMe()
    }
    func dismissMe() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    @IBAction func onTweetTap(_ sender: AnyObject) {
        var params: NSDictionary!
        if tweet != nil {
            params = ["status": tweetTextView.text, "in_reply_to_status_id": tweet?.id]
        }else {
            params = ["status": tweetTextView.text]
        }
        TwitterClient.shared?.apiPost(params: params
            , success: { (response: NSDictionary) in
                self.dismissMe()
            }, failure: { (error: Error) in
                print("Error: \(error.localizedDescription)")
                
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
