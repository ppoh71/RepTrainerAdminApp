//
//  ReplicateModel.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 06/05/2024.
//

import Foundation

struct RequestImagePromptModel: Codable {
  var userId: String
  var requestId: String
  let image: String
  var prompt: String
}

struct RequestReplicateImagetModel: Codable {
  var model: String
  let image: String
  var prompt: String
  var options: [String]
  var promptAddition: String
  var maskUrlString: String
}

struct RequestReplicatePromptOnlyModel: Codable {
  var prompt: String
}

struct DemoModels: Codable {
  var demoModels: [String: String]
}

struct RequestDemoImageResponse: Codable {
  var model: String
  var prompt: String
}

struct RequestImagePromptResponse: Codable {
  var prompt: String
}

struct RequestBaseImagePromptResponse: Codable {
  var response: String
}

struct RequestImageGenerationModel: Codable {
  var userId: String
  var requestId: String
  let prompt: String
}

/// Dall-e response, using repçlicate/flux now
struct RequestImageGenerationResponse: Codable {
  let response: [ImgageResponse]
}

struct RequestDemoImageGeneratedResponse: Codable {
  let response: [String]
}

struct ReplicateTrainingResponse: Codable {
  let response: Bool
}

struct ImgageResponse: Codable {
  let revised_prompt: String
  let url: String
}

//struct ReplicateResponse: Codable {
//  let output: [String]
//}
