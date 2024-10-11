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
  @Binding var docId: String
  @Binding var options: [String]
  @State private var downloalImage = Image(uiImage: UIImage())
  @State private var showDownload: Bool = false
  @State private var showDeleteSheet: Bool = false
  @State private var downloadesUIImage: UIImage = UIImage()
  @State private var downloadedUIImageState: Bool = false

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
  }

  func setDownloadImage(image: Image) {
    downloalImage = image
    showDownload = true
  }

  func deletePrompt() {
    FirebaseService.deletePrompt(db: observer.db, type: observer.trainerType.rawValue, documentID: docId) { result in
      switch result {
      case .success:
        print("Prompt deleted successfully")
      case .failure(let error):
        print("Error deleting prompt: \(error.localizedDescription)")
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

          Text("Options")
            .font(.body.weight(.bold))
            .foregroundStyle(Color.basicText)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

          HStack{
            ForEach(options, id: \.self) { option in

              Text(option)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .font(.body)
                .foregroundColor(Color.white)
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

          Text(prompt)
            .font(.body.weight(.regular))
            .foregroundStyle(Color.basicText)
            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)

          let prompt =  prompt
          ShareLink(item: prompt) {
            SmallButtonNoBackground(text: "Copy/Share", icon: "doc.on.doc")
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
    }.confirmationDialog("Delete Prompt ?", isPresented: $showDeleteSheet, titleVisibility: .visible) {
      Button("Yes") {
       deletePrompt()
      }
    }

  }
}

#Preview {
  SavedPromptDetail(showNavigationSheet: .constant(true), url: .constant(URL(string: "https://apple.com")!), prompt: .constant("A majestic waterfall in a rugged landscape captured early in the morning at a remote, mountainous location. The waterfall is large, cascading dramatically from a steep cliff and is surrounded by lush, green vegetation. The foreground is dominated by young, leafy plants and moss, with fine mist rising from the foot of the waterfall. The perspective is a side view, emphasizing the scale of the waterfall and the intricacy of the surrounding vegetation. The scene is bathed in soft, morning light, creating a warm glow and putting the spotlight on the rising mist. The style is reminiscent of realistic nature photography, with a high dynamic range and sharp focus on both the foreground and waterfall. As a bonus, light rays break through the mist, adding an ethereal quality to the setting."), docId: .constant("asas"), options: .constant(["String", "String2", "String3"])).environmentObject(ObserverModel())
}

