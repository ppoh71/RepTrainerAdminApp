//
//  RepTrainerModels.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 18/09/2024.
//

import Foundation

enum TrainerType: String, CaseIterable, Identifiable {
  case family = "family"
  case baby = "baby"

  var id: String { self.rawValue }  // Conform to Identifiable
}

struct DemoModelToRun: Codable {
  var createdAt: Date?
  var finishedAt: Date?
  var promptAddition: String
  var trigger: String
  var userID: String
}
