//
//  ObserverModel+Persist.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 17/05/2024.
//

import Foundation
import SwiftUI
import FirebaseAppCheck

extension ObserverModel {


  func readSavedFixes() {
    var tempSavedFixes = [FixJson]() /// reset
    let allJson = FileOps.readAllJSONfromDir()

    /// sort by date
    let sortedFileURLs = allJson.sorted { (url1, url2) -> Bool in
      guard let date1 = url1.creationDate, let date2 = url2.creationDate else {
        return false
      }
      return date1 > date2
    }

    for url in sortedFileURLs {
      print("get FIX.....XXX")
      if let newFixJosn = FileOps.getFixJson(url: url) {
        print("get FIX.....\(newFixJosn.fixURL)")
        tempSavedFixes.append(newFixJosn)
      }
    }

    savedFixes = tempSavedFixes
    checkForFailedRequests()
  }

//  func persistFixRequest(urlString: String) {
//    // save json with fix info
//    let newJson = FixJson(id: fixModel.requestId, fixURL: urlString, prompt: fixModel.prompt)
//    FileOps.createFixJson(fixJson: newJson)
//  }

  func persistSuccessRequest(id: String, urlString: String, image: UIImage) {
    // save json with fix info
    var newJson = FixJson(id: id, fixURL: urlString, prompt: fixModel.prompt)
    newJson.size = image.getFileSizeInMB()
    newJson.dimenson = image.dimensions
    newJson.fileType = image.imageType
    FileOps.createFixJson(fixJson: newJson)

    generateThumbnail(requestId: id, fixUrlString: urlString, fixedImage: image)
  }

  func generateThumbnail(requestId: String, fixUrlString: String?, fixedImage: UIImage?) {

   // guard let fixUrl = self.fixModel.fixedUrl, let fixImage = self.fixModel.fixedimage else {print("G. persist"); return}
    
    guard let fixUrl = fixUrlString, let fixImage = fixedImage else {print("G. persist"); return}

    // save thumbnail
    if let thumbnail = FileOps.resizeImage(image: fixImage, maxPixelSize: 300) {
      let _ = FileOps.saveImageToDirectory(image: thumbnail, imageNameRaw: requestId, imagetType: .jpg, directory: MediaManager.dirFixedThumb)
      print("---------------Thumbnail ")
      FileOps.readAllFilesInURL(directoryURL: MediaManager.dirFixedThumb)
    }

    // save fix
      let _ = FileOps.saveImageToDirectory(image: fixImage, imageNameRaw: requestId, imagetType: .jpg, directory: MediaManager.dirFixed)
      print("---------------Saved Fixed ")
      FileOps.readAllFilesInURL(directoryURL: MediaManager.dirFixed)
  }

  func checkForFailedRequests() {

    /// loop through fixes
    /// if no url, check firebase
    /// if ound image, download
    /// save thumbail
    /// save new json
    /// reload

    for fix in savedFixes {

      if fix.fixURL.isEmpty {
        
        self.getRequestOutput(requestId: fix.id, completion: { (success, output) in
          print("Get putput get Sucess: \(success) ")
          print("Get putput get output: \(output) ")

          guard success, let fixUrlString = output.output.first else {print("Guard checl failed"); return }
          guard let fixURL = URL(string: fixUrlString) else {print("Guard checl failed 2"); return }

          print("######### start failed")
          self.getFailedImage(fixJson: fix, fixURL: fixURL)

        })

      }
    }
  }

  func getFailedImage(fixJson: FixJson, fixURL: URL) {
    print("######### start failed before task")
    Task {
      do {

        print("######### start failed do task")
        if let image = try await FileOps.downloadImage(from: fixURL) {

          print("######### start failed dowmload image")
          generateThumbnail(requestId: fixJson.id, fixUrlString: fixURL.absoluteString, fixedImage: image)

          /// resave json
          var newJson = fixJson
          newJson.fixURL = fixURL.absoluteString
          newJson.size = image.getFileSizeInMB()
          newJson.dimenson = image.dimensions
          newJson.fileType = image.imageType

          FileOps.createFixJson(fixJson: newJson)

          let allJsons = FileOps.readAllJSONfromDir()
          print("######### start failed json saved")

          readSavedFixes()

        }

      } catch {
        print(error.localizedDescription)
      }
    }
  }

}
