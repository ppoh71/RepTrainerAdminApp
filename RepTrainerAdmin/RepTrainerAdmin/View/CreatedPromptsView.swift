//
//  Prompts.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 19/09/2024.
//

import SwiftUI

struct CreatedPromptsView: View {
  @EnvironmentObject var observer: ObserverModel
  private static let initialColumns = 3
  @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
  @State private var numColumns = initialColumns
  @State private var showDetailSheet: Bool = false
  @State private var detailUrl: URL = URL(string: "https://apple.com")!
  @State private var fixPrompt: String = ""

  func getNumber() -> Int {
    let has = observer.createdPromptsList.count
    let goal = 18
    return (goal - has) > 0 ? (goal - has) : 1
  }

  var body: some View {
    ScrollView(Axis.Set.vertical, showsIndicators: false) {

      Text("We are here")
      
      Spacer().frame(width: 10, height: 60)

      LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: .infinity), spacing: 5)] , spacing: 5) {

        ForEach(observer.createdPromptsList, id: \.self) { savedPrompt in

          GridItemViewPrompts(prompt: savedPrompt)

            .onTapGesture {

              if let url =  URL(string: savedPrompt.imageURL) {
                detailUrl = url
                fixPrompt = savedPrompt.prompt
                print("load urk: \(detailUrl)")
                showDetailSheet = true
              } else {
               print("nope")
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
                if index == 0 && observer.createdPromptsList.count == 0 {
                  Text("No Clones yet")
                }
              }
          }
        }
      }
    }
    .onAppear{
      self.observer.getCreatedPrompts()
    }

    .navigationBarTitle("Saved Photo Copies", displayMode: .inline)

    .sheet(isPresented: $showDetailSheet) {
      SavedPromptDetail(showNavigationSheet: $showDetailSheet, url: $detailUrl, prompt: $fixPrompt )
        .presentationDetents([.large])
    }
  }
}

struct GridItemViewPrompts: View {
  let prompt: CreatedPrompt

  var body: some View {
    // ZStack(alignment: .topTrailing) {
    AsyncImage(url:  URL(string: prompt.imageURL) ) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      //.clipped()
        .clipShape(Circle())
        .aspectRatio(1, contentMode: .fit)

    } placeholder: {
      ZStack{
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

    //  }
  }
}

#Preview {
  SavedFixes().environmentObject(ObserverModel())
}
