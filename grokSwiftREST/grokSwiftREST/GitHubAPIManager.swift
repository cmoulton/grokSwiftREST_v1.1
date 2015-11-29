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
  
  func printMyStarredGistsWithBasicAuth() -> Void {
    Alamofire.request(GistRouter.GetPublic())
    .responseString { response in
      if let receivedString = response.result.value {
        print(receivedString)
      }
    }
  }
  
  func getGists(urlRequest: URLRequestConvertible, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
    alamofireManager.request(urlRequest)
      .validate()
      .responseArray { (response:Response<[Gist], NSError>) in
        guard response.result.error == nil,
        let gists = response.result.value else {
          print(response.result.error)
          completionHandler(response.result, nil)
          return
        }
        
        // need to figure out if this is the last page
        // check the link header, if present
        let next = self.getNextPageFromHeaders(response.response)
        completionHandler(.Success(gists), next)
    }
  }
  
  func getPublicGists(pageToLoad: String?, completionHandler: (Result<[Gist], NSError>, String?) -> Void) {
    if let urlString = pageToLoad {
      getGists(GistRouter.GetAtPath(urlString), completionHandler: completionHandler)
    } else {
      getGists(GistRouter.GetPublic(), completionHandler: completionHandler)
    }
  }
  
  func imageFromURLString(imageURLString: String, completionHandler:
    (UIImage?, NSError?) -> Void) {
    alamofireManager.request(.GET, imageURLString)
      .response { (request, response, data, error) in
      // use the generic response serializer that returns NSData
      if data == nil {
        completionHandler(nil, nil)
        return
      }
      let image = UIImage(data: data! as NSData)
      completionHandler(image, nil)
    }
  }
  
  private func getNextPageFromHeaders(response: NSHTTPURLResponse?) -> String? {
    if let linkHeader = response?.allHeaderFields["Link"] as? String {
      /* looks like:
      <https://api.github.com/user/20267/gists?page=2>; rel="next", <https://api.github.com/user/20267/gists?page=6>; rel="last"
      */
      // so split on "," then on  ";"
      let components = linkHeader.characters.split {$0 == ","}.map { String($0) }
      // now we have 2 lines like
      // '<https://api.github.com/user/20267/gists?page=2>; rel="next"'
      // So let's get the URL out of there:
      for item in components {
        // see if it's "next"
        let rangeOfNext = item.rangeOfString("rel=\"next\"", options: [])
          if rangeOfNext != nil {
          let rangeOfPaddedURL = item.rangeOfString("<(.*)>;",
          options: .RegularExpressionSearch)
          if let range = rangeOfPaddedURL {
            let nextURL = item.substringWithRange(range)
            // strip off the < and >;
            let startIndex = nextURL.startIndex.advancedBy(1)
            let endIndex = nextURL.endIndex.advancedBy(-2)
            let urlRange = startIndex..<endIndex
            return nextURL.substringWithRange(urlRange)
          }
        }
      }
    }
    return nil
  }
}