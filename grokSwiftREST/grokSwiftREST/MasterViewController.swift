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
import Alamofire
import BRYXBanner

class MasterViewController: UITableViewController, LoginViewDelegate, SFSafariViewControllerDelegate {
  
  var detailViewController: DetailViewController? = nil
  var gists = [Gist]()
  var nextPageURLString: String?
  var isLoading = false
  var dateFormatter = NSDateFormatter()
  var safariViewController: SFSafariViewController?
  var notConnectedBanner: Banner?
  @IBOutlet weak var gistSegmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
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
      self.refreshControl?.addTarget(self, action: #selector(MasterViewController.refresh(_:)),
        forControlEvents: UIControlEvents.ValueChanged)
      self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
      self.dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    if let existingBanner = self.notConnectedBanner {
      existingBanner.dismiss()
    }
    super.viewWillDisappear(animated)
  }
  
  func loadGists(urlToLoad: String?) {
    self.isLoading = true
    let completionHandler: (Result<[Gist], NSError>, String?) -> Void =
    { (result, nextPage) in
      self.isLoading = false
      self.nextPageURLString = nextPage
      
      // tell refresh control it can stop showing up now
      if self.refreshControl != nil && self.refreshControl!.refreshing {
        self.refreshControl?.endRefreshing()
      }
      
      guard result.error == nil else {
        print(result.error)
        self.nextPageURLString = nil
        
        self.isLoading = false
        if let error = result.error {
          if error.domain == NSURLErrorDomain {
            if error.code == NSURLErrorUserAuthenticationRequired {
              self.showOAuthLoginView()
            } else if error.code == NSURLErrorNotConnectedToInternet {
              let path:Path
              if self.gistSegmentedControl.selectedSegmentIndex == 0 {
                path = .Public
              } else if self.gistSegmentedControl.selectedSegmentIndex == 1 {
                path = .Starred
              } else {
                path = .MyGists
              }
              if let archived:[Gist] = PersistenceManager.loadArray(path) {
                self.gists = archived
              } else {
                self.gists = [] // don't have any saved gists
              }
              
              // show not connected error & tell em to try again when they do have a connection
              // check for existing banner
              if let existingBanner = self.notConnectedBanner {
                existingBanner.dismiss()
              }
              self.notConnectedBanner = Banner(title: "No Internet Connection",
                subtitle: "Could not load gists." +
                " Try again when you're connected to the internet",
                image: nil,
                backgroundColor: UIColor.redColor())
            }
            self.notConnectedBanner?.dismissesOnSwipe = true
            self.notConnectedBanner?.show(duration: nil)
          }
        }
        return
      }
      
      if let fetchedGists = result.value {
        if urlToLoad != nil {
          self.gists += fetchedGists
        } else {
          self.gists = fetchedGists
        }
      }
      
      let path:Path
      if self.gistSegmentedControl.selectedSegmentIndex == 0 {
        path = .Public
      } else if self.gistSegmentedControl.selectedSegmentIndex == 1 {
        path = .Starred
      } else {
        path = .MyGists
      }
      PersistenceManager.saveArray(self.gists, path: path)
      
      // update "last updated" title for refresh control
      let now = NSDate()
      let updateString = "Last Updated at " + self.dateFormatter.stringFromDate(now)
      self.refreshControl?.attributedTitle = NSAttributedString(string: updateString)
      
      self.tableView.reloadData()
    }
    
    switch gistSegmentedControl.selectedSegmentIndex {
    case 0:
      GitHubAPIManager.sharedInstance.getPublicGists(urlToLoad, completionHandler:
        completionHandler)
    case 1:
      GitHubAPIManager.sharedInstance.getMyStarredGists(urlToLoad, completionHandler:
        completionHandler)
    case 2:
      GitHubAPIManager.sharedInstance.getMyGists(urlToLoad, completionHandler:
        completionHandler)
    default:
      print("got an index that I didn't expect for selectedSegmentIndex")
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
    isLoading = true
    GitHubAPIManager.sharedInstance.OAuthTokenCompletionHandler = { (error) -> Void in
      self.safariViewController?.dismissViewControllerAnimated(true, completion: nil)
      if let error = error {
        print(error)
        self.isLoading = false
        if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
          // show not connected error & tell em to try again when they do have a connection
          // check for existing banner
          if let existingBanner = self.notConnectedBanner {
            existingBanner.dismiss()
          }
          self.notConnectedBanner = Banner(title: "No Internet Connection",
            subtitle: "Could not load gists. Try again when you're connected to the internet",
            image: nil,
            backgroundColor: UIColor.redColor())
          self.notConnectedBanner?.dismissesOnSwipe = true
          self.notConnectedBanner?.show(duration: nil)
        } else {
          // Something went wrong, try again
          self.showOAuthLoginView()
        }
      } else {
        self.loadGists(nil)
      }
    }
    
    if (!GitHubAPIManager.sharedInstance.hasOAuthToken()) {
      self.showOAuthLoginView()
    } else {
      loadGists(nil)
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
  
  // MARK: - Creation
  func insertNewObject(sender: AnyObject) {
    let createVC = CreateGistViewController(nibName: nil, bundle: nil)
    self.navigationController?.pushViewController(createVC, animated: true)
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let gist = gists[indexPath.row] as Gist
        if let detailViewController = (segue.destinationViewController as! UINavigationController).topViewController as? DetailViewController {
          detailViewController.gist = gist
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
    cell.textLabel!.text = gist.gistDescription
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
    // only allow editing my gists
    return gistSegmentedControl.selectedSegmentIndex == 2
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      if let id = gists[indexPath.row].id {
        let gistToDelete = gists.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        // delete from API
        GitHubAPIManager.sharedInstance.deleteGist(id, completionHandler: {
          (error) in
          print(error)
          if let _ = error {
            // Put it back
            self.gists.insert(gistToDelete, atIndex: indexPath.row)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
            // tell them it didn't work
            let alertController = UIAlertController(title: "Could not delete gist",
              message: "Sorry, your gist couldn't be deleted. Maybe GitHub is "
                + "down or you don't have an internet connection.",
              preferredStyle: .Alert)
            // add ok button
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            // show the alert
            self.presentViewController(alertController, animated:true, completion: nil)
          }
        })
      }
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
    } else {
      defaults.setBool(false, forKey: "loadingOAuthToken")
      if let completionHandler = GitHubAPIManager.sharedInstance.OAuthTokenCompletionHandler {
        let error = NSError(domain: GitHubAPIManager.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create an OAuth authorization URL", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
        completionHandler(error)
      }
    }
  }
  
  // MARK: - Safari View Controller Delegate
  func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
    // Detect not being able to load the OAuth URL
    if (!didLoadSuccessfully) {
      if let completionHandler = GitHubAPIManager.sharedInstance.OAuthTokenCompletionHandler {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: "No Internet Connection", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
        completionHandler(error)
      }
      controller.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  // MARK : - IBActions
  @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
    // only show add button for my gists
    if (gistSegmentedControl.selectedSegmentIndex == 2) {
      self.navigationItem.leftBarButtonItem = self.editButtonItem()
      let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self,
        action: #selector(MasterViewController.insertNewObject(_:)))
      self.navigationItem.rightBarButtonItem = addButton
    } else {
      self.navigationItem.leftBarButtonItem = nil
      self.navigationItem.rightBarButtonItem = nil
    }
    
    // clear gists so they can't get shown for the wrong list
    self.gists = [Gist]()
    self.tableView.reloadData()
    
    loadGists(nil)
  }
}

