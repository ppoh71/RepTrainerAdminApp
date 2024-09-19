//
//  SavedFixes.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 17/05/2024.
//

import SwiftUI

struct SavedFixes: View {
  @EnvironmentObject var observer: ObserverModel
  private static let initialColumns = 3
  @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
  @State private var numColumns = initialColumns
  @State private var showDetailSheet: Bool = false
  @State private var detailUrl: URL = URL(string: "https://apple.com")!
  @State private var thumbForDetail: UIImage = UIImage()
  @State private var fixId: String = ""
  @State private var fixPrompt: String = ""

  func checkForRequest(fixId: String) {
    print("Get putput from Firebase !!!")

    /// get app config data
    observer.getRequestOutput(requestId: fixId, completion: { (success, output) in
      print("Get putput get Sucess: \(success) ")
      print("Get putput get output: \(output) ")

    })
  }

  func getNumber() -> Int {
    let has = observer.savedFixes.count
    let goal = 18
    return (goal - has) > 0 ? (goal - has) : 1
  }

  var body: some View {
    ScrollView(Axis.Set.vertical, showsIndicators: false) {

      Spacer().frame(width: 10, height: 60)

      LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: .infinity), spacing: 5)] , spacing: 5) {

        ForEach(observer.savedFixes, id: \.self) { fix in

          GridItemView(fix: fix)

            .onTapGesture {

              if let url =  URL(string: fix.fixURL) {
                detailUrl = fix.getFullImageURL()
                thumbForDetail = fix.getThumbnail() ?? UIImage()
                fixId = fix.id
                fixPrompt = fix.prompt
                print("load urk: \(detailUrl)")
                showDetailSheet = true
              } else {
                checkForRequest(fixId: fix.id)
              }

            }
        }

        if getNumber() > 0 {
          ForEach(0..<getNumber(), id: \.self) { index in
            Circle()
              .fill(Color(UIColor.secondarySystemBackground))
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
              .clipped()
              .aspectRatio(1, contentMode: .fit)
              .overlay{
                if index == 0 && observer.savedFixes.count == 0 {
                  Text("No Clones yet")
                }
              }
          }
        }
      }
    }
    .onAppear{
        self.observer.readSavedFixes() 
    }

    .navigationBarTitle("Saved Photo Copies", displayMode: .inline)

    .sheet(isPresented: $showDetailSheet) {
      SavedFixDetail(showNavigationSheet: $showDetailSheet, url: $detailUrl, thumbnail: $thumbForDetail, fixId: $fixId, prompt: $fixPrompt )
          .presentationDetents([.large])
      }
  }
}

struct GridItemView: View {
  let fix: FixJson

  var body: some View {
    // ZStack(alignment: .topTrailing) {
    AsyncImage(url: fix.getThumbnailURL()) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        //.clipped()
        .clipShape(Circle())
        .aspectRatio(1, contentMode: .fit)

    } placeholder: {
      ZStack{
        
        if fix.howOld() > 800 {

          Image(uiImage: UIImage())
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipped()
            .aspectRatio(1, contentMode: .fit)

          Text("Failed")
            .font(Font.system(size: 10, weight: .regular))
            .foregroundColor(Color.basicText)
            .offset()

        } else {
          ProgressView()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipped()
            .aspectRatio(1, contentMode: .fit)

          Text("Processing...")
            .font(Font.system(size: 10, weight: .regular))
            .foregroundColor(Color.basicText)
            .offset(y: 20 )
        }
      }
    }

    //  }
  }
}

#Preview {
  SavedFixes().environmentObject(ObserverModel())
}
