//
//  GitHubAPIManager.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2015-11-29.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GitHubAPIManager {
  static let sharedInstance = GitHubAPIManager()
  var alamofireManager: Alamofire.Manager
  
  init () {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    alamofireManager = Alamofire.Manager(configuration: configuration)
  }

  func printPublicGists() -> Void {
    alamofireManager.request(GistRouter.GetPublic())
    .responseString { response in
      if let receivedString = response.result.value {
        print(receivedString)
      }
    }
  }
  
  func getPublicGists(completionHandler: (Result<[Gist], NSError>) -> Void) {
    alamofireManager.request(.GET, "https://api.github.com/gists/public")
    .responseArray { (response:Response<[Gist], NSError>) in
      completionHandler(response.result)
    }
  }
}