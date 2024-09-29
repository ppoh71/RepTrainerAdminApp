//
//  CustomTextView.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 28/12/2023.
//

import SwiftUI
import UIKit

struct CustomTextView: UIViewRepresentable {
  @Binding var text: String
  @Binding var selectedRange: NSRange

  class Coordinator: NSObject, UITextViewDelegate {
    var parent: CustomTextView

    init(parent: CustomTextView) {
      self.parent = parent
    }

    func textViewDidChange(_ textView: UITextView) {
      // Update text and selected range asynchronously to avoid direct state updates during view update
      DispatchQueue.main.async {
        self.parent.text = textView.text
        self.parent.selectedRange = textView.selectedRange
      }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
      // Update selected range asynchronously to avoid direct state updates during view update
      DispatchQueue.main.async {
        self.parent.selectedRange = textView.selectedRange
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.delegate = context.coordinator
    textView.font = UIFont.preferredFont(forTextStyle: .title2)
    textView.isSelectable = true
    textView.isEditable = true
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
    uiView.selectedRange = selectedRange
  }
}
