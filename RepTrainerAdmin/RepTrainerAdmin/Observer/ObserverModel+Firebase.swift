//
//  ObserverModel+Firebase.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 20/05/2024.
//

import Foundation
import Firebase

extension ObserverModel {


  func getDemoModels(type: String, completion: @escaping (Bool, DemoModels?) -> Void) {
    FirebaseService.fetchDemoModels(db: self.db, type: type,  completion: { (success, denmoModels) in
      guard success, let demoModels = denmoModels else {
        completion(false, nil)
        return
      }
      completion(true, denmoModels)
    })
  }

  func getDemoModelToRun(model: String, completion: @escaping (Bool, DemoModelToRun?) -> Void) {
    FirebaseService.fetchDemoModelToRun(db: self.db, model: model,  completion: { (success, denmoModelToRun) in
      guard success, let denmoModelToRun = denmoModelToRun else {
        completion(false, nil)
        return
      }
      completion(true, denmoModelToRun)
    })
  }

  /// Get app config from firebase
  /// - Parameter completion: completion handler  (Bool, AppConfig)
  func getAppConfig(completion: @escaping (Bool, AppConfig) -> Void) {
    FirebaseService.readConfigFromFirebase(db: self.db, completion: { (success, config) in
      guard success, let appConfig = config else {
        completion(false, AppConfig())
        return
      }
      completion(true, appConfig)
    })
  }


  /// Get app config from firebase
  /// - Parameter completion: completion handler  (Bool, AppConfig)
  func getRequestOutput(requestId: String, completion: @escaping (Bool, RequestOutput) -> Void) {
    FirebaseService.readFixRequest(requestId: requestId,  db: self.db, completion: { (success, output) in
      guard success, let requestOutput = output else {
        completion(false, RequestOutput(output: [""]))
        return
      }
      completion(true, requestOutput)
    })
  }

}
