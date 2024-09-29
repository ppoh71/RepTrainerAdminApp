//
//  FixTypes.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 03/03/2024.
//

import Foundation
import SwiftUI

enum FixAction {
  case none
  case imageSelected
  case imageLoadFailure
  case fixSelected
  case fixInProgress
  case fixFinished
  case fixTimeOut
}

enum FixTypes: Codable{
  case none
  case one
  case two
  case three
  case four
  case five
  case six
  case seven
  case eight

  case nine
  case ten
  case eleven
  case twelve


  func getFixItemImages() -> (Image, Image) {
    switch self {
    case .none:
      return (Image(uiImage: UIImage()), Image(uiImage: UIImage()))
    case .one:
      return (Image("pods-1"), Image("pods-2"))
    case .two:
      return (Image("cosmetic-1"), Image("cosmetic-2"))
    case .three:
      return (Image("dog-1"), Image("dog-2"))
    case .four:
      return (Image("stock-1"), Image("stock-2"))
    case .five:
      return (Image("old-1"), Image("old-2"))
    case .six:
      return (Image("rat-1"), Image("rat-2"))
    case .seven:
      return (Image("van-1"), Image("van-2"))
    case .eight:
      return (Image("wom-1"), Image("wom-2"))
    case .nine:
      return (Image("couch-1"), Image("couch-2"))
    case .ten:
      return (Image("desk-1"), Image("desk-2"))
    case .eleven:
      return (Image("desk-1"), Image("desk-2"))
    case .twelve:
      return (Image("glass-1"), Image("glass-2"))
    }
  }

  func getFixSettings() -> (Double, Double) {
    switch self {
    case .none:
      return (0,0)
    case .one:
      return (0.8, 2.6)
    case .two:
      return (0.4, 2.6)
    case .three:
      return (0.6, 1.8)
    case .four:
      return (0.35, 2.9)
    case .five:
      return (0.37, 1.4)
    case .six:
      return (0.98, 2.5)
    case .seven:
      return (0.2, 2.8)
    case .eight:
      return (0.25, 2.9)
    case .nine:
      return (0.98, 2.5)
    case .ten:
      return (0.98, 2.5)
    case .eleven:
      return (0.98, 2.5)
    case .twelve:
      return (0.98, 2.5)
    }
  }
}

struct BubbleLoop: Hashable{
  let image: FixTypes
  let layoutLeft: Bool
  let test: String
}

struct FixModel{
  var requestId: String
  var userId: String
  var originalImage: UIImage
  var baseImage: UIImage?
  var baseImageUrl: String?
  var fixedimage: UIImage?
  var fixedUrl: String?
  var prompt: String
  

  func getFinalPrompt( withTrigger trigger: String, andAddition addition: String) -> String {
    let replacedText = self.prompt
      .replacingOccurrences(of: "###trigger###", with: trigger)
      .replacingOccurrences(of: "###addition###", with: addition)
    return replacedText
  }
}

struct FixGenerated {
  var id: String
  var fixType: FixTypes
  var originalImage: UIImage
  var fixedImage: UIImage
  var prompt: String
}

struct FixJson: Codable, Hashable {
  var id: String
  var fixURL: String
  var prompt: String
  var size: String = ""
  var dimenson: String = ""
  var fileType: String = ""

  func getThumbnailURL() -> URL {
    let imageName = self.id + ".jpg"
    let imageURL = MediaManager.dirFixedThumb.appendingPathComponent(imageName)
    return imageURL
  }

  func getFullImageURL() -> URL {
    let imageName = self.id + ".jpg"
    let imageURL = MediaManager.dirFixed.appendingPathComponent(imageName)
    return imageURL
  }

  func getThumbnail() -> UIImage? {
    let imageName = self.id + ".jpg"
    let imageURL = MediaManager.dirFixedThumb.appendingPathComponent(imageName)

    if let image = FileOps.getImageFromLocalURL(url: imageURL) {
      print("Thubnail: HAs")
      return image
    } else {
      print("Thubnail: HAs NOT")
      return nil
    }
  }

  /// how old is the josn file in seconds
  func howOld() -> Double {
    let jsonUrl = MediaManager.dirJson.appendingPathComponent("\(self.id).json")
    if let date = jsonUrl.creationDate {
      let currentDate = Date()
      let timeInterval = currentDate.timeIntervalSince(date)
      print("How old \(timeInterval)")
      return timeInterval
    } else {
      print("How old 0")
      return 0
    }
  }
}

/// Firebase output model for all request
///
struct RequestOutput: Codable {
  var output: [String]
}
