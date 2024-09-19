
//  FirebaseService.swift
//  PromptNodes
//
//  Created by Peter Pohlmann on 28/01/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth


/// FirebaseService
final class FirebaseService {

  /// Anon login, not implemented yet
  /// - Parameter completion: (Bool))
  class func loginAnonymous(completion: @escaping (Bool) -> Void) {
    Auth.auth().signInAnonymously() { (authResult, error) in
      guard (authResult?.user) != nil else { return }
      DispatchQueue.main.async {
        completion(true)
      }
    }
  }

  class func logout()  {
    let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
  }

  /// SignIn User in Firebase
  /// - Parameters:
  ///   - email: email string
  ///   - password: password string
  class func signinUser(email: String, password: String, completion: @escaping (Bool) -> Void ) {

    Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in

      guard error == nil else {
        completion(false)
        return
      }

      print("AUTH: Auth User Login \(String(describing: authResult))")
      completion(true)
    }
  }


  /// Create New User in Firebase
  /// - Parameters:
  ///   - email: email string
  ///   - password: password string
  class func createNewUser(email: String, password: String, completion: @escaping (Bool) -> Void) {

    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
      guard error == nil else {
        print("AUTH: Error New User \(String(describing: error))")
        completion(false)
        return
      }

      if authResult != nil {
        print("AUTH: Created New User \(String(describing: authResult))")
        completion(true)
      }
    }
  }


  /// GEt App config file
  /// - Parameter db: firebase db
  /// - Parameter completion: (Bool, AppConfig?)
  class func readConfigFromFirebase(db: Firestore?, completion: @escaping (Bool, AppConfig?) -> Void) {
    guard let db = db else {print("G. get tut"); return}

    let docRef = db.collection("Config").document("AppConfig")

    docRef.getDocument { (document, error) in
      if let error = error {
        print("Error retrieving document: \(error)")
        return
      }

      let result = Result { try document?.data(as: AppConfig.self) }

      switch result {
      case .success(let appConfig):
        if let appConfig = appConfig {
          DispatchQueue.main.async {
            completion(true, appConfig)
          }
        } else {
          print("Document does not exist")
          DispatchQueue.main.async {
            completion(false, nil)
          }
        }
      case .failure(let error):
        print("Error decoding studio 6: \(error)")
        DispatchQueue.main.async {
          completion(false, nil)
        }
      }
    }
  }


  class func fetchDemoModels(db: Firestore?, type: String, completion: @escaping (Bool, DemoModels?) -> Void) {
    guard let db = db else {print("G. get tut"); return}
    let docRef = db.collection("prompts").document(type)

    docRef.getDocument { (document, error) in
      if let error = error {
        print("Error retrieving document: \(error)")
        return
      }

      let result = Result { try document?.data(as: DemoModels.self) }

      switch result {
      case .success(let output):
        if let output = output {
          DispatchQueue.main.async {
            completion(true, output)
          }
        } else {
          print("Document does not exist")
          DispatchQueue.main.async {
            completion(false, nil)
          }
        }
      case .failure(let error):
        print("Error decoding studio fetch Demo Models: \(error)")
        DispatchQueue.main.async {
          completion(false, nil)
        }
      }
    }
  }

  class func fetchDemoModelToRun(db: Firestore?, model: String, completion: @escaping (Bool, DemoModelToRun?) -> Void) {
    guard let db = db else {print("G. get tut"); return}

    print("model to find: \(model)")
    let docRef = db.collection("finishedTrainings").document(model)

    docRef.getDocument { (document, error) in
      if let error = error {
        print("Error retrieving document: \(error)")
        return
      }

      let result = Result { try document?.data(as: DemoModelToRun.self) }

      switch result {
      case .success(let output):
        if let output = output {
          DispatchQueue.main.async {
            completion(true, output)
          }
        } else {
          print("Document does not exist")
          DispatchQueue.main.async {
            completion(false, nil)
          }
        }
      case .failure(let error):
        print("Error decoding studio fetch Demo Models: \(error)")
        DispatchQueue.main.async {
          completion(false, nil)
        }
      }
    }
  }


//    docRef.getDocument { (document, error) in
//      if let document = document, document.exists {
//        print("Try get demoModels 2")
//        if let demoModels = document.data()?["demoModels"] as? [String: String] {
//          print("Try get demoModels 3")
//          completion(true, demoModels)
//        } else {
//          print("demoModels map does not exist in the document")
//          completion(false, nil)
//        }
//      } else {
//        print("Document does not exist or error occurred: \(error?.localizedDescription ?? "Unknown error")")
//        completion(false, nil)
//      }
//    }

  /// GEt App config file
  /// - Parameter db: firebase db
  /// - Parameter completion: (Bool, AppConfig?)
  class func readFixRequest(requestId: String, db: Firestore?, completion: @escaping (Bool, RequestOutput?) -> Void) {

    guard let db = db else {print("G. readFixRequest"); return}
    guard let userId = Utils.getUserId() else {print("G. readFixRequest"); return}

    //const docRef = db.collection('outputs').doc(userId).collection(requestId).doc("output");
    let docRef = db.collection("outputs").document(userId).collection(requestId).document("output")

    docRef.getDocument { (document, error) in
      if let error = error {
        print("Error retrieving document: \(error)")
        return
      }

      let result = Result { try document?.data(as: RequestOutput.self) }

      switch result {
      case .success(let output):
        if let output = output {
          DispatchQueue.main.async {
            completion(true, output)
          }
        } else {
          print("Document does not exist")
          DispatchQueue.main.async {
            completion(false, nil)
          }
        }
      case .failure(let error):
        print("Error decoding studio 6: \(error)")
        DispatchQueue.main.async {
          completion(false, nil)
        }
      }
    }
  }



}

