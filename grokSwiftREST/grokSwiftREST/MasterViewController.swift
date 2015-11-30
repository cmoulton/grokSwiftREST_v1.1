//
//  MasterViewController.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2015-10-20.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit
import PINRemoteImage
import SafariServices

class MasterViewController: UITableViewController, LoginViewDelegate, SFSafariViewControllerDelegate {
  
  var detailViewController: DetailViewController? = nil
  var gists = [Gist]()
  var nextPageURLString: String?
  var isLoading = false
  var dateFormatter = NSDateFormatter()
  var safariViewController: SFSafariViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem()
    
    let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
    self.navigationItem.rightBarButtonItem = addButton
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
    
    // add refresh control for pull to refresh
    if (self.refreshControl == nil) {
      self.refreshControl = UIRefreshControl()
      self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
      self.refreshControl?.addTarget(self, action: "refresh:",
        forControlEvents: UIControlEvents.ValueChanged)
      self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
      self.dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
    }
  }
  
  func loadGists(urlToLoad: String?) {
    self.isLoading = true
    GitHubAPIManager.sharedInstance.getMyStarredGists(urlToLoad) {
      (result, nextPage) in
      self.isLoading = false
      self.nextPageURLString = nextPage
      
      // tell refresh control it can stop showing up now
      if self.refreshControl != nil && self.refreshControl!.refreshing {
        self.refreshControl?.endRefreshing()
      }
    
      guard result.error == nil else {
        print(result.error)
        // TODO: display error
        return
      }
    
      if let fetchedGists = result.value {
        if self.nextPageURLString != nil {
          self.gists += fetchedGists
        } else {
          self.gists = fetchedGists
        }
      }
      
      // update "last updated" title for refresh control
      let now = NSDate()
      let updateString = "Last Updated at " + self.dateFormatter.stringFromDate(now)
      self.refreshControl?.attributedTitle = NSAttributedString(string: updateString)
      
      self.tableView.reloadData()
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    let defaults = NSUserDefaults.standardUserDefaults()
    if (!defaults.boolForKey("loadingOAuthToken")) {
      loadInitialData()
    }
  }
  
  func loadInitialData() {
    if (!GitHubAPIManager.sharedInstance.hasOAuthToken()) {
      showOAuthLoginView()
    } else {
      GitHubAPIManager.sharedInstance.printMyStarredGistsWithOAuth2()
    }
  }
  
  func showOAuthLoginView() {
    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    if let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController {
      loginVC.delegate = self
      self.presentViewController(loginVC, animated: true, completion: nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func insertNewObject(sender: AnyObject) {
    let alert = UIAlertController(title: "Not Implemented", message: "Can't create new gists yet, will implement later", preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let gist = gists[indexPath.row] as Gist
        if let detailViewController = (segue.destinationViewController as! UINavigationController).topViewController as? DetailViewController {
          detailViewController.detailItem = gist
          detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
          detailViewController.navigationItem.leftItemsSupplementBackButton = true
        }
      }
    }
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gists.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    let gist = gists[indexPath.row]
    cell.textLabel!.text = gist.description
    cell.detailTextLabel!.text = gist.ownerLogin
    cell.imageView?.image = nil
    
    // set cell.imageView to display image at gist.ownerAvatarURL
    if let urlString = gist.ownerAvatarURL, url = NSURL(string: urlString) {
      cell.imageView?.pin_setImageFromURL(url, placeholderImage:
      UIImage(named: "placeholder.png"))
    } else {
      cell.imageView?.image = UIImage(named: "placeholder.png")
    }
            
    // See if we need to load more gists
    let rowsToLoadFromBottom = 5;
    let rowsLoaded = gists.count
    if let nextPage = nextPageURLString {
      if (!isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
      self.loadGists(nextPage)
      }
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      gists.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array,
      // and add a new row to the table view.
    }
  }
  
  // MARK: - Pull to Refresh
  func refresh(sender:AnyObject) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setBool(false, forKey: "loadingOAuthToken")
    
    nextPageURLString = nil // so it doesn't try to append the results
    loadInitialData()
  }
  
  // MARK: - Login View Delegate
  func didTapLoginButton() {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setBool(true, forKey: "loadingOAuthToken")
    
    self.dismissViewControllerAnimated(false, completion: nil)
    
    if let authURL = GitHubAPIManager.sharedInstance.URLToStartOAuth2Login() {
      safariViewController = SFSafariViewController(URL: authURL)
      safariViewController?.delegate = self
      if let webViewController = safariViewController {
        self.presentViewController(webViewController, animated: true, completion: nil)
      }
    }
  }
  
  // MARK: - Safari View Controller Delegate
  func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
    // Detect not being able to load the OAuth URL
    if (!didLoadSuccessfully) {
      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setBool(false, forKey: "loadingOAuthToken")
      controller.dismissViewControllerAnimated(true, completion: nil)
    }
  }
}

