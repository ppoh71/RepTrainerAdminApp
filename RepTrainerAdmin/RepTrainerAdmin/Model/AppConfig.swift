//
//  Settinge.swift
//  AI Art Prompts
//
//  Created by Peter Pohlmann on 13/12/2022.
//

import Foundation
import SwiftUI

struct AppConfig: Codable {
  var freeFixes: Int = 0
  var websitePrivacy: String = ""
  var websiteShare: String = ""
  var websiteSupport: String = ""
  var websiteToc: String = ""
}

final class AppSettings{

  class func getpromptFontSize() -> Font {
    return Font.title.weight(.heavy)
  }

  class func getpromptSmallFontSize() -> Font {
    return Font.body.weight(.heavy)
  }
}

