//
//  CreateGistViewController.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2015-12-01.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import XLForm

class CreateGistViewController: XLFormViewController {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.initializeForm()
  }
  
  override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.initializeForm()
  }
  
  private func initializeForm() {
    ...
  }
}