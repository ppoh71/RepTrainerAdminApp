//
//  ZoomView.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 27/05/2024.
//

import SwiftUI
import Zoomable

struct ZoomViewForScreenshots: View {
  let image: Image
  let oldImage: Image
  @State private var zoomImage: Image = Image(uiImage: UIImage())
  @State var backText = "Original"

  @State var imageToggle: Bool = false
  @State private var currentZoom = 0.0
  @State private var totalZoom = 1.0
  @State var offset: CGSize = .zero
  @State var lastOffset: CGSize = .zero

  private func handleOffsetChange(_ offset: CGSize) -> CGSize {
    var newOffset: CGSize = .zero
    newOffset.width = offset.width + lastOffset.width
    newOffset.height = offset.height + lastOffset.height
    return newOffset
  }


  func toggleImage() {
    imageToggle.toggle()

    if imageToggle {
      zoomImage = image
      backText = "Photo Copy"
    } else {
      zoomImage = oldImage
      backText = "Original"
    }
    print("toggled")
  }


  var body: some View {

    VStack{

      Spacer().frame(width: 10, height: 180)
      //
      //      HStack{
      //        Spacer().frame(width: 20, height: 20)
      //
      //        Text("Zoom View")
      //          .foregroundColor(Color.basicText)
      //          .font(Font.system(size: 16, weight: .regular))
      //
      //        Spacer()
      //
      //        Image(systemName: "xmark.circle.fill")
      //          .foregroundColor(Color.basicText)
      //          .font(Font.system(size: 30, weight: .regular))
      //          .background(Circle().fill(Color.black).frame(width: 20, height: 20))
      //          .highPriorityGesture(
      //            SpatialTapGesture()
      //              .onEnded { loc in
      //                print("---> loc2: \(loc)")
      //                showZoomSheet = false
      //              })
      //
      //        Spacer().frame(width: 20, height: 20)
      //
      //      }.frame(width: UIScreen.main.bounds.size.width, height: 60 )
      // .offset(x:0, y: 30)
      Text("Toggle")
        .onTapGesture {
          print("toggle")
          toggleImage()
        }

      zoomImage
        .resizable()
        .scaledToFill()
        .scaleEffect(currentZoom + totalZoom)
        .offset(offset)

    }//.navigationBarTitle(backText, displayMode: .inline)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Text(backText)
          .font(.title.bold())
          .accessibilityAddTraits(.isHeader)
      }
    }

    .ignoresSafeArea(.all)

  }
}

#Preview {
  ZoomViewForScreenshots(image: Image("bird-1"), oldImage: Image("bird-2") )
}
