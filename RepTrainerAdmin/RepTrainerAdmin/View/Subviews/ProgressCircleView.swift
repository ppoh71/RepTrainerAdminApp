//
//  ProgressCircleView.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 07/03/2024.
//

import SwiftUI

struct EnhancedShazamLikeAnimationView: View {
  @State private var isAnimating = false

  var body: some View {
    ZStack {
      // Multiple expanding, fading, and spinning ripples with gradient effect
      ForEach(0..<3) { i in
        Circle()
          .stroke(
            LinearGradient(gradient: Gradient(colors: [Color.basicPrimary.opacity(0.8), Color.basicPrimary.opacity(0.1)]), startPoint: .center, endPoint: .bottom),
            lineWidth: 3
          )
          .scaleEffect(isAnimating ? 2.0 : 0.2)
          .opacity(isAnimating ? 0.7 : 1)
          .rotationEffect(Angle(degrees: isAnimating ? 360 : 0)) // Spinning effect
          .animation(
            Animation.easeOut(duration: 2.5)
              .repeatForever()
              .delay(Double(i) * 0.6)
          )
      }

      // Central spinning and pulsing circle
      Circle()
        .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.basicPrimary]), startPoint: .top, endPoint: .bottom))
        .frame(width: 40, height: 40)
        .opacity(isAnimating ? 0.7 : 1)
        .scaleEffect(isAnimating ? 0.9 : 0.6) // Pulsing effect
        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0)) // Spinning effect
        .animation(
          Animation.easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        )
        .animation(
          Animation.linear(duration: 3.0)
            .repeatForever(autoreverses: false)
        )
        .onAppear {
          isAnimating = true
        }
    }
    .frame(width: 300, height: 300)
  }
}

struct SpinningCircleProgressView: View {
  @State private var isAnimating = false
  var circleSize: CGFloat

  var body: some View {
    ZStack {
      // Pulsing ripples
      ForEach(0..<50) { i in
        Circle()
          .stroke(Color.basicPrimary.opacity(0.9), lineWidth: 3)
          .scaleEffect(isAnimating ? 1.0 : 0.1)
          .opacity(isAnimating ? 0.7 : 1)
          .animation(
            Animation.easeOut(duration: 3.0)
              .repeatForever()
              .delay(Double(i) * 1.2), value: isAnimating
          )
      }

      // Central pulsing circle
      Circle()
        .fill(Color.basicPrimary)
        .frame(width: 10, height: 10)
        .opacity(isAnimating ? 0.2 : 1)
        .scaleEffect(isAnimating ? 1.2 : 1.0) // Pulsing effect
        .animation(
          Animation.easeInOut(duration: 2)
            .repeatForever(autoreverses: true), value: isAnimating
        )
        .onAppear {
          isAnimating = true
        }
    }
    .frame(width: circleSize, height: circleSize)
  }
}


struct FixTypeSelectedView: View {
  let fixType: FixTypes

  var body: some View {
    VStack{
      Image(systemName: "mountain.2")
        .foregroundColor(Color.basicText)
        .font(Font.system(size: 50, weight: .bold))
        .frame(height: 25)

      Spacer().frame(width: 10, height: 20)

    }
  }
}

struct FullCircleView: View{
  var circleSize: CGFloat
  @State private var animate: Bool = false

  var body: some View {
    Circle()
      .stroke(Color.basicPrimary, style: StrokeStyle(lineWidth: 10, dash: [5]))
      .opacity(1)
      .frame(width: circleSize , height: circleSize)
      .rotationEffect(.degrees(animate ? 360 : 0))
      .animation(Animation.linear(duration: 0.5).repeatForever(autoreverses: false), value: animate)
      .onAppear {
        animate = true
      }
  }
}

struct CircleOpacityBackgroundView: View{
  var circleSize: CGFloat
  @State private var animate: Bool = false

  var body: some View {
    Circle()
      .fill(.ultraThinMaterial)
      .opacity((animate ? 0.6 : 0.9))
      .frame(width: circleSize, height: circleSize)
      .animation(Animation.linear(duration: 2).repeatForever(autoreverses: true), value: animate)
      .onAppear {
        animate = true
      }

  }
}

struct RectOpacityBackgroundView: View{
  var circleSize: CGFloat

  var body: some View {
    Rectangle()
      .fill(.ultraThinMaterial)
      .opacity(0.8)
      .frame(width: circleSize, height: circleSize)

  }
}

struct ProgressCircleView: View {
  @Binding var progress: CGFloat // Expects a value between 0.0 and 1.0
  var circleSize: CGFloat

  var body: some View {
    Circle()
      .trim(from: 0, to: progress)
      .stroke(Color.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
      .rotationEffect(.degrees(-90)) // Start from the top
      .animation(.linear, value: progress)
      .frame(width: circleSize, height: circleSize)
  }
}


struct LoadingImageProgress: View{
  @State private var animate: Bool = false

  var body: some View {

    ZStack{
      Rectangle()
        .fill(.ultraThinMaterial)
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)

      Circle()
        .fill(.thinMaterial)
        .frame(width: 200, height: 200)
        .opacity((animate ? 0.3 : 0.7))
        .animation(Animation.linear(duration: 0.8).repeatForever(autoreverses: true), value: animate)
        .onAppear {
          animate = true
        }

      Text("Loading Image ...")
        .foregroundColor(Color.basicText)
        .font(.body.weight(.bold))
        .padding()

    }
  }
}

struct LoadingImageProgressSaved: View{
  @State private var animate: Bool = false

  var body: some View {

    ZStack{
      Rectangle()
        .fill(.ultraThinMaterial)
        .frame(width: UIScreen.main.bounds.size.width)

      Circle()
        .fill(.thinMaterial)
        .frame(width: 200, height: 200)
        .opacity((animate ? 0.3 : 0.7))
        .animation(Animation.linear(duration: 0.8).repeatForever(autoreverses: true), value: animate)
        .onAppear {
          animate = true
        }

      Text("Loading Image ...")
        .foregroundColor(Color.basicText)
        .font(.body.weight(.bold))
        .padding()

    }
  }
}

#Preview {

  VStack{
    EnhancedShazamLikeAnimationView()
    SpinningCircleProgressView(circleSize: 350)
   // LoadingImageProgress()
   // FullCircleView(circleSize: 350)
//    FullCircleView(circleSize: 400)
//
//    CircleOpacityBackgroundView(circleSize: 400)
//
//    FixTypeSelectedView(fixType: FixTypes.colorizePhotos)
//
//    ProgressCircleView(progress: .constant(0.7), circleSize: 60)

  } .background(Color.gray)


}
