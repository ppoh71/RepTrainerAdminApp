//
//  ObserverModel+AI.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 11/03/2024.
//

import Foundation
import SwiftUI
import FirebaseAppCheck

extension ObserverModel {

  func generatePromptRequest(requestModel: RequestImagePromptModel ) async {
    networkTaskGetImagePrompt?.cancel()

    // encode chat query
    guard let encoded = try? JSONEncoder().encode(requestModel) else {
      print ("Failed to encode Order")
      return
    }

    // 2. Create the url we want to read
    guard let debugURL = URL(string: "http://127.0.0.1:5001/replicatetrainer-a6cef/us-central1/getImagePrompt"), let live = URL(string: "https://us-central1-replicatetrainer-a6cef.cloudfunctions.net/getImagePrompt") else {
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
        request.setValue(tokenString, forHTTPHeaderField: "X-Firebase-AppCheck")
        request.httpBody = encoded
        print("Probing for call")

        let (data, _) = try await URLSession.shared.data(for: request)
        print("await chunk ")
        print("Received \( String(data: data, encoding: .utf8) )")
        
        let decoder = JSONDecoder()
        if let dataDecoded = try? decoder.decode(RequestImagePromptResponse.self, from: data) {
          print("Prompt Received \(dataDecoded.prompt )")
          //startImageGeberation(prompt: dataDecoded.prompt)

          /// add prompt end finish
          self.fixModel.prompt = dataDecoded.prompt
          self.fixAction = .fixFinished
          startBaseImageGeneration()
          
        } else {
          self.fixAction = .fixTimeOut
          print("Decoding went wrong 1")
        }
      } catch {
        print("Error prompt generation")
        self.fixAction = .fixTimeOut
        print(error)
      }
    }
  }

  func  startBaseImageGeneration() {
    _ = Task {
      await self.baseImageGenerationeRequest(model: "no model needed here", prompt:  self.fixModel.prompt, image: self.fixModel.originalImage)
    }
  }

  func  startIDemoImageGeneration(model: String, prompt: String, image: UIImage) {
    _ = Task {
      await self.generateDemoImageRequest(model: model, prompt: prompt, image: image)
    }
  }

  func baseImageGenerationeRequest(model: String, prompt: String, image: UIImage) async {
    networkTaskGetImage?.cancel()

    /// cretae response model to post
    let requestModel = requestResponseModel(image: image, model: model, prompt: prompt)

    // encode request model for query
    guard let encoded = try? JSONEncoder().encode(requestModel) else {
      print ("Failed to encode Order")
      return
    }

    // 2. Create the url we want to read
    guard let debugURL = URL(string: "http://127.0.0.1:5001/replicatetrainer-a6cef/us-central1/getPromptBaseImage"), let live = URL(string: "https://us-central1-replicatetrainer-a6cef.cloudfunctions.net/getPromptBaseImage") else {
      return
    }

    isLoading = true

    var request = URLRequest(url: live)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.timeoutInterval = 320

    networkTaskGetImage = Task {

      do {

        let token = try await AppCheck.appCheck().token(forcingRefresh: false)
        let tokenString = token.token
        request.setValue(tokenString, forHTTPHeaderField: "X-Firebase-AppCheck")
        request.httpBody = encoded

        print("Probing for call")
        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
        print("data received")
        print(String(decoding: data, as: UTF8.self))

        if let dataDecoded = try? decoder.decode(RequestDemoImageGeneratedResponse.self, from: data) {
          print("image Data \(dataDecoded)")

          //   if let outputString = dataDecoded.response {
          print("Decode Success")
          print("url", dataDecoded.response)

          //fixModel.fixedUrl = dataDecoded.response.first

          /// Download generated image
          do {
            if let url = URL(string: dataDecoded.response.first ?? "") {
              if let image = try await FileOps.downloadImage(from: url) {
                isLoading = false
                self.fixModel.baseImage = image
                self.fixModel.fixedUrl = url.absoluteString
                self.persistSuccessRequest(urlString: self.fixModel.fixedUrl ?? "https://apple.com", image: image)
                generateThumbnail(requestId: self.fixModel.requestId, fixUrlString: self.fixModel.fixedUrl, fixedImage: image)
                print("Got an image \(dataDecoded.response)")
              }
            }
          } catch {
            self.fixAction = .fixTimeOut
            print("Error callHttpStreamEndpoint 1")
            print(error.localizedDescription)
            isLoading = false
          }

          // }
        } else {
          print("Decoding went wrong")
          isLoading = false
        }


      } catch {
        print("Error Image Geneatiom Request !!!!!")
        //self.fixAction = .fixTimeOut
        isLoading = false
        print(error)
      }
    }
  }
  func generateDemoImageRequest(model: String, prompt: String, image: UIImage ) async {
    networkTaskGetImage?.cancel()

    /// cretae response model to post
    let requestModel = requestResponseModel(image: image, model: model, prompt: prompt)
    
    // encode request model for query
    guard let encoded = try? JSONEncoder().encode(requestModel) else {
      print ("Failed to encode Order")
      return
    }

    // 2. Create the url we want to read
    guard let debugURL = URL(string: "http://127.0.0.1:5001/replicatetrainer-a6cef/us-central1/getDemoImage"), let live = URL(string: "https://us-central1-replicatetrainer-a6cef.cloudfunctions.net/getDemoImage") else {
      return
    }

    isLoading = true

    var request = URLRequest(url: live)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.timeoutInterval = 320

    networkTaskGetImage = Task {

      do {

        let token = try await AppCheck.appCheck().token(forcingRefresh: false)
        let tokenString = token.token
        request.setValue(tokenString, forHTTPHeaderField: "X-Firebase-AppCheck")
        request.httpBody = encoded

        print("Probing for call")
        let (data, _) = try await URLSession.shared.data(for: request)

        let decoder = JSONDecoder()
        print("data received")
        print(String(decoding: data, as: UTF8.self))

        if let dataDecoded = try? decoder.decode(RequestDemoImageGeneratedResponse.self, from: data) {
          print("image Data \(dataDecoded)")

       //   if let outputString = dataDecoded.response {
            print("Decode Success")
            print("url", dataDecoded.response)

          fixModel.fixedUrl = dataDecoded.response.first

            /// Download generated image
            do {
              if let url = URL(string: dataDecoded.response.first ?? "") {
                if let image = try await FileOps.downloadImage(from: url) {
                  self.fixModel.fixedimage = image
                  self.fixAction = .fixFinished
                  isLoading = false
                  print("Got an image \(dataDecoded.response)")
                }
              }
            } catch {
              self.fixAction = .fixTimeOut
              print("Error callHttpStreamEndpoint 1")
              print(error.localizedDescription)
              isLoading = false
            }

         // }
        } else {
          print("Decoding went wrong")
          isLoading = false
        }


      } catch {
        print("Error Image Geneatiom Request !!!!!")
        //self.fixAction = .fixTimeOut
        isLoading = false
        print(error)
      }
    }
  }
}
