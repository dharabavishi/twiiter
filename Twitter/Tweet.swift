//
//  Tweet.swift
//  Twitter
//
//  Created by Ruchit Mehta on 10/29/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit

class Tweet: NSObject {

    var text : String?
    var timestamp : Date?
    var retweetCount : Int = 0
    var favoutitesCount : Int = 0
    var profileImageURL : URL?
    var name : String?
    var favourited : Bool
    var screen_name : String?
    var retweetedStatus : String?
    var isRetweet : Int?
    var idStr : String?
    var dictTweets : NSDictionary?
    var retweetedStatusID : String?
    var retweetUserID : String?
    var userMentions : [Any]?
    
    
    init(name: String, screen_name: String, tweetText: String,profileImageUrl : URL, currentTime: Date){
        self.name = name
        self.screen_name = screen_name
        self.text = tweetText
        self.profileImageURL = profileImageUrl
        self.timestamp = currentTime
        self.favourited = false
        
    }
    init(dictionary : NSDictionary){
        
        let userDict = dictionary["user"] as? NSDictionary
        dictTweets = dictionary
        name = (userDict?["name"] as? String)!
        let screenName = userDict?["screen_name"] as? String
        screen_name = "@\(screenName!)"
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        
        
        let timeStampString = dictionary["created_at"] as? String
        if let timeStampStr = timeStampString{
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timeStampStr)
        }
        
        let imageURLString = userDict?["profile_image_url_https"] as? String
        if imageURLString != nil {
            profileImageURL = URL(string: imageURLString!)!
        } else {
            profileImageURL = nil
        }
        favoutitesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        favourited = (dictionary["favorited"] as? Bool)!
        isRetweet = (dictionary["retweeted"] as? Int)!
        if (dictionary["retweeted_status"] != nil){
            
            
            retweetedStatus = "\(name!) retweeted"
            let dic = dictionary["retweeted_status"] as? NSDictionary
            retweetUserID = dic?["id_str"] as? String
            
        }
        idStr = dictionary["id_str"] as? String
        
        
        
        
        
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary])-> [Tweet]{
     
        var tweets = [Tweet]()
        for dict in dictionaries{
            let tweet = Tweet(dictionary: dict)
            tweets.append(tweet)
            
        }
    return tweets
    }
}
