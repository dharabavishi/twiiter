//
//  TweetViewController.swift
//  Twitter
//
//  Created by Ruchit Mehta on 10/29/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit
import MBProgressHUD
class TweetViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,TweetsDetailViewControllerDelegate,ComposeTweetViewControllerDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tweets : [Tweet]!
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false
    
    //var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpPullToRefresh()
        setUpTableView()
        setUpNavigationBar()
        //setupScrollViewIndicator()
        getRefreshTweets(isHud: true)
        
        // Do any additional setup after loading the view.
    }
//    func setupScrollViewIndicator(){
//        // Set up Infinite Scroll loading indicator
//        let frame = CGRect(origin: CGPoint (x : 0, y : tableView.contentSize.height),size : CGSize( width : tableView.bounds.size.width,height : InfiniteScrollActivityView.defaultHeight))
//        loadingMoreView = InfiniteScrollActivityView(frame: frame)
//        loadingMoreView!.isHidden = true
//        tableView.addSubview(loadingMoreView!)
//        
//        var insets = tableView.contentInset;
//        insets.bottom += InfiniteScrollActivityView.defaultHeight;
//        tableView.contentInset = insets
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    func setUpPullToRefresh(){
        
       
        refreshControl.addTarget(self, action: #selector(self.refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
    }
    func getRefreshTweets(isHud : Bool){
        
        if(isHud){
            addHud()
        }
       
        TwitterClient.sharedInstance.homeTimeline(success: { (tweets : [Tweet]) in
            
            
            self.tweets = tweets
            for tweet in self.tweets{
                
                
                print("__________________")
                print(tweet.text!)
                print(tweet.favoutitesCount)
                print(tweet.timestamp)
                self.tableView.reloadData()
                self.dismissHud()
                
            }
            
        }) { (error : Error) in
            
             self.dismissHud()
            
        }
    }
    func setUpNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor.white
        //UIColor.init(colorLiteralRed: 51.0/255.0, green: 145.0/255.0, blue: 236.0/255.0, alpha: 1)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 2, width: 30 , height: 30))
        imageView.contentMode = UIViewContentMode.center
        let imageName = UIImage(named: "navTitle")
        imageView.image = imageName
        self.navigationItem.titleView = imageView

        
    }
    func setUpTableView(){
        self.tableView.estimatedRowHeight = 550
        self.tableView.rowHeight = UITableViewAutomaticDimension

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.tweets) != nil{
            
            return self.tweets.count
        }
        else{
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetsCell", for: indexPath) as! TweetsCell
        cell.tweet = self.tweets[indexPath.row]
        return cell
    }
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
       getRefreshTweets(isHud: false)
    }
    
    func addHud(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    func dismissHud(){
        MBProgressHUD.hide(for: self.view, animated: true)
        self.refreshControl.endRefreshing()
    }
    //MARK: IBACTIONS
    @IBAction func onLogoutClick(_ sender: AnyObject) {
        
        TwitterClient.sharedInstance.logout()
    }
    
     @IBAction func onComposeNewTweet(_ sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeTweetViewController = storyboard.instantiateViewController(withIdentifier: "composeTweetViewController") as! ComposeTweetViewController
        composeTweetViewController.delegate = self
        present(composeTweetViewController, animated: true) {
        }
     }
    
       
    @IBAction func replyClick(_ sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeViewController = storyboard.instantiateViewController(withIdentifier: "composeTweetViewController") as! ComposeTweetViewController
       
        let indexPath = tableView.indexPath(for: sender.superview??.superview as! UITableViewCell)!
        let tweet = tweets[indexPath.row]
        composeViewController.tweet = tweet
        composeViewController.delegate = self
        present(composeViewController, animated: true) {
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "tweetVCDetailSegue") {
            let cell = sender as! TweetsCell
            let indexPath = tableView.indexPath(for: cell)
            let tweet = tweets[(indexPath! as NSIndexPath).row]
            
            let tweetDetailsViewController = segue.destination as! TweetsDetailViewController
            tweetDetailsViewController.tweet = tweet
            tweetDetailsViewController.delegate = self
        }
    }
    //MARK: Detail delegate
    func reloadDataFromDetail(tweet: Tweet){
        self.tableView.reloadData()
    }
    func fromComposeTweet(tweet: Tweet){
        self.tweets.insert(tweet, at: 0)
        self.tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true
                
                // Code to load more results
                //loadMoreData()
            }
        }
    }
//    func loadMoreData() {
//        
//        TwitterClient.sharedInstance.loadMoreHomeTimeline(params: Int64.max, success: { (newTweets : [Tweet]) in
//            
//            self.tweets.append(contentsOf: newTweets)
//            self.tableView.reloadData()
//            
//            // Update flag
//            self.isMoreDataLoading = false
//            
//            // Stop the loading indicator
//            self.loadingMoreView!.stopAnimating()
//            
//        }) { (error : Error) in
//            
//        }
//    }

}
