//
//  User.swift
//  CPTwitter
//
//  Created by Faheem Hussain on 10/27/16.
//  Copyright © 2016 Faheem Hussain. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileUrl: URL?
    var tagline: String?
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        }
        tagline = dictionary["description"] as? String
    }
    static var _current: User?
    
    class var current: User? {
        get {
            if _current == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUser") as? Data
                
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _current = User(dictionary: dictionary)
                }
            }
            return _current
        }
        set(user) {
            _current = user
            let defaults = UserDefaults.standard
            if let user = user {
                do {
                    let data = try JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                    defaults.set(data, forKey: "currentUser")
                } catch {
                    defaults.set(nil, forKey: "currentUser")
                }

            } else {
                defaults.set(nil, forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
}
