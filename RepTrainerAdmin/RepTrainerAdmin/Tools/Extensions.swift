//
//  Extensions.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 11/03/2024.
//

import Foundation
import UIKit
import SwiftUI

extension String {
  func fileNameRaw() -> String {
    return NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent ?? ""
  }

  func fileExtension() -> String {
    return NSURL(fileURLWithPath: self).pathExtension ?? ""
  }

  func extractFileName() -> String? {
    // Decode the URL-encoded string (replace %2F with "/")
    let decodedString = self.replacingOccurrences(of: "%2F", with: "/")

    // Split the decoded string by '/' and get the last component, then remove query parameters
    guard let fileNameWithParams = decodedString.split(separator: "/").last else {
      return nil
    }

    // Remove query parameters like ?alt=media&token=...
    let fileName = fileNameWithParams.split(separator: "?").first

    return fileName.map { String($0) }
  }

}

// MARK: Extension URL
extension URL {

  var attributes: [FileAttributeKey : Any]? {
    do {
      return try FileManager.default.attributesOfItem(atPath: path)
    } catch let error as NSError {
      print("FileAttribute error: \(error)")
    }
    return nil
  }

  var fileSize: UInt64 {
    return attributes?[.size] as? UInt64 ?? UInt64(0)
  }

  var fileSizeString: String {
    return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
  }

  var creationDate: Date? {
    return attributes?[.creationDate] as? Date
  }

  var modificationDate: Date? {
    return attributes?[.modificationDate] as? Date
  }

  var fileExists: Bool {
    let path = self.path
    if (FileManager.default.fileExists(atPath: path))   {
      return true
    }else        {
      return false;
    }
  }
}

// MARK: Extension Date
extension Date {
  func timestamp() -> Int {
    return Int(self.timeIntervalSince1970 * 1000)
  }
}

extension Data {
  func uriEncoded(mimeType: String?) -> String {
    return "data:\(mimeType ?? "");base64,\(base64EncodedString())"
  }
}

extension UIImage {

  // Function to get the file size of the UIImage in MB
  func getFileSizeInMB() -> String{
    guard let imageData = self.jpegData(compressionQuality: 1.0) else {
      return ""
    }
    let sizeInBytes = Double(imageData.count)
    let sizeInMB = sizeInBytes / (1024 * 1024)
    return "\(String(format: "%.2f", sizeInMB)) MB"
  }

  // Function to get the dimensions of the UIImage
  var dimensions: String {
    return "\(Int(self.size.width))x\(Int(self.size.height))"
  }

  // Function to get the type of the UIImage (PNG or JPEG)
  var imageType: String {
    if let _ = self.jpegData(compressionQuality: 1.0) {
      return "JPEG"
    } 
    return ""
  }
}

extension Double {
  // Function to get the integer part of the double
  var asInteger: Int {
    return Int(self)
  }
}

