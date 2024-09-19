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
  case baby = "baby"

  var id: String { self.rawValue }  // Conform to Identifiable
}

struct SelectedDemoModel{
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

struct CreatedPrompt: Codable, Hashable {
  var desc: String
  var imageURL: String
  var prompt: String

  func getImage() async -> UIImage?{
    do {
      if let url = URL(string: self.prompt) {
        if let image = try await FileOps.downloadImage(from: url) {
          
        }
      }
    } catch {
      print("Error callHttpStreamEndpoint 1")
      print(error.localizedDescription)
    }
    return nil
  }

}
