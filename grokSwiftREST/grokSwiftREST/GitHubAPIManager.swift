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

  func printPublicGists() -> Void {
    Alamofire.request(GistRouter.GetPublic())
    .responseString { response in
      if let receivedString = response.result.value {
        print(receivedString)
      }
    }
  }
  
  func getPublicGists(completionHandler: (Result<[Gist], NSError>) -> Void) {
      Alamofire.request(.GET, "https://api.github.com/gists/public")
      .responseArray { (request, response, result: Result<[Gist], NSError>) in
        completionHandler(response.result)
      }
  }
}