//
//  PromptEditor.swift
//  AiCopyImage
//
//  Created by Peter Pohlmann on 12/06/2024.
//

import SwiftUI

struct PromptEditor: View {
  @EnvironmentObject var observer: ObserverModel
  
  @Binding var text: String  // Binding to the text in parent
  @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)  // Tracks cursor range
  @FocusState private var isTextFieldFocused: Bool  // Focus state for the text editor
  @State private var tempText = ""
  @State private var demoModelDict: [String: String] = [:]
  @State private var selectedModel: String = ""
  @State private var isLoading = true

  func loadDemoMOdels() {
    observer.getDemoModels(type: observer.trainerType.rawValue, completion: { (success, demoModels) in
      guard success, let demoModels = demoModels else {
        demoModelDict = [:]
        return
      }
      demoModelDict = demoModels.demoModels

      self.isLoading = false
      if let firstKey = demoModelDict.keys.first {
        observer.selectedDemoModel = firstKey
      }
    })
  }

  var body: some View {
    VStack {
      // Custom TextEditor with cursor management
      CustomTextView(text: $text, selectedRange: $selectedRange)
        .focused($isTextFieldFocused)
        .frame(height:  UIScreen.main.bounds.size.height - 400)
        .padding()
      
        HStack{
          Button(action: {
            insertTextAtCursor(" ###trigger### ")
          }) {
            SmallButtonNoBackground(text: "Add trigger", icon: "text.insert")
          }

          Spacer()

          Button(action: {
            insertTextAtCursor(" ###addition### ")
          }) {
            SmallButtonNoBackground(text: "Add addition", icon: "text.insert")
          }
        }.padding(.horizontal, 20)

        Spacer().frame(width: 10, height: 20)

      VStack{
        HStack{
          SmallButtonNoBackground(text: "Project Target", icon: "target")
          Spacer()
          TrainerTypePicker()
        }.padding(.horizontal, 20)

        HStack{
          SmallButtonNoBackground(text: "Demo Model", icon: "rectangle.portrait.and.arrow.forward.fill")
          Spacer()
          Picker("Select a Model", selection: $observer.selectedDemoModel) {
            // Loop through the demoModels and display each one as an option
            if isLoading {
              Text("Loading...").tag(nil as String?)
            } else {
              ForEach(demoModelDict.keys.sorted(), id: \.self) { key in
                Text(key).tag(key)
                  .font(Font.system(size: 14, weight: .regular))
              }
            }

          }.disabled(isLoading)
          .pickerStyle(MenuPickerStyle())  // Display as a dropdown menu
          .tint(.basicText)
          .onChange(of: observer.trainerType) { oldState, newState in
            // Call action function
            print("Trainer Tyoe is now \(observer.trainerType)")
            isLoading = true
            loadDemoMOdels()
          }
          .onAppear{
            loadDemoMOdels()
          }
        }.padding(.horizontal, 20)
      }.background(Color(UIColor.secondarySystemBackground))
    }

    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        isTextFieldFocused = true  // Focus text editor when the view appears
      }
    }
    .navigationBarTitle("Save & Back")
  }

  // Function to insert text at the cursor position
  func insertTextAtCursor(_ insertText: String) {
    // Ensure the selected range is valid

    guard let range = Range(selectedRange, in: text) else { return }
    tempText = text

    // Insert the text at the cursor position
    tempText = tempText.replacingCharacters(in: range, with: insertText)

    // Update the cursor position after insertion
    selectedRange = NSRange(location: selectedRange.location + insertText.count, length: 0)

    text = tempText
  }



//  var body: some View {
//    VStack {
//      TextEditor(text: $text)
//        .focused($isTextFieldFocused)
//        .font(.title3.weight(.bold))
//        .background(Color(UIColor.systemGray6))
//        .padding()
//
//    }.onAppear{
//      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//        isTextFieldFocused = true
//      }
//
//    }.navigationBarTitle("Save & Back")
//  }
}


#Preview {
  PromptEditor(text: .constant("Thsi si sa test text ")).environmentObject(ObserverModel())
}
