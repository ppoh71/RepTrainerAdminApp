//
//  FileOps.swift
//  PromptNodes
//
//  Created by Peter Pohlmann on 29/01/2023.
//

import Foundation
import AVFoundation
import UIKit
import Compression
import ZIPFoundation 

enum ImageType {
  case jpg
  case png

  var extensionString: String {
    switch self {
    case .jpg:
      return ".jpg"
    case .png:
      return ".png"
    }
  }
}


class FileOps{

  class func createDirectoriesCheck() {
    FileOps.createDirectory(directory: Constants.fixedThumbDir)
    FileOps.createDirectory(directory: Constants.fixedDir)
    FileOps.createDirectory(directory: Constants.originalDir)
    FileOps.createDirectory(directory: Constants.savedJsonDir)
  }

  /// Create Directory
  /// - Parameter directory: Directory to create String
  class func createDirectory(directory: String) {
    let directoryURL = Constants.documentsUrl.appendingPathComponent(directory)
    let isDirectory = directoryURL.hasDirectoryPath

    guard !isDirectory else {
      return
    }

    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]

    if let docURL = URL(string: documentsDirectory) {
      let dataPath = docURL.appendingPathComponent(directory)
      if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
        do {
          try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
          print("Created Direcroty", dataPath.absoluteString)
        } catch {
          print(error.localizedDescription);
        }
      }
    }
  }

  /// Create a thumbnail form a given UIImage
  /// - Parameter image: UIimage
  /// - Returns: Thumbnail UIimage
  class func resizeImage(image: UIImage, maxPixelSize: Int) -> UIImage? {
    var thumbnail: UIImage? = nil
    if let imageData = image.jpegData(compressionQuality: 0.9) as CFData?{
      let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: maxPixelSize] as CFDictionary

      if let source = CGImageSourceCreateWithData(imageData, nil) {
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        thumbnail = UIImage(cgImage: imageReference)
      }
    }
    return thumbnail
  }


  class func getImageFromLocalURL(url: URL) -> UIImage? {
    if let data = try? Data(contentsOf: url) {
      if let image = UIImage(data: data) {
        return image
      } else {return nil}
    } else {return nil }
  }

  // MARK: Read Files in Dir

  /// Read all files inside a Dirctory
  /// - Parameter directory: Dirctory String
  class func readAllFilesInDir(directory: String) {
    let documentsURL = Constants.documentsUrl.appendingPathComponent(directory)
    print("read dir \(documentsURL)")
    do {
      let dirs = try Constants.fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
      print("Directory has \(dirs.count) files")
      print(dirs)
    } catch {
      print("Error readAllFilesInDir \(documentsURL.path): \(error.localizedDescription)")
    }
  }

  class func readAllFilesInURL(directoryURL: URL) {
   // print("Try read dir \(directoryURL)")

    do {
      let dirs  = try Constants.fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
      print(dirs)
    } catch {
      print("Error readAllFilesInDir \(directoryURL.path): \(error.localizedDescription)")
    }
  }

  // MARK: Delete all Files

  /// Delete all Files from given Director
  /// - Parameter directory: Directory String
  class func deleteAllFilesFromFolder(directory: URL) {
    let fileManager = Constants.fileManager
    do {
      let url = directory
      if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil) {
        while let fileURL = enumerator.nextObject() as? URL {
          try fileManager.removeItem(at: fileURL)
        }
      }
    }  catch  {
      print(error)
    }
  }

  class func getFileURLsInDirectory(directory: URL) -> [URL] {
    let fileManager = Constants.fileManager
    var urls:[URL] = [URL]()

    if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) {
      while let fileURL = enumerator.nextObject() as? URL {
        urls.append(fileURL)
      }
    }
    return urls
  }

  // MARK: Save to Dir

  /// Save a given UIImage to a given Directory as JPG
  /// - Parameter image: The UIImage
  /// - Parameter imageName: The Filename (without Extension)
  /// - Parameter directory: The Directory String
  class func saveImageToDirectory(image: UIImage, imageNameRaw: String, imagetType: ImageType,  directory: URL) -> Bool {
    var _data: Data? = nil

    var imageName = ""
    switch imagetType {
    case .jpg:
      _data = image.jpegData(compressionQuality: 0.99)
      imageName = imageNameRaw + ".jpg"
    case .png:
      _data = image.pngData()
      imageName = imageNameRaw + ".png"
    }

    guard let data = _data else {print("G. save img"); return false}

    do {
      try data.write(to: directory.appendingPathComponent(imageName))
      print("saved in \(directory.appendingPathComponent(imageName))")
      return true
    } catch {
      print("save in dir error", error)
      return false
    }
  }

  // MARK: Delete File

  class func deleteFile(fileURL: URL) {
    do {
      try  Constants.fileManager.removeItem(at: fileURL)
      print("File deleted !!")
    } catch  {
      print("File deleted failed")
    }
  }


  // MARK: Delete Directory
  class func deleteDirectory(url: URL) {
    let fileManager = Constants.fileManager
    do{
      try fileManager.removeItem(atPath : url.path)
      print("Deleted Dir", url.path)
    } catch {
      print("error deleting dir")
    }
  }

  // MARK: JSON

  class func createFixJson(fixJson: FixJson) {
    /// create json file
    var jsonString: String?

    do {
      let jsonData = try JSONEncoder().encode(fixJson)
      jsonString = String(data: jsonData, encoding: .utf8)!
    } catch let error as NSError {
      print("Array to JSON conversion failed: \(error.localizedDescription)")
    }

    guard let _jsonString = jsonString else {print("G. json conveert "); return}

    let jsonFilePath = MediaManager.dirJson.appendingPathComponent("\(fixJson.id).json")

    do {
      try _jsonString.write(to: jsonFilePath, atomically: true, encoding: .utf8)

      print("------------JSON Created")
      //readAllJSONfromDir()

    } catch {
      print("Couldn't write to file: \(error.localizedDescription)")
    }
  }


  /// Get an array with all JOSN urls from
  /// the local models library.
  /// Each JOSn is one 3d model
  ///
  /// - Returns: url array to json files
  class func readAllJSONfromDir() -> [URL] {
    let allFiles = FileOps.getFileURLsInDirectory(directory: MediaManager.dirJson)
    var allJsonURL = [URL]()

    _ = allFiles.map{ url in
      if url.lastPathComponent.fileExtension() == "json" {
        allJsonURL.append(url)
      }
    }
    print(allJsonURL)
    return allJsonURL
  }

 class func getFixJson(url: URL) -> FixJson? {
    var fix: FixJson? = nil

    if let data = try? Data(contentsOf: url) {
      let decoder = JSONDecoder()
      if let newJson = try? decoder.decode(FixJson.self, from: data) {
        fix = newJson
      }
    }
    return fix
  }

  class func getFixJsonById(id: String) -> FixJson? {
    let jsonUrl = MediaManager.dirJson.appendingPathComponent("\(id).json")

    var fix: FixJson? = nil

    if let data = try? Data(contentsOf: jsonUrl) {
      let decoder = JSONDecoder()
      if let newJson = try? decoder.decode(FixJson.self, from: data) {
        fix = newJson
      }
    }
    return fix
  }

  /// Sort array of urls  by creation date
  /// - Parameter urls: urls description
  /// - Returns: sorted array
  class func sortURLsByCreationDate(urls: [URL]) -> [URL] {

    let sortedArray = urls.sorted(by: {
      if let time1 =  $0.creationDate?.timestamp(), let time2 = $1.creationDate?.timestamp() {
        return time1 > time2
      } else {
        return false
      }
    })

    return sortedArray
  }

  class func downloadImage(from url: URL) async throws -> UIImage? {
    let (data, response) = try await URLSession.shared.data(from: url)

    print("Start image download 1")
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      print("Start image download 2")
      //throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
      return nil
    }

    print("Start image download 3")
    if let image = UIImage(data: data) {
      print("Start image download 4")
      return image
    } else {
      print("Start image download 5")
      return nil
      //throw NSError(domain: "Data could not be converted to UIImage", code: 1, userInfo: nil)
    }
  }

  class func createZipFromImages(images: [UIImage], zipFileName: String) throws -> URL? {
    // Get the URL of the temporary directory
    let fileManager = FileManager.default
    let tempDirectoryURL = fileManager.temporaryDirectory

    // Create a unique folder in the temp directory to hold the images
    let folderURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString, isDirectory: true)
    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)

    // Save each image as a JPEG file in the folder
    for (index, image) in images.enumerated() {
      let imageData = image.jpegData(compressionQuality: 0.8) // Convert image to Data
      let imageFileName = "image_\(index + 1).jpg" // Create a unique file name for each image
      let fileURL = folderURL.appendingPathComponent(imageFileName)
      try imageData?.write(to: fileURL) // Save image to the folder
    }

    // Create a ZIP file URL in the temporary directory
    let zipFileURL = tempDirectoryURL.appendingPathComponent("\(zipFileName).zip")

    // Check if the ZIP file already exists and delete it if it does
    if fileManager.fileExists(atPath: zipFileURL.path) {
      try fileManager.removeItem(at: zipFileURL) // Remove existing ZIP file
    }

    // Zip the folder containing the images
    try fileManager.zipItem(at: folderURL, to: zipFileURL)

    // Optionally, delete the temporary folder containing the images
    try fileManager.removeItem(at: folderURL)

    print("ZIP file created: \(zipFileURL.path)")

    return zipFileURL // Return the URL of the created ZIP file
  }


}
