//
//  SwipeItemView.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 03/03/2024.
//

import SwiftUI

struct SwipeItemView: View {
  let fixType: FixTypes
  let width: CGFloat

  @State private var curtainWidth: CGFloat
  @GestureState private var dragState = CGSize.zero

  init(fixType: FixTypes, width: CGFloat) {
    self.fixType = fixType
    self.width = width
    self.curtainWidth = width
  }

  var body: some View {
      ZStack(alignment: .topLeading) {
        // Bottom Image
        fixType.getFixItemImages().1
          .resizable()
          .scaledToFit()
          .frame(width: width)

        // Top Image with Mask for Curtain Effect
        fixType.getFixItemImages().0
          .resizable()
          .scaledToFit()
          .frame(width: width)
          .mask(
            HStack {
              Rectangle()
                .frame(width: curtainWidth)
              Spacer()
            }
          )

        // Drag Line and Circle
        VStack {
          Rectangle()
            .fill(Color.white)
            .frame(width: 1, height: width)
        }
        .frame(height: width)
        .offset(x: curtainWidth ) // Adjusting the offset to center the circle on the line
      }.edgesIgnoringSafeArea(.all) // To ensure it fills the full width including the edges
  }
}

#Preview {
  SwipeItemView(fixType: .one, width: 160)
}
