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
  case savedPrompts
  case createTraining
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
  @Published var selectedDemoModelList: [SelectedDemoModel] = [SelectedDemoModel]()
  @Published var selectedDemoModel: SelectedDemoModel = SelectedDemoModel(id: UUID(), desc: "", modelName: "")
  @Published var createdPromptsList: [CreatedPrompt] = []
  @Published var selectedOptions: [String] = []
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

  @Published var isLoading: Bool = false

  // Create Trainint
  @Published var newTrainging: NewTrainingModel = NewTrainingModel()
  @Published var newTraingingSelctedImages: [UIImage] = []
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
    guard let userId = Utils.getUserId() else { return }
    let requestId = UUID().uuidString
    let newFixModel = FixModel(requestId: requestId, userId: userId, originalImage: originalImage, prompt: "")
    fixModel = newFixModel
    selectedOptions = []
  }

  func startNewRequest() {
    networkTaskGetImagePrompt?.cancel()
    fixAction = .none
    self.selectedOptions = []
    self.fixModel = FixModel(requestId: "", userId: "", originalImage: UIImage(), fixedimage: UIImage(), fixedUrl: "", prompt: "")
  }

  func startRequest() {
    guard !fixModel.requestId.isEmpty && !fixModel.userId.isEmpty else { return }
    selectedOptions = []

    fixAction = .fixInProgress
    triggerHapticFeedback()

    /// create and start the copy request
      if let resizedImage = FileOps.resizeImage(image: self.fixModel.originalImage, maxPixelSize: 1600), let jpegData = resizedImage.jpegData(compressionQuality: 0.85) {
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

  func startNewPromptRequest(prompt: String) {
    networkTaskGetImagePrompt?.cancel()

    self.fixAction = .fixInProgress
    
    guard let userId = Utils.getUserId() else { return }
    let requestId = UUID().uuidString
    let newFixModel = FixModel(requestId: requestId, userId: userId, originalImage: UIImage(), prompt: prompt)
    fixModel = newFixModel
    self.currentPath = .fix
    self.selectedOptions = []
    startBaseImageFromPromptGeneration()
  }

  /// Create replicate request, resize the original image, get image datd and write uriExcnode for the request
  func requestResponseModel(image: UIImage, model: String, prompt: String, options: [String], promtpAddition: String) -> RequestReplicateImagetModel? {

    // handel image
    guard let resizedImage = FileOps.resizeImage(image: image, maxPixelSize: 1200) else {return nil}
    guard let jpegData = resizedImage.jpegData(compressionQuality: 1.0) else {return nil}
    let mimeType = "image/jpeg"
    let imageString = jpegData.uriEncoded(mimeType: mimeType)

    let newRequest = RequestReplicateImagetModel(model: model, image: imageString, prompt: prompt, options: options, promptAddition: promtpAddition)
    return newRequest
  }

  func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .soft)
    generator.prepare()
    generator.impactOccurred()
  }

  func getCreatedPrompts() {
    Task {
      do {
        if let allPrompts = try await FirebaseService.downloadPromptData(db: self.db, type: self.trainerType.rawValue) {
          createdPromptsList = allPrompts
          print("Fetched all prompts: \(allPrompts)")
        } else {
          print("Fetched all prompts FAILED")
        }

      } catch {
        print("Error: \(error)")
      }
    }
  }

  

}



