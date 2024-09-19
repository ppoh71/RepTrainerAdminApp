//
//  Components.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 04/03/2024.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct Components: View {
  @EnvironmentObject var observer: ObserverModel

    var body: some View {
      VStack{
        SmallButton(text: "Some Text", icon: "arrow.left")
        Zoom()
        BeforeAfter(text: "Original")
        PickerImageView(imageState: .success(UIImage()))
        ButtonDefaultShape(buttonType: .addPhotos)
        PickerImageView(imageState: observer.imageState)
      }
    }
}

struct Zoom: View {

  var body: some View {
    HStack(alignment: .top, spacing: 3){

      Image(systemName: "plus.magnifyingglass")
        .foregroundStyle(Color.white)
        .font(Font.system(size: 10, weight: .bold))

      Text("Zoom")
        .foregroundStyle(Color.white)
        .font(Font.system(size: 10, weight: .bold))
    }
    .padding(5)
    .background(Color.black)
    .cornerRadius(5)
  }
}

struct PickerImageView: View {
  let imageState: ImageState

  var body: some View {
    switch imageState {
    case .success(let uiImage):

      //Image("flamingo")
      Image(uiImage: uiImage)
        //.resizable()
        //.scaledToFit()
        //.frame(height: 400)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: UIScreen.main.bounds.size.width - 3, height: UIScreen.main.bounds.size.width - 3)
        .clipShape(Circle())

      // .frame(width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.width) * Constants.heightMultiplier)

    case .loading:
      ProgressView()
    case .empty:
      Spacer()
    case .failure:
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 40))
        .foregroundColor(.white)
    }
  }
}

enum ButtonType {
  case addPhotos
  case fixUpscxape
  case redo
  case newFix
  case cancel
  case goHistory
  case download
}

struct ButtonDefaultShape: View {
  let buttonType: ButtonType

  var icon: (String, String) {
    switch buttonType {

    case .addPhotos:
      return ("plus", "Upload your photo")
    case .fixUpscxape:
      return ("arrow.circlepath", "Start Cloning")
    case .redo:
      return ("arrow.triangle.2.circlepath", "Try Again")
    case .newFix:
      return ("plus", "New Clone")
    case .cancel:
      return ("xmark", "Cancel")
    case .goHistory:
      return ("square.stack.3d.down.right", "Got to History")
    case .download:
      return ("arrow.down.square", "Download")
    }
  }

  var body: some View {
    HStack(alignment: .top){
      Image(systemName: icon.0)
        .foregroundColor(Color.basicText)
        .font(Font.system(size: 18, weight: .black))

      Text(icon.1)
        .foregroundStyle(Color.basicText)
        .font(Font.system(size: 18, weight: .black))
    }
    .padding(10)
    .background(Color.basicPrimary)
    .cornerRadius(10)

  }
}


struct BeforeAfter: View {
  let text: String

  var body: some View {
    HStack(alignment: .top){

      Text(text)
        .foregroundStyle(Color.basicText)
        .font(Font.system(size: 10, weight: .bold))
    }
    .padding(5)
    .background(Color.basicBackground)
    .cornerRadius(5)
  }
}


struct SmallButton: View {
  let text: String
  let icon: String

  var body: some View {
    HStack(alignment: .center, spacing: 5){

      Image(systemName: icon)
        .foregroundStyle(Color.basicText)
        .font(Font.system(size: 12, weight: .bold))

      Text(text)
        .foregroundStyle(Color.basicText)
        .font(Font.system(size: 12, weight: .bold))
    }

  }
}

struct SmallButtonNoBackground: View {
  let text: String
  let icon: String

  var body: some View {
    HStack(alignment: .center, spacing: 5){
      Image(systemName: icon)

      Text(text)
    } 
    .font(Font.system(size: 14, weight: .regular))
    .foregroundStyle(Color.basicText)
    .padding(5)

  }
}

#Preview {
  Components().environmentObject(ObserverModel())
}
