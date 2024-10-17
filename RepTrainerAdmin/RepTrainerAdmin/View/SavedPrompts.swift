//
//  Prompts.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 19/09/2024.
//

import SwiftUI

struct SavedPromptsView: View {
  @EnvironmentObject var observer: ObserverModel
  private static let initialColumns = 3
  @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
  @State private var numColumns = initialColumns
  @State private var showDetailSheet: Bool = false
  @State private var detailUrl: URL = URL(string: "https://apple.com")!
  @State private var fixPrompt: String = ""
  @State private var requestId: String = ""
  @State private var options: [String] = [String]()
  @State private var isEditingOrder: Bool = false
  @State private var selectedOptions: [String] = []

  func getNumber() -> Int {
    let has = observer.createdPromptsList.count
    let goal = 18
    return (goal - has) > 0 ? (goal - has) : 1
  }

  func moveItemAndUpdateFirestore(fromOffsets indices: IndexSet, toOffset newOffset: Int) {
    observer.createdPromptsList.move(fromOffsets: indices, toOffset: newOffset)
    for (index, prompt) in observer.createdPromptsList.enumerated() {
      let newSortOrder = index // The new index is the new sortOrder
      let documentId = prompt.id // Assuming `id` contains the Firestore document ID
      FirebaseService.updateSortOrderForPrompt(db: observer.db, documentID: documentId, type: observer.trainerType.rawValue, newOrder: newSortOrder)
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

  func displayFromPromptOptions(promptOptions: [String]?) -> Bool {
    guard let promptOptions = promptOptions else {print("No prompt options"); return true}
    guard selectedOptions.count > 0  else {print("No options selected"); return true}
    let commonStrings = promptOptions.filter { selectedOptions.contains($0) }
    return commonStrings.count > 0 ? true : false
  }

  var body: some View {

    VStack{
      HStack{
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
//        Button(action: {
//          isEditingOrder.toggle()
//        }) {
//          Text(isEditingOrder ? "Done Editing" : "Edit Order")
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//        }
      }

      Spacer().frame(width: 10, height: 60)

      if isEditingOrder {

        List {
          ForEach(observer.createdPromptsList.indices, id: \.self) { index in
            let prompt = observer.createdPromptsList[index]
            HStack{
              GridItemViewPrompts(prompt: prompt)
                .frame(width: 90, height: 90)
              Spacer()
              Image(systemName: "chevron.up.chevron.down")
                .foregroundColor(Color.basicText)
                .font(Font.system(size: 20, weight: .regular))
            }
          }
          .onMove(perform: { indices, newOffset in
            moveItemAndUpdateFirestore(fromOffsets: indices, toOffset: newOffset)
          })
        }
      }

      if !isEditingOrder {
        ScrollView(Axis.Set.vertical, showsIndicators: false) {
          LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: .infinity), spacing: 5)] , spacing: 5) {
            ForEach( observer.createdPromptsList, id: \.self ) { prompt in
              if displayFromPromptOptions(promptOptions: prompt.options) {
                GridItemViewPrompts(prompt: prompt)
                  .onTapGesture {
                    print("doc \(prompt.id)")
                    if let url =  URL(string: prompt.imageURL) {
                      print("url ok ")

                      requestId = prompt.id
                      detailUrl = url
                      fixPrompt = prompt.prompt
                      options = prompt.options ?? ["No options"]
                      showDetailSheet = true
                    } else {
                      print("nope")
                    }
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
      }
    }.onAppear{
      self.observer.getCreatedPrompts()
    }
    .navigationBarTitle("Saved Photo Copies (\(observer.createdPromptsList.count))", displayMode: .inline)

    .sheet(isPresented: $showDetailSheet) {
      SavedPromptDetail(showNavigationSheet: $showDetailSheet, url: $detailUrl, prompt: $fixPrompt, options: $options, requestId: $requestId )
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
