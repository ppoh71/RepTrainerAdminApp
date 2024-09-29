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
  @State private var docId: String = "test"
  @State private var options: [String] = [String]()
  @State private var isEditingOrder: Bool = false

  func getNumber() -> Int {
    let has = observer.createdPromptsList.count
    let goal = 18
    return (goal - has) > 0 ? (goal - has) : 1
  }

  func moveItem(in array: [(key: String, value: CreatedPrompt)], from source: IndexSet, to destination: Int) {
    var updatedArray = array
    updatedArray.move(fromOffsets: source, toOffset: destination)

    // Update the dictionary with new sort orders
    for (index, element) in updatedArray.enumerated() {
      let key = element.key
      observer.createdPromptsList[key]?.sortOrder = index

      guard let promptKey = observer.createdPromptsList[key] else {print("ni key"); return }
      print("move item: \(key) newOrder: \(index)")
      FirebaseService.updateSortOrderForPrompt(db: observer.db, documentID: key, type: observer.trainerType.rawValue, newOrder: index)
    }
  }

  var body: some View {

    VStack{
      Button(action: {
        isEditingOrder.toggle()
      }) {
        Text(isEditingOrder ? "Done Editing" : "Edit Order")
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }

      Spacer().frame(width: 10, height: 60)

      if isEditingOrder {
        List {
          ForEach(Array(observer.createdPromptsList), id: \.key) { (documentID, savedPrompt) in
            HStack{
              GridItemViewPrompts(prompt: savedPrompt)
                .frame(width: 90, height: 90)

              Spacer()

              Image(systemName: "chevron.up.chevron.down")
                .foregroundColor(Color.basicText)
                .font(Font.system(size: 20, weight: .regular))
            }
          }
          .onMove(perform: { indices, newOffset in
            moveItem(in: Array(observer.createdPromptsList), from: indices, to: newOffset)
          })
        }
      }

      if !isEditingOrder {
        ScrollView(Axis.Set.vertical, showsIndicators: false) {
          LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: .infinity), spacing: 5)] , spacing: 5) {
            ForEach(Array(observer.createdPromptsList), id: \.key) { (documentID, savedPrompt) in
              GridItemViewPrompts(prompt: savedPrompt)
                .onTapGesture {
                  print("doc \(documentID)")
                  if let url =  URL(string: savedPrompt.imageURL) {
                    print("url ok ")

                    docId = documentID
                    detailUrl = url
                    fixPrompt = savedPrompt.prompt
                    options = savedPrompt.options ?? ["No options"]
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
      }
    }
    .navigationBarTitle("Saved Photo Copies", displayMode: .inline)

    .sheet(isPresented: $showDetailSheet) {
      SavedPromptDetail(showNavigationSheet: $showDetailSheet, url: $detailUrl, prompt: $fixPrompt, docId: $docId, options: $options )
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
