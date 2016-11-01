//
//  TweetsCell.swift
//  Twitter
//
//  Created by Ruchit Mehta on 10/29/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit
import Swift
protocol TweetsCellDelegate {
    func replyClick(tweet: Tweet)
    
}
class TweetsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var displayScreenLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var textDescriptionLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var reTweetedStackView: UIStackView!
    @IBOutlet weak var reTweetedlabel: UILabel!
    
    @IBOutlet weak var profileImageTopConstraint: NSLayoutConstraint!
    
    let twitterClient = TwitterClient.sharedInstance
    var tweet : Tweet!{
        didSet{
            
            if let name = tweet.name{
                
                nameLabel.text = name
            }else{
                nameLabel.text =  ""
            }
            
            if let desc = tweet.text{
                textDescriptionLabel.text = desc
            }else{
                textDescriptionLabel.text = ""
            }
            let imageURLString = tweet.profileImageURL
            if imageURLString != nil {
                profileImageView.setImageWith(tweet.profileImageURL!)
                
            } else {
                profileImageView = nil
            }
            
            
            if tweet.favoutitesCount == 0{
                favCountLabel.isHidden = true
                favCountLabel.text = ""
            }
            else{
                favCountLabel.isHidden = false
                favCountLabel.text = "\(tweet.favoutitesCount)"
                
            }
            
            if tweet.retweetCount == 0{
                retweetCount.isHidden = true
                retweetCount.text = ""
                retweetButton.isSelected = false
            }
            else{
                retweetCount.isHidden = false
                retweetCount.text = "\(tweet.retweetCount)"
                retweetButton.isSelected = true
                
            }
            timeLabel.text = "\(tweet.timestamp!)"
            let dateInString = Helper.timeAgoSinceDate(date: tweet.timestamp!, numericDates: true)
            timeLabel.text = ".\(dateInString)"
            
            if tweet.favourited{
                favouriteButton.isSelected = true
            }else{
                favouriteButton.isSelected = false
            }
            
            
            displayScreenLabel.text = tweet.screen_name
            profileImageTopConstraint.constant = 8
            reTweetedStackView.isHidden = true
            retweetButton.isSelected = false
            print("tweet status is \(tweet.retweetedStatus)")
            if tweet.isRetweet == 1  {
                
                retweetButton.isSelected = true
                if(tweet.retweetedStatus != nil){
                    reTweetedStackView.isHidden = false
                    reTweetedlabel.text = tweet.retweetedStatus
                    
                    profileImageTopConstraint.constant = 26
                }
                
               
                
                
            }
            
            
            
            
        }
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        self.selectionStyle = .none
        
    }
    @IBAction func retweetClick(_ sender: UIButton) {
       
        if(!sender.isSelected){
            let params = tweet.idStr
            twitterClient.doRetweet(params: params!, success: {
                print("Retweet done")
                }, failure: { (error : Error) in
                    print(error.localizedDescription)
            })
            tweet.retweetCount += 1
            tweet.isRetweet = 1
            
        } else {
            var originalTweetId = tweet.idStr
            
            
            if(tweet.dictTweets?["retweeted_status"] != nil){
                let actualOriginalTweetId = tweet.retweetUserID
                originalTweetId = actualOriginalTweetId
            }
            
            
            twitterClient.getStatusForreTweet(params: originalTweetId!, success: { (originalTweet : NSDictionary) in
                let originalTweetJson = originalTweet["current_user_retweet"] as? NSDictionary
                let retweetId = originalTweetJson?["id_str"] as? String
                
                print("Rewwwt id (retweetId)")
                
                self.twitterClient.undoRetweet(params: retweetId!, success: {
                    
                    }, failure: { (error : Error) in
                        print(error.localizedDescription)
                })
                
                }, failure: { (error : Error) in
                    print(error.localizedDescription)
            })
            tweet.retweetCount -= 1
            tweet.isRetweet = 0
            
        }
        sender.isSelected = !sender.isSelected
        if tweet.retweetCount == 0{
            retweetCount.isHidden = true
            retweetCount.text = ""
            
            
        }
        else{
            retweetCount.isHidden = false
            retweetCount.text = "\(tweet.retweetCount)"
            
            
            
            
        }
       
       
    }

    @IBAction func favouriteClick(_ sender: UIButton) {
        
        var parameter = [String : String]()
        parameter["id"] = tweet.idStr
        
        if(sender.isSelected){
            
            twitterClient.unfavoriteTweet(params: parameter, success: {
                
                print("UnFav")
                }, failure: { (error : Error) in
                    print(error.localizedDescription)
            })
            tweet.favoutitesCount -= 1
            tweet.favourited = false
            
            
            
        } else {
            twitterClient.favoriteTweet(params: parameter, success: {
                print("Fav")
                }, failure: { (error : Error) in
                    print(error.localizedDescription)
            })
            tweet.favoutitesCount += 1
            tweet.favourited = true
           
        }
        sender.isSelected = !sender.isSelected
        
        if tweet.favoutitesCount == 0{
            favCountLabel.isHidden = true
            favCountLabel.text = ""
            
        }
        else{
            favCountLabel.isHidden = false
            favCountLabel.text = "\(tweet.favoutitesCount)"
            
            
        }
        
        
    }
    
    
    
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
