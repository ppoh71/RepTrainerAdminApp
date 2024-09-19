//
//  InPogressTExt.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 14/05/2024.
//

import SwiftUI

struct TimedTextView: View {
  @EnvironmentObject var observer: ObserverModel

  let messages = [
    "Initializing AI copy process.", "Analyzing image data.", "Creating image prompt.", "Generating copy.",
    "Final adjustments in progress.", "Completing proccess.", "Preparing to display your new image."
  ]

  @State private var currentIndex = 0
  @State private var displayText = ""
  @State private var fullText = ""
  @State private var messageTimer: Timer?
  @State private var typewriterTimer: Timer?
  @State private var charIndex = 0

  var body: some View {
    Text(displayText)
      .font(.body.weight(.bold))
      .padding()
      .onAppear {
        startMessageTimer()
      }
      .onDisappear {
        stopTimers()
      }
  }

  // Timer to switch messages every 10 seconds
  func startMessageTimer() {
    nextMessage()

    messageTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { _ in
      nextMessage()
    }
  }

  // Function to start typewriter effect
  func startTypewriterEffect() {
    typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
      updateText()
    }
  }

  // Prepare and start typewriter effect for new message
  func nextMessage() {
    if currentIndex < messages.count {
      fullText = messages[currentIndex]
      displayText = ""
      charIndex = 0
      startTypewriterEffect()
      currentIndex += 1
    } else {
      stopTimers() // Stop all timers when all messages are displayed
      
    }
  }

  // Update text for typewriter effect
  func updateText() {
    if charIndex < fullText.count {
      displayText += String(fullText[fullText.index(fullText.startIndex, offsetBy: charIndex)])
      charIndex += 1
    } else {
      typewriterTimer?.invalidate() // Stop typewriter timer when message is fully displayed
    }
  }

  // Stop both timers
  func stopTimers() {
    messageTimer?.invalidate()
    typewriterTimer?.invalidate()
    messageTimer = nil
    typewriterTimer = nil
  }
}

struct TimedTextView_Previews: PreviewProvider {
  static var previews: some View {
    TimedTextView().environmentObject(ObserverModel())
  }
}
