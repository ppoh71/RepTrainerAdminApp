//
//  RepTrainerModels.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 18/09/2024.
//

import Foundation
import SwiftUI

enum TrainerType: String, CaseIterable, Identifiable {
  case family = "family"
  case kids = "kids"
  case baby = "baby"

  var id: String { self.rawValue }  // Conform to Identifiable
}

struct SelectedDemoModel: Identifiable, Hashable{
  var id = UUID()
  var desc: String
  var modelName: String
}

struct DemoModelToRun: Codable {
  var createdAt: Date?
  var finishedAt: Date?
  var promptAddition: String
  var trigger: String
  var userID: String
}

enum PromptOptions: String, CaseIterable, Identifiable {
  case noimg2img = "noimg2img"
  case boys = "boys"
  case girls = "girls"
  case allGender = "baby"
  case photoshooting = "photoshooting"
  case cartoon = "cartoon"
  case birthday = "birthday"
  case western = "western"
  case easter = "eastern"
  case middelEast = "middleEast"

  var id: String { self.rawValue }  // Conform to Identifiable
}

struct CreatedPrompt: Codable, Hashable {
  var id: String
  var desc: String
  var imageURL: String
  var prompt: String
  var options: [String]?
  var sortOrder: Int = 1

  func getImage() async -> UIImage?{
    do {
      if let url = URL(string: self.prompt) {
        if (try await FileOps.downloadImage(from: url)) != nil {
          
        }
      }
    } catch {
      print("Error callHttpStreamEndpoint 1")
      print(error.localizedDescription)
    }
    return nil
  }
}

struct NewTrainingModel: Codable {
  var modelName: String = ""
  var promptAddition: String = ""
  var promptOptions: [String] = [String]()
  var zipURL: String = ""
  var userId: String = ""
  var traingingType: String = ""
}
