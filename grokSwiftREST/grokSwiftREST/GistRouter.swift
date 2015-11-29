//
//  GistRouter.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2015-11-29.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire

enum GistRouter: URLRequestConvertible {
  static let baseURLString:String = "https://api.github.com"
  
  case GetPublic() // GET https://api.github.com/gists/public
  case GetMyStarred() // GET https://api.github.com/gists/starred
  
  case GetAtPath(String) // GET at given path
  
  var URLRequest: NSMutableURLRequest {
    var method: Alamofire.Method {
    switch self {
      case .GetPublic:
        return .GET
      case .GetMyStarred:
        return .GET
      case .GetAtPath:
        return .GET
      }
    }
    
    let result: (path: String, parameters: [String: AnyObject]?) = {
      switch self {
      case .GetPublic:
        return ("/gists/public", nil)
      case .GetMyStarred:
        return ("/gists/starred", nil)
      case .GetAtPath(let path):
        let URL = NSURL(string: path)
        let relativePath = URL!.relativePath!
        return (relativePath, nil)
      }
    }()
    
    let URL = NSURL(string: GistRouter.baseURLString)!
    let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
    
    let encoding = Alamofire.ParameterEncoding.JSON
    let (encoded, _) = encoding.encode(URLRequest, parameters: result.parameters)
    
    encoded.HTTPMethod = method.rawValue
    
    return encoded
  }
}
