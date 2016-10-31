//
//  Tweet.swift
//  CPTwitter
//
//  Created by Faheem Hussain on 10/27/16.
//  Copyright © 2016 Faheem Hussain. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: String?
    var timestamp: Date?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var favorited: Bool?
    var reTweeted: Bool?
    var originalId: Int?
    var id: Int?
    var user: User!
    var retweetStatus: Tweet?
    var hasRetweetStatus: Bool = false
    var idStr: String?
    init(dictionary: NSDictionary){
        super.init()
        setFrom(dictionary: dictionary)
    }
    
    func setFrom(dictionary: NSDictionary){
        var tweetDictionary: NSDictionary = dictionary
        
        favorited = (tweetDictionary["favorited"] as? Int == 1)
        reTweeted = (tweetDictionary["retweeted"]! as! Int == 1)
        originalId = (tweetDictionary["id"] as? Int) ?? 0
        idStr = tweetDictionary["created_at"] as? String
        id = (tweetDictionary["id"] as? Int) ?? 0
        user = User(dictionary: tweetDictionary["user"] as! NSDictionary)
        if tweetDictionary["retweeted_status"] != nil{
            tweetDictionary = dictionary["retweeted_status"] as! NSDictionary
            hasRetweetStatus = true
            retweetStatus = Tweet(dictionary: tweetDictionary)
        } else {
            tweetDictionary = dictionary
        }
        let timestampString = tweetDictionary["created_at"] as? String
        
        text = tweetDictionary["text"] as? String
        retweetCount = (tweetDictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (tweetDictionary["favorite_count"] as? Int) ?? 0
        
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet]{
        var tweets : [Tweet] = []
        var minId: Int64 = (dictionaries[0]["id"] as! NSNumber).int64Value
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            let tid = (dictionary["id"] as! NSNumber).int64Value
            if tid < minId {
                minId = tid
            }
            tweets.append(tweet)
        }
        return tweets
    }
    func replaceWith(dictionary: NSDictionary){
        setFrom(dictionary: dictionary)
    }
}
