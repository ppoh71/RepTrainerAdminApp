//
//  PromptInput.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 12/10/2024.
//

import SwiftUI

struct PromptInput: View {
  @EnvironmentObject var observer: ObserverModel
  @Binding var showPromtpInputSheet: Bool

  @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)  // Tracks cursor range
  @FocusState private var isTextFieldFocused: Bool  // Focus state for the text editor
  @State private var text: String = "" // Binding to the text in parent

    var body: some View {

      ScrollView(Axis.Set.vertical, showsIndicators: false) {
        VStack(spacing: 30){

          HStack{
            Spacer().frame(width: 30, height: 30)

            Button(action: {
              isTextFieldFocused = false
            }) {
              SmallButtonNoBackground(text: "Close keyboard", icon: "keyboard")
            }.opacity(isTextFieldFocused ? 1 : 0.3)

            Spacer()

            Button(action: {
              showPromtpInputSheet = false
            }) {
              Image(systemName: "xmark.circle")
                .foregroundColor(Color.white)
                .font(Font.system(size: 30, weight: .regular))
            }

            Spacer().frame(width: 30, height: 30)
          }

          Button(action: {
            observer.startNewPromptRequest(prompt: text)
            showPromtpInputSheet = false
          }) {
            ButtonDefaultShape(buttonType: .promptInput)
          }


          // Custom TextEditor with cursor management
          CustomTextView(text: $text, selectedRange: $selectedRange)
            .focused($isTextFieldFocused)
            .padding(.horizontal, 20)
            .frame(width: UIScreen.main.bounds.size.width - 10, height: 500)
            .border(.basicText)
            .cornerRadius(3)

          Spacer().frame(width: 10, height: 40)

        }
      }
    }
}

#Preview {
  PromptInput(showPromtpInputSheet: .constant(true)).environmentObject(ObserverModel())
}
