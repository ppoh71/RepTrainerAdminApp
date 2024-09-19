//
//  ZoomView.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 27/05/2024.
//

import SwiftUI
import Zoomable

struct ZoomView: View {
  let image: Image
  @State private var currentZoom = 0.2
  @State private var totalZoom = 1.0
  @State var offset: CGSize = .zero
  @State var lastOffset: CGSize = .zero

  private func handleOffsetChange(_ offset: CGSize) -> CGSize {
    var newOffset: CGSize = .zero
    newOffset.width = offset.width + lastOffset.width
    newOffset.height = offset.height + lastOffset.height
    return newOffset
  }

  var body: some View {

 //   VStack{
      image
        .resizable()
        .scaledToFit()
       //.scaleEffect(2.2)
       // .offset(offset)
        .zoomable()
      
//        .gesture(
//          MagnifyGesture()
//            .onChanged { value in
//              print("current zoom \(currentZoom)")
//              currentZoom = value.magnification - 1
//            }
//            .onEnded { value in
//              print("totalZoom \(totalZoom)")
//              totalZoom += currentZoom
//              currentZoom = 0
//            }
//
//            .simultaneously(
//              with: DragGesture(minimumDistance: 0)
//                .onChanged({ value in
//                  withAnimation(.interactiveSpring()) {
//                    offset = handleOffsetChange(value.translation)
//                  }
//                })
//                .onEnded({ _ in
//                  lastOffset = offset
//                })
//            )
//        )

  //  }
  //  .navigationBarTitle("Back", displayMode: .inline)

//    .navigationBarTitleDisplayMode(.inline)
//      .toolbar {
//        ToolbarItem(placement: .topBarLeading) {
//          Text("Back")
//            .font(.title.bold())
//            .accessibilityAddTraits(.isHeader)
//        }
//      }
      .ignoresSafeArea(.all)

  }
}

#Preview {
  ZoomView(image: Image("old-1") )
}
