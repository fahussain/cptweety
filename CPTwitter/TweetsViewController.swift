//
//  TweetsViewController.swift
//  CPTwitter
//
//  Created by Faheem Hussain on 10/28/16.
//  Copyright © 2016 Faheem Hussain. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeDelegate {

    
    @IBOutlet weak var tweetsTableView: UITableView!
    var tweets: [Tweet] = []
    private let refreshControl = UIRefreshControl()
    var isMoreDataLoading: Bool = false
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self
        tweetsTableView.estimatedRowHeight = 88
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(forName: TweetCell.tweetDidChange, object: nil, queue: OperationQueue.main) { (notification: Notification) in
            self.tweetsTableView.reloadData()
        }
        addPullToRefresh()
        loadTweets()
        // Do any additional setup after loading the view.
    }
    func addPullToRefresh(){
        refreshControl.tintColor = UIColor.white
        refreshControl.backgroundColor = UIColor(netHex: 0x1D8DEF)
        let attributes = [NSForegroundColorAttributeName: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Tweets ...", attributes: attributes)
        if #available(iOS 10.0, *) {
            tweetsTableView.refreshControl = refreshControl
        } else {
            tweetsTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func onNewTap(_ sender: AnyObject) {
        composeFor(tweet: nil)
    }
    @IBAction func onLogoutTap(_ sender: AnyObject) {
        TwitterClient.shared?.logout()
    }
    func refreshData(sender: UIRefreshControl) {
        TwitterClient.shared?.homeTimeline(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tweetsTableView.reloadData()
                sender.endRefreshing()
            }, failure: { (error: Error) in
                print("Error:\(error.localizedDescription)")
                sender.endRefreshing()
        })
    }
    func loadTweets(){
        TwitterClient.shared?.homeTimeline(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tweetsTableView.reloadData()
            }, failure: { (error: Error) in
                print("Error:\(error.localizedDescription)")
        })
    }
    func loadMoreData() {
        let params: NSDictionary = ["max_id":tweets.last?.id]
        TwitterClient.shared?.homeTimeline(params: params, success: { (tweets: [Tweet]) in
            self.tweets += tweets
            self.tweetsTableView.reloadData()
            self.isMoreDataLoading = false
            }, failure: { (error: Error) in
                print("Error:\(error.localizedDescription)")
        })
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetsTableView.bounds.size.height
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging) {
                isMoreDataLoading = true
                //loadMoreData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    func getSourceTweet() -> Tweet {
        return self.tweet
    }
    func composeFor(tweet: Tweet?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ComposeViewController") as! ComposeViewController
        if let sourceTweet = tweet {
            controller.tweet = sourceTweet
        }else {
            controller.tweet = nil
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
        //self.navigationController?.present(controller, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TweetDetailViewController") as! TweetDetailViewController
        controller.tweet = tweets[indexPath.row]
        controller.composer = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetsTableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet
        cell.composer = self
        return cell
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

