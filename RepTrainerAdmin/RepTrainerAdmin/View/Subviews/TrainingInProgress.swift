//
//  TrainingInProgress.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 23/09/2024.
//

import SwiftUI

struct TrainingInProgress: View {
  @EnvironmentObject var observer: ObserverModel

  /// check when training is ready
  ///
  /// display images


    var body: some View {

      Text("Training started")
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
        .font(.body)
        .foregroundColor(Color.basicText)


      EnhancedShazamLikeAnimationView()
        .frame(width: 80, height: 80)
        .opacity(0.3)
      /// Message Training started
      /// Animation
      ///
      /// Check macg messsge

      /// add reminder notification
      /// or add email for reminder


    }
}

#Preview {
    TrainingInProgress().environmentObject(ObserverModel())
}
