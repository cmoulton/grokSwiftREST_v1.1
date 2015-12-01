//
//  File.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2015-12-01.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class File: ResponseJSONObjectSerializable {
  var filename: String?
  var raw_url: String?
  
  required init?(json: JSON) {
    self.filename = json["filename"].string
    self.raw_url = json["raw_url"].string
  }
}