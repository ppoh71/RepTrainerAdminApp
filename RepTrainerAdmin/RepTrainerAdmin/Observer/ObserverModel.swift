//
//  ObserverModel.swift
//  AI Art Prompts
//
//  Created by Peter Pohlmann on 07/12/2022.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreTransferable
import Firebase
import UIKit

enum NavigationItem {
  case none
  case welcome
  case home
  case fix
  case savedFixes
  case settings
  // Add more cases for different navigation paths as needed
}

@MainActor
class ObserverModel: ObservableObject {
  let db = Firestore.firestore()
  var appConfig = AppConfig()

  var networkTaskGetImagePrompt: Task<Void, Error>? = nil
  var networkTaskGetImage: Task<Void, Error>? = nil

 // @Published var isFixNavigation: Bool = false
  @Published var path = NavigationPath()
  @Published var currentPath: NavigationItem = NavigationItem.home

  /// Replciate Trainer
  @Published var trainerType: TrainerType = .family
  @Published var selectedDemoModel: String = ""

  /// Purchase
  @Published var showPaywall: Bool = false
  @Published var purchasePrice: String = "€7,99"
  @Published var tokenStartCount: Int = 0
  @Published var showSubscription: Bool = false
  @Published var showPromptEditor: Bool = false

  @Published var savedFixes: [FixJson] = [FixJson]()
  @Published var homeDisplayFixType: FixTypes = .eleven

  @Published var creativity: Double = Constants.creativity
  @Published var resemblance: Double = Constants.resemblance
  @Published var scale: Double = Constants.scale
  @Published var textPrompt: String = ""

  @Published var fixInProgressText: String = "Fixing Photo"
  @Published var errorMessage: String = ""

  @Published var loadingPhoto: Bool = false
  @Published var progressFix: CGFloat = 0
  @Published var selectedFix: FixTypes = .none
  @Published var fixAction: FixAction = .none
  @Published var fixModel = FixModel(requestId: "", userId: "", originalImage: UIImage(named: "flamingo") ?? UIImage(), fixedimage: UIImage(), fixedUrl: "https://replicate.delivery/pbxt/pdV2WXZDuyKLNJsiVOWSheoflAgoFRYbfuvlLK1UnbHQWImlA/1337-d2ba1eb4-0f13-11ef-ac52-36bd68c515e6.png", prompt: "")
  @Published private(set) var imageState: ImageState = .empty
  @Published var imageSelection: PhotosPickerItem? = nil {
    didSet {
      print("did set image selection")
      self.selectedFix = .none
      if let imageSelection {
        let progress = loadTransferable(from: imageSelection)
        imageState = .loading(progress)
      } else {
        imageState = .empty
      }
    }
  }
}

extension ObserverModel {

  func startup() {
    FileOps.createDirectoriesCheck()
  }

  func navigateToPath(navigatoTo: NavigationItem) {
    DispatchQueue.main.async {
      self.path.append(navigatoTo)
    }
  }


  func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
    
    DispatchQueue.main.async {
      self.loadingPhoto = true
    }

    return imageSelection.loadTransferable(type: PickerImage.self) { result in


      print("load tranferable finish")

      DispatchQueue.main.async {
        self.loadingPhoto = false

        guard imageSelection == self.imageSelection else {
          print("Failed to get the selected item.")
          return
        }
        switch result {
        case .success(let pickerImage?):
          self.fixAction = .imageSelected
          self.imageState = .success(pickerImage.uiImage)
          self.setNewFixModelForNewImage(originalImage: pickerImage.uiImage)
          self.currentPath = .fix
        case .success(nil):
          self.fixAction = .none
          self.imageState = .empty
          self.currentPath = .fix
          self.selectedFix = .none
        case .failure(let error):
          self.fixAction = .imageLoadFailure
          self.imageState = .failure(error)
          self.currentPath = .fix
        }
      }
    }
  }

  func setNewFixModelForNewImage(originalImage: UIImage) {

    /// set fix model
    guard let userId = Utils.getUserId() else { return }
    let requestId = UUID().uuidString

    let newFixModel = FixModel(requestId: requestId, userId: userId, originalImage: originalImage, prompt: "")
    fixModel = newFixModel
  }


  func startNewRequest() {
    networkTaskGetImagePrompt?.cancel()
    fixAction = .none
    self.fixModel = FixModel(requestId: "", userId: "", originalImage: UIImage(), fixedimage: UIImage(), fixedUrl: "", prompt: "")
  }

  func startRequest() {

    guard !fixModel.requestId.isEmpty && !fixModel.userId.isEmpty else { return }
    
    self.fixAction = .fixInProgress
    triggerHapticFeedback()

    /// create and start the copy request
    DispatchQueue.global(qos: .background).async {

      if let resizedImage = FileOps.resizeImage(image: self.fixModel.originalImage, maxPixelSize: 1024), let jpegData = resizedImage.jpegData(compressionQuality: 0.85) {
        let mimeType = "image/jpeg"
        let imageString = jpegData.uriEncoded(mimeType: mimeType)
        let newRequest = RequestImagePromptModel(userId:  self.fixModel.userId, requestId: self.fixModel.requestId, image: imageString, prompt: self.textPrompt)

        _ = Task {
          await self.generatePromptRequest(requestModel: newRequest)
        }
      } else {
        self.fixAction = .fixTimeOut
      }

    }
  }

  /// Create replicate request, resize the original image, get image datd and write uriExcnode for the request
  /// - Parameters:
  ///   - image: uiimage
  ///   - userId: the userid
  ///   - requestId: the request id
  /// - Returns: replicate model
  func requestFixModel(image: UIImage, userId: String, requestId: String) -> RequestImagePromptModel? {
    
    print("Start image encode 1")
    // handel image
    guard let resizedImage = FileOps.resizeImage(image: image, maxPixelSize: 1200) else {return nil}
    print("Start image encode 2")
    guard let jpegData = resizedImage.jpegData(compressionQuality: 1.0) else {return nil}
    let mimeType = "image/jpeg"
    print("Start image encode 3")
    let imageString = jpegData.uriEncoded(mimeType: mimeType)
    print("Start image encode 4")
    /// create model
    let newReplicate = RequestImagePromptModel(userId: userId, requestId: requestId, image: imageString, prompt: self.textPrompt)
    print("Start image encode 5")
    return newReplicate
  }

  func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .soft)
    generator.prepare()
    generator.impactOccurred()
  }

}



