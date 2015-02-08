//
//  FeedTableViewController.swift
//  RSSReader
//
//  Created by Fahir on 2/8/15.
//  Copyright (c) 2015 Fahir. All rights reserved.
//

import UIKit
import CoreData

class FeedTableViewController: UITableViewController, MWFeedParserDelegate, SideBarDelegate {
    
    var context: NSManagedObjectContext!;
    
    var feedItems = [MWFeedItem]();
    
    var sideBar = SideBar();
    
    var feeds = [Feed]();
    var feedNames = [String]();
    
    func loadFeeds() {
        
        feedNames = [String]();
        feedNames.append("Add Feed");
        
        var request = NSFetchRequest(entityName: "Feed")
        
        var err: NSError?;
        feeds = context.executeFetchRequest(request, error: &err) as [Feed];
        
        if feeds.count > 0 {
        
            for feed in feeds {
                feedNames.append(feed.name);
            }
            
        }
        
        sideBar = SideBar(sourceView: self.navigationController!.view, menuItems: feedNames);
        sideBar.delegate = self;
        
    }
    
    func requestFeed(stringURL: String?) {
        
        if(stringURL == nil) {
            var url = NSURL(string: "http://feeds.reuters.com/reuters/businessNews");
            var feedParser = MWFeedParser(feedURL: url);
            feedParser.delegate = self;
            feedParser.parse();
        } else {
            var url = NSURL(string: stringURL!);
            var feedParser = MWFeedParser(feedURL: url);
            feedParser.delegate = self;
            feedParser.parse();
        }
        
    }
    
    // MARK: - FEED PARSER DELEGATE
    
    func feedParserDidStart(parser: MWFeedParser!) {
        feedItems = [MWFeedItem]();
    }
    
    func feedParserDidFinish(parser: MWFeedParser!) {
        self.tableView.reloadData();
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
    //    println(info);
        self.title = info.title;
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        feedItems.append(item);
    }
    
    // MARK: - SIDE BAR DELEGATE
    func sideBarDidSelectMenuButtonAtIndex(index: Int) {
        if index == 0 {
            
            var alert = UIAlertController(title: "Add Feed", message: "Enter Feed Name and URL", preferredStyle: .Alert);
            
            var save = UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                
                var name = alert.textFields![0] as UITextField;
                var URL = alert.textFields![1] as UITextField;
                
                if (name.text != "" && URL.text != "") {
                    
                    var feed = NSEntityDescription.insertNewObjectForEntityForName("Feed", inManagedObjectContext: self.context) as Feed
                    
                    feed.name = name.text;
                    feed.url = URL.text;
                    
                    var err: NSError?;
                    self.context.save(&err);
                    
                    if(err != nil) {
                        println("Problem while saving Feed URL: \(err)" );
                    }
                    
                    self.loadFeeds();
                    
                }
                
                
            })
            
            var cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
            
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
                textField.placeholder = "Feed Name";
            });
            
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
                textField.placeholder = "Feed URL";
            });
            
            alert.addAction(save);
            alert.addAction(cancel);
            
            presentViewController(alert, animated: true, completion: nil);
            
        } else {
            
            var request = NSFetchRequest(entityName: "Feed");
            var err: NSError?;
            var items = self.context.executeFetchRequest(request, error: &err) as [Feed];
            
            if(err != nil) {
                println("Problem loading feeds \(err)");
            }
            
            // subtracting 1 from the index because our first item is our Add Feed string
            requestFeed(items[index - 1].url);
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFeeds();
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        requestFeed(nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return feedItems.count;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        var item = feedItems[indexPath.row] as MWFeedItem;
        cell.textLabel?.text = item.title;

        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = feedItems[indexPath.row] as MWFeedItem;
        
        let browser = KINWebBrowserViewController();
        let url = NSURL(string: item.link);
        
        browser.loadURL(url);
        
        self.navigationController?.pushViewController(browser, animated: true);
        
    }

}




























