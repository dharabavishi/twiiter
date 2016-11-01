//
//  TweetsDetailViewController.swift
//  Twitter
//
//  Created by Ruchit Mehta on 10/31/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit
protocol TweetsDetailViewControllerDelegate {
    func reloadDataFromDetail(tweet: Tweet)
}
class TweetsDetailViewController: UIViewController {
    
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
    var delegate : TweetsDetailViewControllerDelegate?
    
    var tweet : Tweet!

        override func viewDidLoad() {
        super.viewDidLoad()
            
       

        setUpView()
       
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.delegate?.reloadDataFromDetail(tweet: tweet)
    }
    func setUpView(){
        
        self.title = "Tweet"
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
       
        let dateInString = Helper.getDateTime(date: tweet.timestamp!)
        timeLabel.text = "\(dateInString)"
        
        if tweet.favourited{
            favouriteButton.isSelected = true
        }else{
            favouriteButton.isSelected = false
        }
        
        
        displayScreenLabel.text = tweet.screen_name
        profileImageTopConstraint.constant = 72
        reTweetedStackView.isHidden = true
        retweetButton.isSelected = false
        print("tweet status is \(tweet.retweetedStatus)")
        if tweet.isRetweet == 1  {
            
            retweetButton.isSelected = true
            if(tweet.retweetedStatus != nil){
                reTweetedStackView.isHidden = false
                reTweetedlabel.text = tweet.retweetedStatus
                
                profileImageTopConstraint.constant = 98
            }
            
            
            
        }
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func reloadDataFromDetail(tweet: Tweet) {
        delegate?.reloadDataFromDetail(tweet: tweet)
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
