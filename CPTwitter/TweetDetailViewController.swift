//
//  TweetDetailViewController.swift
//  CPTwitter
//
//  Created by Faheem Hussain on 10/28/16.
//  Copyright © 2016 Faheem Hussain. All rights reserved.
//

import UIKit
import FaveButton
import ActiveLabel

class TweetDetailViewController: UIViewController, FaveButtonDelegate{

    weak var composer: ComposeDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var statusTextLabel: ActiveLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: FaveButton!
    @IBOutlet weak var retweetButton: FaveButton!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Tweet"
        retweetButton.selectedColor = UIColor(netHex: 0x15CB71)
        favoriteButton.delegate = self
        retweetButton.delegate = self
        profileImage.setImageWith((tweet?.user.profileUrl!)!)
        profileImage.layer.cornerRadius = 4.0
        profileImage.layer.masksToBounds = true
        nameLabel.text = tweet?.user.name
        screennameLabel.text = "@\(tweet!.user.screenname!)"
        statusTextLabel.text = tweet?.text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy 'at' h:mm aaa"
        dateLabel.text = formatter.string(from: tweet!.timestamp!)
        
        retweetCountLabel.text = "\(tweet!.retweetCount)"
        favoritesCountLabel.text = "\(tweet!.favoritesCount)"
        if retweetButton.isSelected != tweet!.reTweeted! {
            retweetButton.isSelected = tweet!.reTweeted!
        }
        if favoriteButton.isSelected != tweet!.favorited! {
            favoriteButton.isSelected = tweet!.favorited!
        }
        
        statusTextLabel.handleURLTap { (url: URL) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        statusTextLabel.handleHashtagTap { (hashTag) in
            self.showAlert(title: "Hashtag", message: "You tapped #\(hashTag)")
        }
        statusTextLabel.handleMentionTap { (mention) in
            self.showAlert(title: "Mention", message: "You tapped #\(mention)")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onReplyTap(_ sender: AnyObject) {
        composer?.composeFor(tweet: tweet!)
    }
    func likeTweet(){
        let params: NSDictionary = ["id" : tweet!.id!]
        TwitterClient.shared?.likeTweet(destroy: tweet!.favorited!, params: params, success: { (tweet: NSDictionary) in
            self.tweet!.replaceWith(dictionary: tweet)
            }, failure: { (error: Error) in
                print("like erro: \(error.localizedDescription)")
                self.favoriteButton.isSelected = !self.tweet!.favorited!
                if self.favoriteButton.isSelected {
                    self.favoriteCount(add: true)
                } else {
                    self.favoriteCount(add: false)
                }
        })
    }
    func favoriteCount(add: Bool){
        if add {
            favoritesCountLabel.text = favoritesCountLabel.text?.add(number: 1)
        }else {
            favoritesCountLabel.text = favoritesCountLabel.text?.add(number: -1)
        }
    }
    func retweetCount(add: Bool){
        if add {
            retweetCountLabel.text = retweetCountLabel.text?.add(number: 1)
        }else {
            retweetCountLabel.text = retweetCountLabel.text?.add(number: -1)
        }
    }
    func retweet() {
        let params: NSDictionary = ["id" : tweet!.id!]
        
        //print("retweeted:\(tweet.reTweeted!)")
        TwitterClient.shared?.retweet(unRetweet: tweet!.reTweeted!, params: params, success: { (tweet: NSDictionary) in
            print("\(tweet)")
            self.tweet!.replaceWith(dictionary: tweet)
            print("retweeted:\(self.tweet!.reTweeted!)")
            //NotificationCenter.default.post(name: TweetCell.tweetDidChange, object: nil)
            }, failure: { (error: Error) in
                print("Retweet Erro: \(error.localizedDescription)")
                self.retweetButton.isSelected = !self.tweet!.reTweeted!
                if self.retweetButton.isSelected {
                    self.retweetCount(add: true)
                } else {
                    self.retweetCount(add: false)
                }
        })
    }
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool){
        if faveButton === favoriteButton {
            if selected {
                favoriteCount(add: true)
            } else {
                favoriteCount(add: false)
            }
            likeTweet()
        } else if faveButton === retweetButton {
            if selected {
                retweetCount(add: true)
            } else {
                retweetCount(add: false)
            }
            retweet()
        }
    }
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        if( faveButton === favoriteButton){
            //return colors
            
        }
        return nil
    }
    
    func showAlert (title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response here.
        }
        alertController.addAction(OKAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
