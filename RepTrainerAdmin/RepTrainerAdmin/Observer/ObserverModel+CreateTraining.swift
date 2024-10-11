//
//  ObserverModel+CreateTraining.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 20/09/2024.
//

import Foundation
import SwiftUI
import FirebaseAppCheck

extension ObserverModel {

  func initNewTraining() {
    /// reset traingings array
    self.newTrainging = NewTrainingModel()

    /// reset Images
    newTraingingSelctedImages = [UIImage]()

    guard let userId = Utils.getUserId() else {print("start trining, no user id"); return }
    newTrainging.userId = userId
    newTrainging.modelName = UUID().uuidString
    newTrainging.traingingType = self.trainerType.rawValue
  }

  func uploadZipToStartTraining() {
    guard !self.newTrainging.userId.isEmpty else {print("start training, no user id"); return }
    guard !self.newTraingingSelctedImages.isEmpty else {print("start training, no images"); return }

    Task {
      do {
        if let zipFileURL = try FileOps.createZipFromImages(images: newTraingingSelctedImages, zipFileName: "data") {

          FirebaseService.uploadZipAndStartTraining(userId: newTrainging.userId, modelName: self.newTrainging.modelName, zipFileURL: zipFileURL) { result in
            switch result {
            case .success(let downloadURL):
              print("ZIP file uploaded. URL: \(downloadURL)")
              // Optionally, call Firebase Functions here
              self.newTrainging.zipURL = downloadURL.absoluteString
              self.startTraingFromFirebaseFunction()

            case .failure(let error):
              print("Failed to upload ZIP file: \(error.localizedDescription)")
            }
          }
        }
      } catch {
        print("Failed to create ZIP file: \(error)")
      }
    }
  }

  func startTraingFromFirebaseFunction() {
    _ = Task {
      await self.sendTrainingToFirebaseFunction(training: self.newTrainging)
    }
  }

  func sendTrainingToFirebaseFunction(training: NewTrainingModel) async {
    networkTaskGetImagePrompt?.cancel()

    // encode chat query
    guard let encoded = try? JSONEncoder().encode(training) else {
      print ("Failed to encode Order")
      return
    }

    // 2. Create the url we want to read
    guard let debugURL = URL(string: "http://127.0.0.1:5001/replicatetrainer-a6cef/us-central1/initTraining"), let live = URL(string: "https://us-central1-replicatetrainer-a6cef.cloudfunctions.net/initTraining") else {
      return
    }

    var request = URLRequest(url: live)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.timeoutInterval = 320

    networkTaskGetImagePrompt = Task {

      do {

        let token = try await AppCheck.appCheck().token(forcingRefresh: false)
        let tokenString = token.token
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue(tokenString, forHTTPHeaderField: "X-Firebase-AppCheck")
        request.httpBody = encoded

        let (data, _) = try await URLSession.shared.data(for: request)
        print("await chunk ")
        print(training)
        print("Received \( String(data: data, encoding: .utf8) )")

        let decoder = JSONDecoder()
        if let dataDecoded = try? decoder.decode(ReplicateTrainingResponse.self, from: data) {
          print("Training Response:")
          print(dataDecoded.response)

          

        } else {
          print("Trainign Decoding went wrong 1")
        }
      } catch {
        print("Error start training")
        print(error)
      }
    }
  }

}
