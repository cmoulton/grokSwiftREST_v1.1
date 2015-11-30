//
//  AlamofireRequest+JSONSerializable.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2015-11-29.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Alamofire.Request {
  public func responseObject<T: ResponseJSONObjectSerializable>(completionHandler:
    Response<T, NSError> -> Void) -> Self {
      let serializer = ResponseSerializer<T, NSError> { request, response, data, error in
        guard error == nil else {
          return .Failure(error!)
        }
        guard let responseData = data else {
          let failureReason = "Object could not be serialized because input data was nil."
          let error = Error.errorWithCode(.DataSerializationFailed,
            failureReason: failureReason)
          return .Failure(error)
        }
        
        let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
        let result = JSONResponseSerializer.serializeResponse(request, response,
          responseData, error)
        
        switch result {
        case .Success(let value):
          let json = SwiftyJSON.JSON(value)
          if let object = T(json: json) {
            return .Success(object)
          } else {
            let failureReason = "Object could not be created from JSON."
            let error = Error.errorWithCode(.JSONSerializationFailed,
              failureReason: failureReason)
            return .Failure(error)
          }
        case .Failure(let error):
          return .Failure(error)
        }
      }
      
      return response(responseSerializer: serializer, completionHandler: completionHandler)
  }

  public func responseArray<T: ResponseJSONObjectSerializable>(completionHandler: Response<[T], NSError> -> Void) -> Self {
      let serializer = ResponseSerializer<[T], NSError> { request, response, data, error in
        guard error == nil else {
          return .Failure(error!)
        }
        guard let responseData = data else {
          let failureReason = "Array could not be serialized because input data was nil."
          let error = Error.errorWithCode(.DataSerializationFailed,
            failureReason: failureReason)
          return .Failure(error)
        }
        
        let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
        let result = JSONResponseSerializer.serializeResponse(request, response,
          responseData, error)
        
        switch result {
        case .Success(let value):
          let json = SwiftyJSON.JSON(value)
          var objects: [T] = []
          for (_, item) in json {
            if let object = T(json: item) {
              objects.append(object)
            }
          }
          return .Success(objects)
        case .Failure(let error):
          return .Failure(error)
        }
      }
      
      return response(responseSerializer: serializer, completionHandler: completionHandler)
  }
  
  public func isUnauthorized(completionHandler: Response<Bool, NSError> -> Void) -> Self {
    let serializer = ResponseSerializer<Bool, NSError> { request, response, data, error in
      if let code = response?.statusCode {
        return .Success(code == 401)
      }
      let error = Error.errorWithCode(.StatusCodeValidationFailed, failureReason:
        "No status code received")
      return .Failure(error)
    }
    
    return response(responseSerializer: serializer, completionHandler: completionHandler)
  }
}