//
//  Constants.swift
//  PromptNodes
//
//  Created by Peter Pohlmann on 30/01/2023.
//

import UIKit
import SwiftUI

struct Constants {

  /// Filemanger
  static let fileManager = FileManager.default
  static var documentsUrl: URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }

  /// Dirs
  static let fixedThumbDir = "fixedThumbnail"
  static let fixedDir = "fixedImage"
  static let originalDir = "originalImage"
  static let savedJsonDir = "savedJson"
  static let savedImagesDir = "savedImages"

  /// Sizes
  static let fixItemSize: CGFloat = 120
  static let widthPadding: CGFloat = 20
  static let circleSizeSubstract: CGFloat = 90
  static let heightMultiplier: CGFloat = 1.2

  static let creativity: Double = 0.2
  static let resemblance: Double = 2.8
  static let scale: Double = 2
  static let textPrompt: String = ""
}
