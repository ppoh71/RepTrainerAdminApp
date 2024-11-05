//
//  PromptEditor.swift
//  AiCopyImage
//
//  Created by Peter Pohlmann on 12/06/2024.
//

import SwiftUI

struct PromptEditor: View {
  @EnvironmentObject var observer: ObserverModel
  @Binding var showPromtpEditorSheet: Bool

  @Binding var text: String  // Binding to the text in parent
  @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)  // Tracks cursor range
  @FocusState private var isTextFieldFocused: Bool  // Focus state for the text editor
  @State private var tempText = ""

  var body: some View {
    VStack {

//        HStack{
//          Spacer().frame(width: 30, height: 30)
//          
//          Button(action: {
//            isTextFieldFocused = false
//          }) {
//            SmallButtonNoBackground(text: "Close keyboard", icon: "keyboard")
//          }.opacity(isTextFieldFocused ? 1 : 0.3)
//
//          Spacer()
//
//          Button(action: {
//            showPromtpEditorSheet = false
//          }) {
//            Image(systemName: "xmark")
//              .foregroundColor(Color.basicText)
//              .font(Font.system(size: 30, weight: .regular))
//          }
//
//          Spacer().frame(width: 30, height: 30)
//        }


      Spacer().frame(width: 30, height: 20)

      HStack{
        Button(action: {
          insertTextAtCursor(" ###trigger### ")
        }) {
          SmallButtonNoBackground(text: "Trigger", icon: "arrow.right")
            .scaleEffect(1.3)
        }

        Spacer()

        Button(action: {
          insertTextAtCursor(" ###addition### ")
        }) {
          SmallButtonNoBackground(text: "Addition", icon: "arrow.right")
            .scaleEffect(1.3)
        }

        Spacer()

        Button(action: {
          insertTextAtCursor("w###age###")
        }) {
          SmallButtonNoBackground(text: "Age", icon: "arrow.right")
            .scaleEffect(1.3)
        }

      }.padding(.horizontal, 20)


      Spacer().frame(width: 120, height: 50)

      // Custom TextEditor with cursor management
      CustomTextView(text: $text, selectedRange: $selectedRange)
        .focused($isTextFieldFocused)
        .padding(.horizontal, 20)
        .border(.basicText)
        .cornerRadius(3)

        Spacer().frame(width: 10, height: 40)
    }

    .onAppear {
//      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//        isTextFieldFocused = true  // Focus text editor when the view appears
//      }
    }

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
  PromptEditor(showPromtpEditorSheet: .constant(true), text: .constant("A cascading waterfall over moss-covered rocks. The water flows smoothly and rapidly, creating a serene yet powerful scene. The background is a natural rocky terrain. The rocks are coated with vibrant green moss, contrasting with the grey and black tones of the wet rocks. The image is captured with a close-up angle, focusing on the details of the water splashing over the rocks. Lighting is natural, highlighting the texture of the moss and the movement of the water. The style is realistic and nature-focused, capturing the essence of a tranquil waterfall in the wilderness.")).environmentObject(ObserverModel())
}
