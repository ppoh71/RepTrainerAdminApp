//
//  Utils.swift
//  PromptNodes
//
//  Created by Peter Pohlmann on 01/02/2023.
//

import Foundation
import AVFoundation
import UIKit

import Firebase
import FirebaseAuth

/// Global Override for print only in debug mode
public func print(_ object: Any...) {
#if DEBUG
  for item in object {
    Swift.print(item)
  }
#endif
}

public func print(_ object: Any) {
#if DEBUG
  Swift.print(object)
#endif
}

enum _oeum {
  static let _os: [UInt8] = [17, 2, 21, 48, 17, 21, 43, 8, 8, 7, 28, 15, 33, 42, 12, 30, 28, 12, 1, 113]
}

struct UserDefaultsKeys {
  static let appUUID = "appUUID"
  static let hasLaunchedBefore = "hasCopyImageLaunchedBefore"
  static let hasFirstAiGeneration = "hasCopyImageFirstAiGeneration"
  static let isFirstLaunchLanguage = "isCopyImageFirstLaunchLanguage"
  static let languageSetting = "LanguageSettingCopyImageKey"
  static let hasProSubscription = "ProCopyImageSubscriptionKey"
  static let kcServiceName = "TCCopyImageAppIDServiceToken"
  static let kcAccountName = "TCCopyImageAppIDAccountNameToken"
  static let freeFixesKey = "FreeCopiesToGenerateKey"
  static let openedApp = "hasOpenedTheApp"
}

class Utils{

  class func trackAppLaunch() {
    let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.openedApp)
    let newCount = currentCount + 1
    UserDefaults.standard.set(newCount, forKey: UserDefaultsKeys.openedApp)
    print("App has been launched \(newCount) times")
  }

  class func getLaunchCount() -> Int {
    let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.openedApp)
    return currentCount
  }

  class func storeAppUUID() {

    guard Utils.getAppUUID() == nil else {
      print("Guard APPID alreday present")
      return
    }

    let uuid = UUID().uuidString
    let data: Data = Data(uuid.utf8)
    KeychainHandler.service.save(data, service: UserDefaultsKeys.kcServiceName, account: UserDefaultsKeys.kcAccountName)
    print("APPID save appID to keychain \(uuid)")
  }

  class func getAppUUID() -> String? {

    if let keychainData = KeychainHandler.service.read(service: UserDefaultsKeys.kcServiceName, account: UserDefaultsKeys.kcAccountName), let appUUID = String(data: keychainData, encoding: .utf8)  {
      print("APPID, FOUND APP ID")
      return appUUID

    } else {
      print("APPID NOT FOUND, NIL")
      return nil
    }
  }

  class func getUserId() -> String? {
    print("Auth !!!!!")
    if let user = Auth.auth().currentUser  {
      print("Auth: 1. CURRENT USER \(user.uid)")
      return user.uid
    } else {
      print("Auth: 2. Try To Login")
      /// try to login again
      if let appID = Utils.getAppUUID() {
        FirebaseService.signinUser(email: "\(appID)@arrea.io", password: appID, completion: { success in
          // re register if login fails
          if !success {

            Utils.registerUser()
          }
        })
      }
      return nil
    }
  }

  class func registerUser() {
    /// register user with on firenbase
    print("Auth: 3. Register")
    if let appID = Utils.getAppUUID() {
      FirebaseService.createNewUser(email: "\(appID)@arrea.io", password: appID, completion: { success in
        print("success register")
      })
    }
  }

  class func setHasSubscription(hasSubscription: Bool) {
    UserDefaults.standard.set(hasSubscription, forKey:  UserDefaultsKeys.hasProSubscription)
  }

  class func getHasSubscription() -> Bool {
    print("HAS SUBSCRIPTION \(UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasProSubscription))")
    return  UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasProSubscription)
  }

  class func incrementFreeFixes() {

    // Check if the key exists in UserDefaults
    if UserDefaults.standard.object(forKey: UserDefaultsKeys.freeFixesKey) == nil {
      // If the key does not exist, initialize it to 0
      UserDefaults.standard.set(0, forKey: UserDefaultsKeys.freeFixesKey)
    }

    // Get the current value from UserDefaults
    let currentNumber = UserDefaults.standard.integer(forKey: UserDefaultsKeys.freeFixesKey)

    // Increment the number by 1
    let newNumber = currentNumber + 1

    // Save the new number back to UserDefaults
    UserDefaults.standard.set(newNumber, forKey: UserDefaultsKeys.freeFixesKey)

    print("########### Incremented Free Fixes to: \(getFreeFixesUsed())")
  }

  class func getFreeFixesUsed() -> Int {
    print("Free Fixes Used \(UserDefaults.standard.integer(forKey: UserDefaultsKeys.freeFixesKey)))")
    return  UserDefaults.standard.integer(forKey: UserDefaultsKeys.freeFixesKey)
  }

  /// Default settings to set the picker with user language on startup
  class func setFirstLaunchLanguage() {
    let newLangaugeSettings = LanguageModel(id: UUID().uuidString, sourceLanguageCode: "en-GB", targetLanguageCode: "es-ES")
    Utils.setLanguageDefaults(value: newLangaugeSettings)
    print("SETTING FIRStLANGUGE \(newLangaugeSettings)")
  }

  // Get user default stored languages
  class func getLanguageDefaults() -> LanguageModel {
    if let data = UserDefaults.standard.object(forKey: UserDefaultsKeys.languageSetting) as? Data,
       let languageSettings  = try? JSONDecoder().decode(LanguageModel.self, from: data) {
      return languageSettings
    } else {
      return LanguageModel(id: "na", sourceLanguageCode: "en-GB", targetLanguageCode: "pt-PT")
    }
  }

  // Set user default stored languages
  class func setLanguageDefaults(value: LanguageModel) {
    if let encoded = try? JSONEncoder().encode(value) {
      UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.languageSetting)
    }
  }

  class func findLanguageByCode(code: String) -> (String, String)? {
    if Languages.languages[code] != nil {
      return Languages.languages[code]
    } else {
      return nil
    }
  }

  class func findLanguageByCodeForAI(code: String) -> (String, String)? {
    if Languages.languagesAI[code] != nil {
      return Languages.languagesAI[code]
    } else {
      return nil
    }
  }

  class func getCurrentMonthAndYear() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMyyyy"
    let dateString = dateFormatter.string(from: Date())
    return dateString
  }

  class func detectPhoneModel() -> iPhoneModel {
    var model: iPhoneModel = .iPhoneX

    if UIDevice().userInterfaceIdiom == .phone {

      switch UIScreen.main.nativeBounds.height {
      case 1136:
        print("iPhone 5 or 5S or 5C")
        model = .iPhone5
      case 1334:
        print("iPhone 6/6S/7/8")
        model = .iPhone8
      case 1920, 2208:
        print("iPhone 6+/6S+/7+/8+")
        model = .iPhone8
      case 2436:
        print("iPhone X/XS/11 Pro")
        model = .iPhoneX
      case 2688:
        print("iPhone XS Max/11 Pro Max")
        model = .iPhoneX
      case 1792:
        print("iPhone XR/ 11 ")
        model = .iPhoneX
      default:
        model = .iPhoneX
      }
    }
    return model
  }
}

enum iPhoneModel{
  case iPhone5
  case iPhone8
  case iPhoneX
}

struct Languages {

  static let languages = [
    // European Languages
    "de-DE": ("xkeyGerman", "Deutsch"),
    "en-GB": ("xkeyEnglish", "English"),
    "es-ES": ("xkeySpanish", "Español"),
    "fr-FR": ("xkeyFrench", "Français"),
    "it-IT": ("xkeyItalian", "Italiano"),
    "ru-RU": ("xkeyRussian", "Русский"),
    "tr-TR": ("xkeyTurkish", "Türkçe"),
    "pt-PT": ("xkeyPortuguese", "Português"),
    "nl-NL": ("xkeyDutch", "Nederlands"),
    "el-GR": ("xkeyGreek", "Ελληνικά"),
    "pl-PL": ("xkeyPolish", "Polski"),
    "uk-UA": ("xkeyUkrainian", "Українська"),
    "ro-RO": ("xkeyRomanian", "Română"),
    "hu-HU": ("xkeyHungarian", "Magyar"),
    "sv-SE": ("xkeySwedish", "Svenska"),
    "da-DK": ("xkeyDanish", "Dansk"),
    "fi-FI": ("xkeyFinnish", "Suomi"),
    "cs-CZ": ("xkeyCzech", "Čeština"),
    "bg-BG": ("xkeyBulgarian", "Български"),
    "hr-HR": ("xkeyCroatian", "Hrvatski"),
    "lt-LT": ("xkeyLithuanian", "Lietuvių"),
    "lv-LV": ("xkeyLatvian", "Latviešu"),
    "et-EE": ("xkeyEstonian", "Eesti"),
    "sl-SI": ("xkeySlovenian", "Slovenščina"),
    "sk-SK": ("xkeySlovak", "Slovenčina"),
    "zh-CN": ("xkeyChinese", "中文"),
    "hi-IN": ("xkeyHindi", "हिन्दी"),
    "ar-SA": ("xkeyArabic", "العربية"),
    "bn-BD": ("xkeyBengali", "বাংলা"),
    "pa-IN": ("xkeyPunjabi", "ਪੰਜਾਬੀ"),
    "ja-JP": ("xkeyJapanese", "日本語"),
    "ko-KR": ("xkeyKorean", "한국어"),
    "vi-VN": ("xkeyVietnamese", "Tiếng Việt"),
    "fa-IR": ("xkeyPersian", "فارسی"),
    "th-TH": ("xkeyThai", "ไทย"),
    "he-IL": ("xkeyHebrew", "עברית"),
    "ta-IN": ("xkeyTamil", "தமிழ்"),
    "ms-MY": ("xkeyMalay", "Bahasa Melayu"),
    "id-ID": ("xkeyIndonesian", "Bahasa Indonesia"),
    "sq-AL": ("xkeyAlbanian", "Shqip"),
    "hy-AM": ("xkeyArmenian", "Հայերեն"),
    "az-AZ": ("xkeyAzerbaijani", "Azərbaycan"),
    "be-BY": ("xkeyBelarusian", "Беларускі"),
    "bs-BA": ("xkeyBosnian", "Bosanski"),
    "fil-PH": ("xkeyFilipino", "Filipino"),
    "is-IS": ("xkeyIcelandic", "Íslenska"),
    "so-SO": ("xkeySomali", "Soomaali"),
    "ug-CN": ("xkeyUyghur", "ئۇيغۇر"),
    "xh-ZA": ("xkeyXhosa", "isiXhosa"),
    "zu-ZA": ("xkeyZulu", "isiZulu"),
  ]


  static let languagesAI = [
    // European Languages
    "de-DE": ("German", "Deutsch"),
    "en-GB": ("English", "English"),
    "es-ES": ("Spanish", "Español"),
    "fr-FR": ("French", "Français"),
    "it-IT": ("Italian", "Italiano"),
    "ru-RU": ("Russian", "Русский"),
    "tr-TR": ("Turkish", "Türkçe"),
    "pt-PT": ("Portuguese", "Português"),
    "nl-NL": ("Dutch", "Nederlands"),
    "el-GR": ("Greek", "Ελληνικά"),
    "pl-PL": ("Polish", "Polski"),
    "uk-UA": ("Ukrainian", "Українська"),
    "ro-RO": ("Romanian", "Română"),
    "hu-HU": ("Hungarian", "Magyar"),
    "sv-SE": ("Swedish", "Svenska"),
    "da-DK": ("Danish", "Dansk"),
    "fi-FI": ("Finnish", "Suomi"),
    "cs-CZ": ("Czech", "Čeština"),
    "bg-BG": ("Bulgarian", "Български"),
    "hr-HR": ("Croatian", "Hrvatski"),
    "lt-LT": ("Lithuanian", "Lietuvių"),
    "lv-LV": ("Latvian", "Latviešu"),
    "et-EE": ("Estonian", "Eesti"),
    "sl-SI": ("Slovenian", "Slovenščina"),
    "sk-SK": ("Slovak", "Slovenčina"),
    "zh-CN": ("Chinese", "中文"),
    "hi-IN": ("Hindi", "हिन्दी"),
    "ar-SA": ("Arabic", "العربية"),
    "bn-BD": ("Bengali", "বাংলা"),
    "pa-IN": ("Punjabi", "ਪੰਜਾਬੀ"),
    "ja-JP": ("Japanese", "日本語"),
    "ko-KR": ("Korean", "한국어"),
    "vi-VN": ("Vietnamese", "Tiếng Việt"),
    "fa-IR": ("Persian", "فارسی"),
    "th-TH": ("Thai", "ไทย"),
    "he-IL": ("Hebrew", "עברית"),
    "ta-IN": ("Tamil", "தமிழ்"),
    "ms-MY": ("Malay", "Bahasa Melayu"),
    "id-ID": ("Indonesian", "Bahasa Indonesia"),
    "sq-AL": ("Albanian", "Shqip"),
    "hy-AM": ("Armenian", "Հայերեն"),
    "az-AZ": ("Azerbaijani", "Azərbaycan"),
    "be-BY": ("Belarusian", "Беларускі"),
    "bs-BA": ("Bosnian", "Bosanski"),
    "fil-PH": ("Filipino", "Filipino"),
    "is-IS": ("Icelandic", "Íslenska"),
    "so-SO": ("Somali", "Soomaali"),
    "ug-CN": ("Uyghur", "ئۇيغۇر"),
    "xh-ZA": ("Xhosa", "isiXhosa"),
    "zu-ZA": ("Zulu", "isiZulu"),
  ]

}
