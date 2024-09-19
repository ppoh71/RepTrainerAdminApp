//
//  FixSliderView.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 11/05/2024.
//

import SwiftUI

struct FixSliderView: View {
  @EnvironmentObject var observer: ObserverModel
  @FocusState private var isTextFieldFocused: Bool

  func resetToDefault() {
    observer.creativity = Constants.creativity
    observer.resemblance = Constants.resemblance
    observer.scale = Constants.scale
    observer.textPrompt = ""
  }

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 10) {
        Text("Creativity: \(observer.creativity, specifier: "%.2f")")
          .foregroundColor(Color.basicText)
          .font(.footnote.bold())

        Slider(value: $observer.creativity, in: 0...1, step: 0.01)
          .accentColor(Color.basicText)

        Text("A value from 0-3; higher values enhance the similarity and fidelity to the original image, preserving more of its details and characteristics.")
          .foregroundColor(Color.basicText.opacity(0.7))
          .font(.footnote)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding()

      VStack(alignment: .leading, spacing: 10) {
        Text("Resemblance: \(observer.resemblance, specifier: "%.2f")")
          .foregroundColor(Color.basicText)
          .font(.footnote.bold())


        Slider(value: $observer.resemblance, in: 0...3, step: 0.01)
          .accentColor(Color.basicText)

        Text("A value from 0-1; higher values increase the AI model's tendency to generate imaginative or altered content, deviating more from the original image.")
          .foregroundColor(Color.basicText.opacity(0.7))
          .font(.footnote)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding()

      VStack(alignment: .leading, spacing: 10) {
        Text("Scale: \(observer.scale.asInteger)x")
          .foregroundColor(Color.basicText)
          .font(.footnote.bold())

        Slider(value: $observer.scale, in: 1...6, step: 1)
          .accentColor(Color.basicText)
          .disabled(Utils.getHasSubscription() ? false : true)

        Text("A value from 0-10; higher values increase the output image resolution, resulting in larger and more detailed images.")
          .foregroundColor(Color.basicText.opacity(0.7))
          .font(.footnote)
          .fixedSize(horizontal: false, vertical: true)
      }.opacity(Utils.getHasSubscription() ? 1 : 0.5)
      .padding()

      // Multiline Text Editor
//      VStack(alignment: .leading) {
//        Text("Prompt:")
//          .foregroundColor(Color.basicText)
//          .font(.footnote.bold())
//
//        TextEditor(text: $observer.textPrompt)
//          .foregroundColor(Color.basicText)
//          .font(.footnote.bold())
//          .focused($isTextFieldFocused)
//          .scrollContentBackground(.hidden) // <- Hide it
//          .background(Color(UIColor.secondarySystemBackground))
//          .frame(height: 60) // Set the height of the TextEditor
//          .cornerRadius(10)
//
//      }
//      .padding()

      Spacer().frame(width: 10, height: 20)

      Button(action: {
        observer.startRequest()
      }) {
        VStack{
          Spacer().frame(width: 10, height: 50)
          ButtonDefaultShape(buttonType: .fixUpscxape)
        }
      }

      Spacer().frame(width: 10, height: 20)

      VStack(alignment: .center) {
        Button(action: {
          resetToDefault()
        }) {
          HStack{
            Image(systemName: "arrow.uturn.backward")
              .foregroundColor(Color.basicText)
              .font(.footnote.bold())

            Text("Reset to Default")
              .foregroundColor(Color.basicText)
              .font(.footnote.bold())
          }

        }
      }
      .padding()

      Spacer().frame(width: 10, height: 200)

    }
  }
}

#Preview {
  FixSliderView().environmentObject(ObserverModel()) 
}
