
//  FirebaseService.swift
//  PromptNodes
//
//  Created by Peter Pohlmann on 28/01/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

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
    guard !model.isEmpty else {print("G. model is empty"); return}

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
        print("Error decoding studio fetch Demo Run Models: \(error)")
        DispatchQueue.main.async {
          completion(false, nil)
        }
      }
    }
  }

  class func createPromptWithImage(db: Firestore?, type: String, image: UIImage, prompt: String, desc: String, options: [String], sortOrder: Int, completion: @escaping (Result<String, Error>) -> Void) {
    guard let db = db else {print("G. get tut"); return }

    guard let resizedImage = FileOps.resizeImage(image: image, maxPixelSize: 1024), let imageData = resizedImage.jpegData(compressionQuality: 0.9) else {
      print("Failed to resize image UIImage to Data")
      return
    }

    // Convert UIImage to Data
//    guard let imageData = image.jpegData(compressionQuality: 0.9) else {
//      print("Failed to convert UIImage to Data")
//      return
//    }

    // Create a unique filename for the image
    let fileName = UUID().uuidString
    let storageRef = Storage.storage().reference().child("promptImages/\(fileName).jpg")

    // Upload image data to Firebase Storage
    storageRef.putData(imageData, metadata: nil) { metadata, error in
      if let error = error {
        print("Failed to upload image to Firebase Storage: \(error.localizedDescription)")
        completion(.failure(error))
        return
      }

      // Get download URL of the image
      storageRef.downloadURL { url, error in
        if let error = error {
          print("Failed to get download URL: \(error.localizedDescription)")
          completion(.failure(error))
          return
        }

        guard let downloadURL = url?.absoluteString else {
          print("Download URL is nil")
          return
        }

        print("Download URL: \(downloadURL)")
        var ref: DocumentReference? = nil
        ref = db.collection("prompts").document(type).collection("prompt").addDocument(data: [
          "id": "", // Placeholder, will be updated
          "imageURL": downloadURL,
          "prompt": prompt,
          "desc": desc,
          "options": options,
          "sortOrder": sortOrder
        ]) { error in
          if let error = error {
            print("Failed to save image URL to Firestore: \(error.localizedDescription)")
            completion(.failure(error))
          } else {
            print("Successfully saved image URL to Firestore")

            // Now update the 'id' field with the document ID
            ref?.updateData(["id": ref!.documentID]) { updateError in
              if let updateError = updateError {
                print("Failed to update document ID: \(updateError.localizedDescription)")
                completion(.failure(updateError))
              } else {
                print("Successfully updated document with its ID")
                completion(.success(downloadURL))
              }
            }
          }
        }
      }
    }
  }

 class func getMaskImageDownloadUrl(from urlString: String, completion: @escaping (Result<String, Error>) -> Void) {
    // Extract the original filename from the URL
    guard let originalFileName = urlString.extractFileName() else {
      print("Failed to extract filename from URL.")
      completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract filename from URL"])))
      return
    }

    // Modify the filename to append '_mask' before the file extension
    let maskFileName = originalFileName.replacingOccurrences(of: ".jpg", with: "_mask.jpg")

    // Create the reference for the mask image in Firebase Storage
    let storageRef = Storage.storage().reference().child("promptImages/\(maskFileName)")

    // Get the download URL for the mask image
    storageRef.downloadURL { url, error in
      if let error = error {
        print("Failed to get download URL for mask image: \(error.localizedDescription)")
        completion(.failure(error))
      } else if let downloadUrl = url?.absoluteString {
        print("Successfully retrieved mask image URL: \(downloadUrl)")
        completion(.success(downloadUrl))
      }
    }
  }
  
  class func overrideImageAndCreateMask(from urlString: String, newImage: UIImage, maskImage: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
    // Extract the filename from the URL

    guard let resizedImage = FileOps.resizeImage(image: newImage, maxPixelSize: 1024), let imageData = resizedImage.jpegData(compressionQuality: 0.9) else {
      print("Failed to resize image UIImage to Data")
      completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to resize image UIImage to Data"])))
      return
    }

    guard let fileName = urlString.extractFileName() else {
      print("Failed to extract filename from URL")
      completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract filename from URL"])))
      return
    }

    print("Override image and create mask for: \(fileName)")

    // Create the reference for the original image (based on the extracted filename)
    let storageRef = Storage.storage().reference().child("promptImages/\(fileName)")

    // Upload the new image to override the existing one
    storageRef.putData(imageData, metadata: nil) { metadata, error in
      if let error = error {
        print("Failed to upload new image to Firebase Storage: \(error.localizedDescription)")
        completion(.failure(error))
        return
      }

      guard let maskImage = maskImage else {
        print("No mask image")
        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mask image, return and dont save mask image"])))
        return
      }

      // Now create the "_mask" image
      let maskFileName = fileName.replacingOccurrences(of: ".jpg", with: "_mask.jpg")
      let maskStorageRef = Storage.storage().reference().child("promptImages/\(maskFileName)")

      // Convert the mask image to Data
      guard let maskImageData = maskImage.jpegData(compressionQuality: 0.9) else {
        print("Failed to convert mask image to Data")
        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert mask image to Data"])))
        return
      }

      // Upload the mask image
      maskStorageRef.putData(maskImageData, metadata: nil) { metadata, error in
        if let error = error {
          print("Failed to upload mask image to Firebase Storage: \(error.localizedDescription)")
          completion(.failure(error))
          return
        }

        print("Successfully uploaded new image and mask.")
        completion(.success(())) // Successful completion
      }
    }
  }

  
  class func updatePromptAndOptions(db: Firestore?, documentID: String, type: String, newPrompt: String, newOptions: [String], completion: @escaping (Error?) -> Void) {
    guard let db = db else {
      print("Firestore database reference is nil")
      return
    }

    // Reference to the document based on its ID and type
    let docRef = db.collection("prompts").document(type).collection("prompt").document(documentID)

    // Update the 'prompt' and 'options' fields
    docRef.updateData([
      "prompt": newPrompt,
      "options": newOptions
    ]) { error in
      if let error = error {
        print("Failed to update prompt and options: \(error.localizedDescription)")
        completion(error)
      } else {
        print("Prompt and options updated successfully")
        completion(nil)
      }
    }
  }

  class func updateSortOrderForPrompt(db: Firestore?, documentID: String, type: String, newOrder: Int) {
    guard let db = db else {print("G. get tut"); return }

    db.collection("prompts").document(type).collection("prompt").document(documentID).updateData(["sortOrder": newOrder]) { error in
      if let error = error {
        print("Error updating sort order: \(error)")
      } else {
        print("Sort order updated successfully")
      }
    }
  }

  class func deletePrompt(db: Firestore?, type: String, documentID: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let db = db else {print("G. get tut"); return }
    let docRef = db.collection("prompts").document(type).collection("prompt").document(documentID)

    docRef.delete { error in
      if let error = error {
        print("Failed to delete document: \(error.localizedDescription)")
        completion(.failure(error))
      } else {
        print("Successfully deleted document with ID: \(documentID)")
        completion(.success(()))
      }
    }
  }

  class func deleteImageFromStorage(downloadURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
    // Extract the filename from the download URL using the provided extractFileName function
    guard let originalFileName = downloadURL.extractFileName() else {
      print("Failed to extract filename from URL.")
      completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract filename from URL"])))
      return
    }

    // Assuming the file is stored in "promptImages/" directory in Firebase Storage
    let storageRef = Storage.storage().reference().child("promptImages/\(originalFileName)")

    // Delete the file from Firebase Storage
    storageRef.delete { error in
      if let error = error {
        print("Failed to delete image from Firebase Storage: \(error.localizedDescription)")
        completion(.failure(error))
      } else {
        print("Image successfully deleted from Firebase Storage")
        completion(.success(()))
      }
    }
  }

  class func downloadPromptData(db: Firestore?, type: String) async throws -> [CreatedPrompt]? {
    guard let db = db else {print("G. get tut"); return nil }

    // Reference to the collection
    let collectionRef = db.collection("prompts").document(type).collection("prompt")

    do {
      // Fetch all documents in the collection
      let snapshot = try await collectionRef.getDocuments()
      
      // Dictionary to store document IDs and their corresponding CreatedPrompt models
      var allPrompts: [CreatedPrompt] = []

      // Loop through each document in the collection
      for document in snapshot.documents {
        do {
          // Decode the document data into the CreatedPrompt model
          if let prompt = try document.data(as: CreatedPrompt?.self) {
            // Store the document ID as the key and the CreatedPrompt as the value
            allPrompts.append(prompt)
          }
        } catch {
          print("Error decoding document \(document.documentID): \(error)")
        }
      }

      let sortedPrompts = allPrompts.sorted { $0.sortOrder < $1.sortOrder }
      return sortedPrompts

    } catch {
      print("Error fetching documents: \(error.localizedDescription)")
      throw error
    }
  }


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

  class func uploadZipAndStartTraining(userId: String, modelName: String, zipFileURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
    // Create a reference to Firebase Storage
    let storageRef = Storage.storage().reference().child("training_images/\(userId)/\(modelName)/data.zip")

    // Upload the file
    let uploadTask = storageRef.putFile(from: zipFileURL, metadata: nil) { metadata, error in
      if let error = error {
        print("Error uploading file: \(error.localizedDescription)")
        completion(.failure(error))
        return
      }

      // Get the download URL
      storageRef.downloadURL { url, error in
        if let error = error {
          print("Error getting download URL: \(error.localizedDescription)")
          completion(.failure(error))
          return
        }

        if let downloadURL = url {
          print("File uploaded successfully. Download URL: \(downloadURL)")
          completion(.success(downloadURL))
        }
      }
    }

    // Monitor the upload progress (optional)
    uploadTask.observe(.progress) { snapshot in
      let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount) * 100
      print("Upload is \(percentComplete)% complete")
    }
  }


}

