//
//  PhotoPicker.swift
//  PromptNodes
//
//  Created by Peter Pohlmann on 18/01/2023.
//

import SwiftUI
import PhotosUI
import CoreTransferable

enum ImageState {
  case empty
  case loading(Progress)
  case success(UIImage)
  case failure(Error)
}

enum ImageStateCompare {
  case empty
  case loading
  case success
  case failure
  case transition
}
enum TransferError: Error {
  case importFailed
}

struct PickerImage: Transferable {
  let uiImage: UIImage

  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(importedContentType: .image) { data in
      guard let uiImage = UIImage(data: data) else {
        throw TransferError.importFailed
      }
      return PickerImage(uiImage: uiImage)
    }
  }
}
