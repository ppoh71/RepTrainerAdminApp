//
//  MaskPainterView.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 14/10/2024.
//

import SwiftUI

struct MaskPainterView: View {
  @EnvironmentObject var observer: ObserverModel
  @Binding var showMaskSheet: Bool
  var urlString: String
  var originalImage: UIImage

  @State private var lines: [Line] = []
  @State private var currentLine = Line(points: [], color: .white, lineWidth: 10)
  @State private var brushSize: CGFloat = 40
  @State private var image: UIImage? = UIImage(named: "test") // Use your image named "test"
  @State private var snapshotImage: UIImage? = nil
  @State private var maskImage: UIImage = UIImage()
  @State private var newOriginalImage: UIImage = UIImage()
  @State private var screenShowOriginal: Bool = false

  // Scroll offsets
  @State private var xOffset: CGFloat = 0
  @State private var yOffset: CGFloat = 0

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        if let uiImage = image {
          GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
              ZStack {
                // Display the image and the drawing canvas
                Image(uiImage: uiImage)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 1024, height: 1024)
                  .offset(x: xOffset, y: yOffset)
                  .opacity(0)

                DrawingCanvasView(image: image, lines: $lines, screenShotOriginal: screenShowOriginal )
                  .padding(0)
                  .frame(width: 1024, height: 1024)
                  .offset(x: xOffset, y: yOffset)
                  .background(Color.blue)

                  .gesture(
                    DragGesture(minimumDistance: 0)
                      .onChanged { value in
                        let point = CGPoint(x: value.location.x - xOffset, y: value.location.y - yOffset)
                        currentLine.points.append(point)
                        lines.append(currentLine)
                      }
                      .onEnded { _ in
                        currentLine = Line(points: [], color: .white, lineWidth: brushSize)
                      }
                  )
              }
            }
          }
        }
      }
      .background(Color.yellow)
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      // Sliders for scrolling the image on X and Y axes
      HStack {
        Text("X")
        Slider(value: $xOffset, in: -512...512)
          .tint(Color.basicPrimary)
        Text("Y")
        Slider(value: $yOffset, in: -512...512)
          .tint(Color.basicPrimary)
      }
      .padding()

      // Brush Size Slider
      HStack {
        Text("Brush Size: \(Int(brushSize))")
        Slider(value: $brushSize, in: 1...80, step: 1)
          .tint(Color.basicPrimary)
      } .padding()


      // Save and Clear Buttons
      HStack {
        Button(action: clearCanvas) {
          Text("Clear")
            .padding()
            .background(Color.basicPrimary)
            .foregroundColor(Color.basicText)
            .cornerRadius(10)
        }

        Button(action:
                {
          saveSnapshot(isMask: false)
          image = UIImage(named: "MaskBlack") ?? UIImage()
          saveSnapshot(isMask: true)
          saveImagesToFirebase()
          screenShowOriginal = false
          showMaskSheet = false
        }
        ) {
          Text("Save Mask")
            .padding()
            .background(Color.basicPrimary)
            .foregroundColor(Color.basicText)
            .cornerRadius(10)
        }
      }

      Button(action: {
        showMaskSheet = false
      }) {
        SmallButton(text: "Close", icon: "xmark")
      }

      .padding()

      // Display the captured snapshot
      if let snapshotImage = snapshotImage {
        Image(uiImage: snapshotImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 300, height: 300)
          .padding()
      }
    }.onAppear{
      image = originalImage
    }
  }

  // Function to clear the canvas
  func clearCanvas() {
    lines = []
  }

  // Function to save the snapshot of the canvas
  func saveSnapshot(isMask: Bool) {

    /// overlay original image hide hide lines
    if isMask == false {
      screenShowOriginal = true
    } else {
      screenShowOriginal = false
    }

    if let image = snapshotViewAsImage() {
      if isMask {
        maskImage = image
      } else {
        newOriginalImage = image
      }
    }
  }

  // Function to capture a snapshot of the canvas using UIViewRepresentable
  func snapshotViewAsImage() -> UIImage? {
    let controller = UIHostingController(rootView: DrawingCanvasView(image: image, lines: $lines, screenShotOriginal: screenShowOriginal))
    let view = controller.view

    let targetSize = CGSize(width: 1024, height: 1024)
    view?.bounds = CGRect(origin: .zero, size: targetSize)
    view?.backgroundColor = .clear

    let renderer = UIGraphicsImageRenderer(size: targetSize)

    return renderer.image { _ in
      view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
    }
  }

  func saveImagesToFirebase() {
    FirebaseService.overrideImageAndCreateMask(from: urlString, newImage: newOriginalImage, maskImage: maskImage) { result in
      switch result {
      case .success:
        print("Image and mask uploaded successfully.")
      case .failure(let error):
        print("Failed to upload image and mask: \(error)")
      }
    }
  }


}

// Custom View to display image and drawing
struct DrawingCanvasView: View {
  var image: UIImage?
  @Binding var lines: [Line]
  var screenShotOriginal: Bool

  var body: some View {
    ZStack(alignment: .top) {
      if let uiImage = image {
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .padding(0)
          .frame(width: 1024, height: 1024)
          .offset(y: -24)


        Canvas { context, size in
          for line in lines {
            var path = Path()
            path.addLines(line.points)
            context.stroke(path, with: .color(.white), lineWidth: line.lineWidth)
          }
        }
        .padding(0)
        .frame(width: 1024, height: 1024)

        if screenShotOriginal {
          Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .padding(0)
            .frame(width: 1024, height: 1024)
            .offset(y: -24)
        }

      }
    }
    .padding(0)
    .frame(width: 1024, height: 1024)
    .background(Color.blue)
  }
}

struct Line {
  var points: [CGPoint]
  var color: Color
  var lineWidth: CGFloat
}

struct MaskPainterView_Previews: PreviewProvider {
  static var previews: some View {
    MaskPainterView(showMaskSheet: .constant(false), urlString: "Test URL", originalImage: UIImage()).environmentObject(ObserverModel())
  }
}
