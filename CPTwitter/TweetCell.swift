//
//  TweetCell.swift
//  CPTwitter
//
//  Created by Faheem Hussain on 10/28/16.
//  Copyright © 2016 Faheem Hussain. All rights reserved.
//

import UIKit
import ActiveLabel
import SwiftDate
import FaveButton

class TweetCell: UITableViewCell, FaveButtonDelegate {
    
    weak var composer: ComposeDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tweeTextLabel: ActiveLabel!
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var retweetButton: FaveButton!
    @IBOutlet weak var favoriteButton: FaveButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var topRetweetLabel: UILabel!
    @IBOutlet weak var retweetViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topRetweetView: UIView!

    static let tweetDidChange = NSNotification.Name(rawValue: "TweetDidChange")
    
    var tweet: Tweet! {
        didSet {
            nameLabel.text = tweet.user.name
            usernameLabel.text = "@\(tweet.user.screenname!)"
            let dateFormatter = DateFormatter()
            timeLabel.text = dateFormatter.timeSince(from: tweet.timestamp!, numericDates: true)
            tweeTextLabel.text = tweet.text
            thumbImageView.setImageWith(tweet.user.profileUrl!)
            retweetCountLabel.text = "\(tweet.retweetCount)"
            favoritesCountLabel.text = "\(tweet.favoritesCount)"
            if retweetButton.isSelected != tweet.reTweeted! {
                retweetButton.isSelected = tweet.reTweeted!
            }
            if favoriteButton.isSelected != tweet.favorited! {
                favoriteButton.isSelected = tweet.favorited!
            }
            if tweet.hasRetweetStatus {
                topRetweetLabel.text = tweet.retweetStatus!.user.name!
            }else {
                topRetweetView.isHidden = true
            }
        }
    }
    var oldTweet: Tweet?

    
    @IBAction func onReplyTap(_ sender: AnyObject) {
        composer?.composeFor(tweet: self.tweet)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        favoriteButton.delegate = self
        retweetButton.delegate = self
        retweetButton.selectedColor = UIColor(netHex: 0x15CB71)
        thumbImageView.layer.cornerRadius = 4
        thumbImageView.clipsToBounds = true
        tweeTextLabel.handleURLTap { (url: URL) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        tweeTextLabel.handleHashtagTap { (hashTag) in
            self.showAlert(title: "Hashtag", message: "You tapped #\(hashTag)")
        }
        tweeTextLabel.handleMentionTap { (mention) in
            self.showAlert(title: "Mention", message: "You tapped #\(mention)")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func likeTweet(){
        let params: NSDictionary = ["id" : tweet.id!]
        TwitterClient.shared?.likeTweet(destroy: tweet.favorited!, params: params, success: { (tweet: NSDictionary) in
            self.tweet.replaceWith(dictionary: tweet)
            }, failure: { (error: Error) in
                print("like erro: \(error.localizedDescription)")
                self.favoriteButton.isSelected = !self.tweet.favorited!
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
        let params: NSDictionary = ["id" : tweet.id!]
        
        //print("retweeted:\(tweet.reTweeted!)")
        TwitterClient.shared?.retweet(unRetweet: tweet.reTweeted!, params: params, success: { (tweet: NSDictionary) in
            print("\(tweet)")
            self.tweet.replaceWith(dictionary: tweet)
            print("retweeted:\(self.tweet.reTweeted!)")
            //NotificationCenter.default.post(name: TweetCell.tweetDidChange, object: nil)
            }, failure: { (error: Error) in
                print("Retweet Erro: \(error.localizedDescription)")
                self.retweetButton.isSelected = !self.tweet.reTweeted!
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


}
