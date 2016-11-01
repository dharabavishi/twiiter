//
//  TwitterClient.swift
//  Twitter
//
//  Created by Ruchit Mehta on 10/27/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let  consumerKey = "bBRVqCAgL3F3kATxww9DhWtjy"
let  consumerSecret = "dGz9LTIMNBoXRg06sPsXUpJw89btObtmGYEBaKK0XLWJ129B0X"
let  appUrl = "https://api.twitter.com"



class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance =  TwitterClient(baseURL: NSURL(string:appUrl)! as URL!, consumerKey: consumerKey, consumerSecret: consumerSecret)!
    var loginSuccess :  (() -> ())?
    var loginFail : ((Error)->())?
    
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error)->() ){
        
        
        TwitterClient.sharedInstance.get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task : URLSessionDataTask?, requestData : Any?)-> Void in
            
            print(requestData)
            let tweetsDictionaries = requestData as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: tweetsDictionaries)
            success(tweets)
            
            
            }, failure: { (task : URLSessionDataTask?, error : Error)-> Void in
                
            print(error.localizedDescription)
            failure(error)
        })
        
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()){
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task : URLSessionDataTask, response : Any?) in
            print("--- TwitterClient: currentAccount : Success")
            let userDictionary = response as! NSDictionary
            let user = User(dictionary : userDictionary)
            
            success(user)
            
            }, failure: { (task : URLSessionDataTask?, error : Error) in
                failure(error)
                
        })
        
    }
    func postTweet(params: Any, success: @escaping() -> (), failure: @escaping (Error) -> ()){
        post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task : URLSessionDataTask,response : Any?) in
            success()
        }) { (task : URLSessionDataTask?,error: Error) in
            failure(error)
        }
    }
    
    func login(success : @escaping () -> (), failure : @escaping (Error)->()){
        
        loginSuccess = success
        loginFail = failure
        let client  = TwitterClient.sharedInstance
        //client.deauthorize()
        client.fetchRequestToken(withPath:"oauth/request_token",
                                 method: "GET",
                                 callbackURL: URL(string:"twitterDemo://oauth"),
                                 scope: nil,
                                 success: { (requestToken:BDBOAuth1Credential?)->Void in
                                    
                                    print("here it is \(requestToken!.token!)")
                                    
                                    let fileUrl = Foundation.URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")
                                    
                                    UIApplication.shared.open(fileUrl!, options: [:], completionHandler: { (isThere : Bool) in
                                        
                                    })
                                    
                                    
                                    print("Token ")
               
                                    
            }, failure: { (error: Error?)->Void in
                print("Error is \(error.debugDescription)")
                self.loginFail?(error!)
                
                
        })
    }
    
    func favoriteTweet(params: Any, success: @escaping() -> (), failure: @escaping (Error) -> ()){
        post("1.1/favorites/create.json", parameters: params, progress: nil, success: { (task : URLSessionDataTask,response : Any?) in
            success()
        }) { (task : URLSessionDataTask?,error: Error) in
            failure(error)
        }
    }
    
    func unfavoriteTweet(params: Any, success: @escaping() -> (), failure: @escaping (Error) -> ()){
        post("1.1/favorites/destroy.json", parameters: params, progress: nil, success: { (task : URLSessionDataTask,response : Any?) in
            success()
        }) { (task : URLSessionDataTask?,error: Error) in
            failure(error)
        }
    }
    
    func getStatusForreTweet(params: String, success: @escaping(NSDictionary) -> (), failure: @escaping (Error) -> ()){
        let showStatusesBaseUrl = "1.1/statuses/show/{id}.json?include_my_retweet=1"
        let showStatusUrl = showStatusesBaseUrl.replacingOccurrences(of: "{id}", with: params)
        get(showStatusUrl, parameters: nil, progress: nil, success: { (task : URLSessionDataTask,response : Any?) in
            let tweet = response as! NSDictionary
            success(tweet)
        }) { (task : URLSessionDataTask?,error: Error) in
            failure(error)
        }
    }
    
    func doRetweet(params: String, success: @escaping() -> (), failure: @escaping (Error) -> ()){
        let retweetUrl = "1.1/statuses/retweet/{id}.json"
        let retweetUrlAfterReplacing = retweetUrl.replacingOccurrences(of: "{id}", with: params)
        post(retweetUrlAfterReplacing, parameters: nil, progress: nil, success: { (task : URLSessionDataTask,response : Any?) in
            success()
        }) { (task : URLSessionDataTask?,error: Error) in
            failure(error)
        }
    }
    func undoRetweet(params: String, success: @escaping() -> (), failure: @escaping (Error) -> ()){
        let retweetUrl = "1.1/statuses/unretweet/{id}.json"
        let retweetUrlAfterReplacing = retweetUrl.replacingOccurrences(of: "{id}", with: params)
        post(retweetUrlAfterReplacing, parameters: nil, progress: nil, success: { (task : URLSessionDataTask,response : Any?) in
            success()
        }) { (task : URLSessionDataTask?,error: Error) in
            failure(error)
        }
    }

    func handleOpenUrl(url : URL){
        
        let requestToken = BDBOAuth1Credential(queryString : url.query)
        
        let client = TwitterClient.sharedInstance
        client.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken : BDBOAuth1Credential?)-> Void in
            
            print("Access token \(accessToken)")
            self.currentAccount(success: { (user : User) -> () in
                User.currentUser = user
                self.loginSuccess?()
                }, failure: { (error : Error) -> () in
                    self.loginFail?(error)
                    
            })
            
           self.loginSuccess?()
            
            
            
            }, failure: { (error :  Error?) in
                print(error?.localizedDescription)
                self.loginFail?(error!)
                
        })

    }
    func logout(){
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userLogoutNotification), object: nil)
    }
    
    func loadMoreHomeTimeline(params: Int64, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()){
        let params = ["max_id" : params - 1]
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (task : URLSessionDataTask,response: Any?) in
            print("--- TwitterClient : home time line response  success")
            
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            success(tweets)
            }, failure: { (task : URLSessionDataTask?, error : Error) in
                failure(error)
                
        })
    }

}
