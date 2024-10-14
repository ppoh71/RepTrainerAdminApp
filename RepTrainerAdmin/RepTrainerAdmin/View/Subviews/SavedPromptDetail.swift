//
//  SavedPromptDetail.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 20/09/2024.
//

//
//  SavedFixDetail.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 17/05/2024.
//

import SwiftUI
import Zoomable

struct SavedPromptDetail: View {
  @EnvironmentObject var observer: ObserverModel
  
  @Binding var showNavigationSheet: Bool
  @Binding var url: URL
  @Binding var prompt: String
  @Binding var options: [String]
  @Binding var requestId: String
  @State private var downloalImage = Image(uiImage: UIImage())
  @State private var showDownload: Bool = false
  @State private var showDeleteSheet: Bool = false
  @State private var downloadesUIImage: UIImage = UIImage()
  @State private var downloadedUIImageState: Bool = false
  @FocusState private var isTextFieldFocused: Bool
  @State private var selectedOptions: [String] = []
  @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)  // Tracks cursor range

  func  startDownload() {
    _ = Task {
      await downloadUIImage()
    }
  }

  func downloadUIImage() async {
    do {
        if let image = try await FileOps.downloadImage(from: url) {
          print("Download uiimage ok")
          downloadesUIImage = image
          downloadedUIImageState = true
        }
    } catch {
      print("Error downloaded imgae")
      downloadedUIImageState = false
    }
  }

  func setForFix() {
    if let userId = Utils.getUserId()  {
      observer.fixModel = FixModel(requestId: UUID().uuidString, userId: userId, originalImage: downloadesUIImage, baseImage: downloadesUIImage, prompt: prompt)
      observer.fixAction = .fixFinished
      observer.currentPath = .fix
    }
    observer.selectedOptions = options
  }

  func setDownloadImage(image: Image) {
    downloalImage = image
    showDownload = true
  }

  func deletePrompt() {
    FirebaseService.deletePrompt(db: observer.db, type: observer.trainerType.rawValue, documentID: requestId) { result in
      switch result {
      case .success:
        print("Prompt deleted successfully")
      case .failure(let error):
        print("Error deleting prompt: \(error.localizedDescription)")
      }
    }
  }

  func toggleOption(_ option: PromptOptions) {
    if let index = selectedOptions.firstIndex(of: option.rawValue) {
      selectedOptions.remove(at: index)  // Remove if already selected
    } else {
    selectedOptions.append(option.rawValue)  // Add if not selected
    }
  }

  func isSelected(_ option: PromptOptions) -> Bool {
    selectedOptions.contains(option.rawValue)
  }

  func updatePrompt() {
    FirebaseService.updatePromptAndOptions(db: observer.db, documentID: requestId, type: observer.trainerType.rawValue, newPrompt: prompt, newOptions: selectedOptions) { error in
      if let error = error {
        print("Error updating prompt and options: \(error.localizedDescription)")
      } else {
        print("Prompt and options updated successfully")
      }
    }

  }


  var body: some View {
    ScrollView(Axis.Set.vertical, showsIndicators: false) {

      VStack{

        Spacer().frame(width: 10, height: 30)

        HStack{
          Spacer()
          Button(action: {
            showNavigationSheet = false
          }) {
            Image(systemName: "xmark")
              .foregroundColor(Color.basicText)
              .font(Font.system(size: 30, weight: .regular))
          }

          Spacer().frame(width: 10, height: 10)
        }

        Spacer().frame(width: 10, height: 60)

        AsyncImage(url: url) { image in

          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.size.width - 3, height: UIScreen.main.bounds.size.width - 3 )
            .clipShape(Circle())
            .clipped()
            .onAppear{
              setDownloadImage(image: image)
            }
            .zoomable()

        } placeholder: {

          ZStack{
            LoadingImageProgressSaved()
          }
        }

        Spacer().frame(width: 10, height: 30)


        Button(action: {
          setForFix()
        }) {
          ButtonDefaultShape(buttonType: .gotoFix)
        }
          .opacity(downloadedUIImageState ? 1 : 0.5)

        if showDownload {

          Spacer().frame(width: 10, height: 30)

          ShareLink(item: downloalImage, preview: SharePreview("Image Copy", image: downloalImage)) {
            HStack{
              Image(systemName: "arrow.down.square")
                .foregroundColor(Color.basicText)
                .font(Font.system(size: 25, weight: .bold))

              Text("Download")
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .font(Font.system(size: 25, weight: .bold))
                .foregroundColor(Color.basicText)
            }
          }

          Spacer().frame(width: 10, height: 30)


          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              Spacer().frame(width: 10, height: 20)
              ForEach(PromptOptions.allCases) { option in
                Button(action: {
                  toggleOption(option)
                }) {
                  Text(option.rawValue.capitalized)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(isSelected(option) ? Color.basicPrimary : Color.basicBackground)
                    .foregroundColor(.basicText)
                    .cornerRadius(8)
                }
              }
              Spacer().frame(width: 10, height: 20)
            }
          }

          Spacer().frame(width: 10, height: 30)

          Text("Pompt")
            .font(.body.weight(.bold))
            .foregroundStyle(Color.basicText)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)


          CustomTextView(text: $prompt, selectedRange: $selectedRange)
            .focused($isTextFieldFocused)
            .padding(.horizontal, 20)
            .frame(width: UIScreen.main.bounds.size.width - 10, height: 300)
            .border(.basicText)
            .cornerRadius(3)

          Spacer().frame(width: 10, height: 40)

          Button(action: {
            updatePrompt()
          }) {
            SmallButtonNoBackground(text: "Update Prompt", icon: "doc.on.doc")
              .scaleEffect(1.1)
          }


          Spacer().frame(width: 10, height: 40)

          Button(action: {
            showDeleteSheet = true
          }) {
            SmallButtonNoBackground(text: "Delete Prompt?", icon: "minus.circle")
          }

        }

      }
    }.onAppear{
      print("appear \(url)")
      startDownload()
      selectedOptions = options
    }.confirmationDialog("Delete Prompt ?", isPresented: $showDeleteSheet, titleVisibility: .visible) {
      Button("Yes") {
       deletePrompt()
      }
    }

  }
}

#Preview {
  SavedPromptDetail(showNavigationSheet: .constant(true), url: .constant(URL(string: "https://apple.com")!), prompt: .constant("A majestic waterfall in a rugged landscape captured early in the morning at a remote, mountainous location. The waterfall is large, cascading dramatically from a steep cliff and is surrounded by lush, green vegetation. The foreground is dominated by young, leafy plants and moss, with fine mist rising from the foot of the waterfall. The perspective is a side view, emphasizing the scale of the waterfall and the intricacy of the surrounding vegetation. The scene is bathed in soft, morning light, creating a warm glow and putting the spotlight on the rising mist. The style is reminiscent of realistic nature photography, with a high dynamic range and sharp focus on both the foreground and waterfall. As a bonus, light rays break through the mist, adding an ethereal quality to the setting."), options: .constant(["String", "String2", "String3"]), requestId: .constant("")).environmentObject(ObserverModel())
}

