//
//  FixView.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 02/03/2024.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct FixView: View {
  @EnvironmentObject var observer: ObserverModel


  var isPreview: Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }

  var body: some View {
    ScrollViewReader { value in
      ScrollView(Axis.Set.vertical, showsIndicators: false) {

        // MARK: No Photo selected
        VStack{

          Spacer().frame(width: 10, height: 100)
            .id(1)


          // MARK:  Nothing Selected View
          if observer.fixAction == .none {
            FixViewProgressStart()
          }

          // MARK: Photo selected, progress
          if observer.fixAction != .none && observer.fixAction != .fixFinished &&  observer.fixAction != .fixTimeOut {
            FixViewProgressSelected()
          }

          // MARK: /// Fix Ready, Show Swipe
          if observer.fixAction != .none && observer.fixAction == .fixFinished {
            FixViewProgressReady()
          }

          if observer.fixAction != .none && observer.fixAction == .fixTimeOut {
            FixViewTimeOut()
          }

        }
      }
    }
    .onAppear{ // DEBUG ********************
      if isPreview {
        observer.fixAction = .fixFinished
        observer.selectedFix = .one
      }
    }

    .navigationBarTitle("Prompt Generator", displayMode: .inline)
    .edgesIgnoringSafeArea(.all)
  }
}

struct FixViewProgressStart: View {
  @EnvironmentObject var observer: ObserverModel
  @State private var showPromtpInputSheet: Bool = false

  var body: some View {
    VStack{
      ZStack{
        Rectangle()
          .fill(Color(UIColor.secondarySystemBackground))
          .cornerRadius(20)

        VStack{
          Spacer().frame(width: 10, height: 170)

          Image(systemName: "photo.on.rectangle.angled")
            .foregroundColor(Color.basicText.opacity(0.5))
            .font(Font.system(size: 180, weight: .thin))
            .frame(height: 80)

          Spacer().frame(width: 10, height: 170)
        }
      }.padding(20)

      Spacer().frame(width: 10, height: 20)

      PhotosPicker(selection: $observer.imageSelection,
                   matching: .images,
                   photoLibrary: .shared()) {
        ButtonDefaultShape(buttonType: .addPhotos)
      }

      Spacer().frame(width: 10, height: 30)

      Button(action: {
        showPromtpInputSheet = true
      }) {
        ButtonDefaultShape(buttonType: .promptInput)
      }

    } .sheet(isPresented: $showPromtpInputSheet) {
      PromptInput(showPromtpInputSheet: $showPromtpInputSheet)
        .presentationDetents([.large])
    }
  }
}

struct FixViewProgressSelected: View {
  @EnvironmentObject var observer: ObserverModel

  var body: some View {

    if observer.fixAction == .fixInProgress {
      ZStack{
        PickerImageView(imageState: observer.imageState)
          .mask(
            Circle() // Masking the image with a circle
              .frame(width: UIScreen.main.bounds.size.width - 50, height: UIScreen.main.bounds.size.width - 50)
          )

        CircleOpacityBackgroundView(circleSize:  UIScreen.main.bounds.size.width - 30)
        EnhancedShazamLikeAnimationView()
        //SpinningCircleProgressView(circleSize: UIScreen.main.bounds.size.width - 40)
      }
    } else {
      PickerImageView(imageState: observer.imageState)
    }

    /// Progress Text Disaply
    if observer.fixAction == .fixInProgress {
      TimedTextView()
        .frame( height: 60)

      Spacer().frame(width: 10, height: 100)
    }

    /// Show Action Button
    if observer.fixAction == .imageSelected {

      Button(action: {
        observer.startRequest()
      }) {
        VStack{
          Spacer().frame(width: 10, height: 50)
          ButtonDefaultShape(buttonType: .fixUpscxape)
            .scaleEffect(1.3)
        }
      }


      Spacer().frame(width: 10, height: 50)

      PhotosPicker(selection: $observer.imageSelection,
                   matching: .images,
                   photoLibrary: .shared()) {
        SmallButton(text: "Select other Photo", icon: "photo.on.rectangle.angled")
      }

      Spacer().frame(width: 10, height: 50)

    }
  }
}

struct FixViewProgressReady: View {
  @EnvironmentObject var observer: ObserverModel
  @State private var showCopiedText: Bool = false
  @State private var showPromtpEditorSheet: Bool = false
  @State private var showPromtpInputSheet: Bool = false

  func getImage() -> Image {
    if let image = observer.fixModel.fixedimage {
      return Image(uiImage: image)
    } else {
      return Image(uiImage: UIImage(named: "bird-2") ?? UIImage())
    }
  }


  var body: some View {

    VStack{

      VStack{
        Spacer().frame(width: 10, height: 20)

        HStack{
          Spacer().frame(width: 30, height: 10)

          Button(action: {
            showPromtpInputSheet = true
          }) {
            SmallButton(text: "New from Prompt", icon: "photo.on.rectangle.angled")
          }

          Spacer()

          PhotosPicker(selection: $observer.imageSelection,
                       matching: .images,
                       photoLibrary: .shared()) {
            SmallButton(text: "New from Image", icon: "photo.on.rectangle.angled")

          }
          Spacer().frame(width: 30, height: 10)
        }

        Spacer().frame(width: 10, height: 20)

        BubbleReadyView(cloneImage: Image(uiImage:  observer.fixModel.baseImage ?? UIImage()), originalImage: Image(uiImage:  observer.fixModel.originalImage))
          .frame(height:  UIScreen.main.bounds.size.width + 120)
          .clipped()

        Spacer().frame(width: 10, height: 20)

        HStack{
          Button(action: {
            observer.startBaseImageGeneration()
            observer.fixModel.baseImage = UIImage()
          }) {
            SmallButtonNoBackground(text: "Re-Run Base Image", icon: "play")
          }
          if observer.isLoading {
            ProgressView()
          }
        }

        Spacer().frame(width: 10, height: 40)

        Text(observer.fixModel.prompt)
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
          .font(.body)
          .foregroundColor(Color.white)
          .padding(20)
        
          .onTapGesture {
            showPromtpEditorSheet = true
          }

        Spacer().frame(width: 10, height: 30)

        RunDemoModel()

      }
      Spacer().frame(width: 10, height: 30)

      Spacer().frame(width: 10, height: 130)
    }
    .sheet(isPresented: $showPromtpEditorSheet) {
      PromptEditor(showPromtpEditorSheet: $showPromtpEditorSheet, text:  $observer.fixModel.prompt)
        .presentationDetents([.large])
    }

    .sheet(isPresented: $showPromtpInputSheet) {
      PromptInput(showPromtpInputSheet: $showPromtpInputSheet)
        .presentationDetents([.large])
    }

  }
}

struct FixViewTimeOut: View {
  @EnvironmentObject var observer: ObserverModel

  var body: some View {

    VStack{

      Image(systemName: "shield.lefthalf.filled.trianglebadge.exclamationmark")
        .foregroundColor(Color.basicText)
        .font(Font.system(size: 100, weight: .regular))

      Spacer().frame(width: 10, height: 50)


#if targetEnvironment(simulator)

      Spacer().frame(width: 10, height: 20)
      Text("The Device Check Failed. Please use a real device and not the simulator.")
        .font(Font.system(size: 16, weight: .regular))
        .foregroundColor(Color.red)
        .multilineTextAlignment(.center)

      Spacer().frame(width: 10, height: 50)

      Button(action: {
        observer.startNewRequest()
      }) {
        ButtonDefaultShape(buttonType: .cancel)
      }

#else

      Text("Something went wrong.")
        .font(Font.system(size: 20, weight: .bold))
        .foregroundColor(Color.basicText)
        .multilineTextAlignment(.center)

      Spacer().frame(width: 10, height: 30)

      Text("The operation may timed out. Once completed, the final image will be available in your history.")
        .font(Font.system(size: 16, weight: .regular))
        .foregroundColor(Color.basicText)
        .multilineTextAlignment(.center)

      Button(action: {
        observer.currentPath = .savedFixes
      }) {
        ButtonDefaultShape(buttonType: .goHistory)
      }

      Spacer().frame(width: 10, height: 60)

      Text("Start a new process.")
        .font(Font.system(size: 16, weight: .regular))
        .foregroundColor(Color.basicText)
        .multilineTextAlignment(.center)

      Button(action: {
        observer.startNewRequest()
      }) {
        ButtonDefaultShape(buttonType: .fixUpscxape)
      }


#endif


      Spacer().frame(width: 10, height: 50)

    }.padding(.horizontal, 60)
  }
}


struct FixImageInfos: View {
  @EnvironmentObject var observer: ObserverModel

  @State private var creativity : Double = 0
  @State private var resemblance : Double = 0
  @State private var scale : Double = 0
  @State private var dimension = ""
  @State private var size = ""
  @State private var fileType = ""

  @State private var show: Bool = false

  let fixId: String

  func getInfos() {

    if let fix = FileOps.getFixJsonById(id: fixId) {
      dimension = fix.dimenson
      size = fix.size
      fileType = fix.fileType

      show = true
    }
  }

  var body: some View {
    HStack{
      Spacer().frame(width: 30, height: 30)

      VStack(alignment: .leading){
        Text("Creativity: \(String(format: "%.2f", creativity) )")
        Text("Resemblance: \(String(format: "%.2f", resemblance) )")
        Text("Scale: \(scale.asInteger)x ")
      }

      Spacer()

      VStack(alignment: .leading){
        Text("Dimension: \(dimension)")
        Text("Size: \(size)")
        Text("FileType: \(fileType)")
      }
      Spacer().frame(width: 30, height: 30)
    }
    .font(.footnote.weight(.regular))
    .foregroundStyle(Color.basicText)

    .opacity(show ? 0.8 : 0)
    .onAppear{
      getInfos()
    }
  }
}

#Preview {
  FixView().environmentObject(ObserverModel())
}
