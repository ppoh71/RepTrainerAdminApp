//
//  CreateTrainging.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 20/09/2024.
//

import SwiftUI
import PhotosUI
import UIKit

struct CreateTrainging: View {
  @EnvironmentObject var observer: ObserverModel

  // Selected PhotoPicker items
  @State private var selectedItems: [PhotosPickerItem] = []
  @State private var itemToImageMap: [Int: UIImage] = [:]
  @State private var loadedItems: [PhotosPickerItem] = []

  var columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 3-column grid

  var body: some View {
    VStack {

      VStack {
        Button(action: {
          observer.initNewTraining()
          selectedItems = []
          itemToImageMap = [:]
          loadedItems = []
        }) {
          ButtonDefaultShape(buttonType: .createTraining)
        }

        Spacer().frame(width: 10, height: 30)

        // Photo picker button
        PhotosPicker(
          selection: $selectedItems,
          maxSelectionCount: 10, // Allow multiple selection, max 10 images
          matching: .images
        ) {
          ButtonDefaultShape(buttonType: .selectImages)
        }
        .onChange(of: selectedItems) { oldValue, newValue in
          Task {
            await loadImages(from: newValue)
            resizeSelectedImages()
          }
        }
      }

      Spacer().frame(width: 10, height: 30)
      
      // Display selected images in a grid
      ScrollView {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(Array(observer.newTraingingSelctedImages.enumerated()), id: \.offset) { index, image in
            ZStack(alignment: .topTrailing) {
              Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(5)

              // Delete button overlay
              Button(action: {
                deleteImage(at: index)
              }) {
                Image(systemName: "xmark.circle.fill")
                  .foregroundColor(Color.basicPrimary)
                  .padding(5)
              }
            }
          }
        }
      }

      NavigationLink(destination: SelectFamilyMember(), label: {
        ButtonDefaultShape(buttonType: .next)
      })

    } .navigationBarTitle("Create Trainging", displayMode: .large)
    .padding()
  }

  func loadImages(from items: [PhotosPickerItem]) async {
    // Filter out items that have already been loaded to avoid duplicates
    let newItems = items.filter { !loadedItems.contains($0) }

    // Append newly selected items to the loadedItems to track them
    loadedItems.append(contentsOf: newItems)

    // Process the new items
    for (index, item) in newItems.enumerated() {
      if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
        observer.newTraingingSelctedImages.append(image)
        itemToImageMap[index] = image  // Track the new image by index
      }
    }
  }

  func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat = 1600) -> UIImage? {
    let size = image.size

    // Check if resizing is needed
    if size.width <= maxDimension && size.height <= maxDimension {
      return image // Return the original image if it's already smaller than the max size
    }

    // Calculate the new size while maintaining aspect ratio
    let aspectRatio = size.width / size.height
    var newSize: CGSize

    if size.width > size.height {
      newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
    } else {
      newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
    }

    // Resize the image
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resizedImage
  }

  func deleteImage(at index: Int) {
    // Remove the corresponding PhotosPickerItem
    observer.newTraingingSelctedImages.remove(at: index)

    /// delete for still selected in media lib
    if index < selectedItems.count {
      selectedItems.remove(at: index)
    }

    // Remove from itemToImageMap to keep things in sync
    itemToImageMap.removeValue(forKey: index)
  }

  func resizeSelectedImages() {
    observer.newTraingingSelctedImages = observer.newTraingingSelctedImages.compactMap { image in
      return resizeImageIfNeeded(image)
    }
  }
}


#Preview {
    CreateTrainging().environmentObject(ObserverModel())
}
