//
//  MediaManager.swift
//  PromptNodes
//
//  Created by Peter Pohlmann on 30/01/2023.
//

import Foundation
import UIKit

struct MediaStorage{
  let modiferThumbnail: URL
  let modifierLarge: URL
}

final class MediaManager{
  static let dirRoot = Constants.documentsUrl
  static let dirFixedThumb = Constants.documentsUrl.appendingPathComponent(Constants.fixedThumbDir)
  static let dirOriginal = Constants.documentsUrl.appendingPathComponent(Constants.originalDir)
  static let dirFixed = Constants.documentsUrl.appendingPathComponent(Constants.fixedDir)
  static let dirJson = Constants.documentsUrl.appendingPathComponent(Constants.savedJsonDir)

  /// getImageFromLocalURL
  /// - Parameter urlString
  /// - Returns: UIImage or nil
  class func getImageFromLocalURL(url: URL) -> UIImage? {
    if let data = try? Data(contentsOf: url) {
      if let image = UIImage(data: data) {
        return image
      } else {return nil}
    } else {return nil }
  }

  /// Create local urls where images are stored to look for
  class func getMediaStorageUrls(id: String) -> MediaStorage {

    /// filename
    let filename = id + ".jpg"

    // create the filepath
    let modiferThumbDir = Constants.fixedThumbDir + "/" + filename
    let modiferLargeDir = Constants.fixedDir + "/" + filename

    // create urls
    let modiferThumbURL = Constants.documentsUrl.appendingPathComponent(modiferThumbDir)
    let modiferLargeURL = Constants.documentsUrl.appendingPathComponent(modiferLargeDir)

    /// Create Storage URLS
    let storage = MediaStorage(modiferThumbnail: modiferThumbURL, modifierLarge: modiferLargeURL)
    return storage
  }


}
