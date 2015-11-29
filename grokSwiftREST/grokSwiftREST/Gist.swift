//
//  Gist.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2015-11-29.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Gist: ResponseJSONObjectSerializable {
  var id: String?
  var description: String?
  var ownerLogin: String?
  var ownerAvatarURL: String?
  var url: String?
  
  required init(json: JSON) {
    self.description = json["description"].string
    self.id = json["id"].string
    self.ownerLogin = json["owner"]["login"].string
    self.ownerAvatarURL = json["owner"]["avatar_url"].string
    self.url = json["url"].string
  }
  
  required init() {
  }
}