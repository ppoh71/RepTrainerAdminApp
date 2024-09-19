//
//  LanguageModel.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 28/12/2023.
//

import Foundation

struct LanguageModel: Codable, Identifiable, Hashable {
  let id: String
  var sourceLanguageCode: String
  var targetLanguageCode: String
}

extension LanguageModel {


  var sourceLanguageNameEnglishForAi: String {
    let languageOptions = Languages.languagesAI
    if let languageName = languageOptions.first(where: { $0.key == self.sourceLanguageCode })?.value {
      return languageName.0
    } else {
      return "N.A."
    }
  }

  var targetLanguageNameEnglishForAi: String {
    let languageOptions = Languages.languagesAI
    if let languageName = languageOptions.first(where: { $0.key == self.targetLanguageCode })?.value {
      return languageName.0
    } else {
      return "N.A."
    }
  }

  var sourceLanguageName: String {
    let languageOptions = Languages.languages
    if let languageName = languageOptions.first(where: { $0.key == self.sourceLanguageCode })?.value {
      return languageName.0
    } else {
      return "N.A."
    }
  }

  var sourceLanguageNameNative: String {
    let languageOptions = Languages.languages
    if let languageName = languageOptions.first(where: { $0.key == self.sourceLanguageCode })?.value {
      return languageName.1
    } else {
      return "N.A."
    }
  }

  var targetLanguageName: String {
    let languageOptions = Languages.languages
    if let languageName = languageOptions.first(where: { $0.key == self.targetLanguageCode })?.value {
      return languageName.0
    } else {
      return "N.A."
    }
  }

  var targetLanguageNameNative: String {
    let languageOptions = Languages.languages
    if let languageName = languageOptions.first(where: { $0.key == self.targetLanguageCode })?.value {
      return languageName.1
    } else {
      return "N.A."
    }
  }
}
