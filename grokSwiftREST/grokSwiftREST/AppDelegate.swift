//
//  AppDelegate.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2015-10-20.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions:
    [NSObject: AnyObject]?) -> Bool {
      // Override point for customization after application launch.
      let splitViewController = self.window!.rootViewController as! UISplitViewController
      let navigationController = splitViewController.viewControllers[
        splitViewController.viewControllers.count-1] as! UINavigationController
      navigationController.topViewController!.navigationItem.leftBarButtonItem
        = splitViewController.displayModeButtonItem()
      splitViewController.delegate = self
      return true
  }
  
  func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
    GitHubAPIManager.sharedInstance.processOAuthStep1Response(url)
    return true
  }
  // MARK: - Split view
  
  func splitViewController(splitViewController: UISplitViewController,
    collapseSecondaryViewController secondaryViewController:UIViewController,
    ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
      guard let secondaryAsNavController = secondaryViewController as?
        UINavigationController else { return false }
      guard let topAsDetailController = secondaryAsNavController.topViewController as?
        DetailViewController else { return false }
      if topAsDetailController.detailItem == nil {
        // Return true to indicate that we have handled the collapse by doing nothing
        // the secondary controller will be discarded.
        return true
      }
      return false
  }
}
