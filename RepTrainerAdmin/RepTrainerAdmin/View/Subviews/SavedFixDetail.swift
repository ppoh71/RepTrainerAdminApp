//
//  SavedFixDetail.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 17/05/2024.
//

import SwiftUI
import Zoomable

struct SavedFixDetail: View {
  @Binding var showNavigationSheet: Bool
  @Binding var url: URL
  @Binding var thumbnail: UIImage
  @Binding var fixId: String
  @Binding var prompt: String

  @State private var downloalImage = Image(uiImage: UIImage())
  @State private var showDownload: Bool = false

  func setDownloadImage(image: Image) {
    downloalImage = image
    showDownload = true
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
              Image(uiImage: thumbnail)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.size.width)

             LoadingImageProgressSaved()
            }
          }

          if showDownload {

            Spacer().frame(width: 10, height: 30)

            ShareLink(item: downloalImage, preview: SharePreview("Inage Copy", image: downloalImage)) {
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

            Spacer().frame(width: 10, height: 60)
          }

        }
      }.onAppear{
        print("appear \(url)")
      }

    }
}

#Preview {
  SavedFixDetail(showNavigationSheet: .constant(true), url: .constant(URL(string: "https://apple.com")!), thumbnail: .constant(UIImage(named: "flamingo")!), fixId: .constant("xxx"), prompt: .constant("A majestic waterfall in a rugged landscape captured early in the morning at a remote, mountainous location. The waterfall is large, cascading dramatically from a steep cliff and is surrounded by lush, green vegetation. The foreground is dominated by young, leafy plants and moss, with fine mist rising from the foot of the waterfall. The perspective is a side view, emphasizing the scale of the waterfall and the intricacy of the surrounding vegetation. The scene is bathed in soft, morning light, creating a warm glow and putting the spotlight on the rising mist. The style is reminiscent of realistic nature photography, with a high dynamic range and sharp focus on both the foreground and waterfall. As a bonus, light rays break through the mist, adding an ethereal quality to the setting."))
}
