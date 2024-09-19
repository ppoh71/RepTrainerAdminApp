//
//  BubbleView.swift
//  AiCopyImage
//
//  Created by Peter Pohlmann on 29/08/2024.
//

import SwiftUI

struct BubbleView: View {
  @EnvironmentObject var observer: ObserverModel

  let cloneImage: Image
  let originalImage: Image
  let leftLayout: Bool
  let textStatic: String

  let imagePadding: CGFloat = 0

  func getText(text: String) -> some View {
    Text(text)
      .foregroundColor(Color.basicText)
      .font(.title.weight(.heavy))
      .fixedSize(horizontal: false, vertical: true)
      .offset(y: 20)
  }

  var body: some View {

    VStack{

      HStack(alignment: .top){
        Spacer().frame(width: 10, height: 10)

        if leftLayout {
          getText(text: textStatic)
          Spacer().frame(width: 10, height: 10)
        }

        ZStack{
          originalImage
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 185, height: 185)
            .clipShape(Circle())

          BeforeAfter(text: "     Original")
            .offset(x: -70)
        }

        if !leftLayout {
          Spacer().frame(width: 10, height: 10)
          getText(text: textStatic)

        }

        Spacer().frame(width: 10, height: 10)
      }

      ZStack{
        cloneImage
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: UIScreen.main.bounds.size.width - imagePadding, height: UIScreen.main.bounds.size.width - imagePadding )
          .clipShape(Circle())

        BeforeAfter(text: "     Clone")
          .offset(x: -UIScreen.main.bounds.size.width/2 + 15)
      }.offset(x:0, y: -50)
    }
  }
}

struct BubbleReadyView: View {
  @EnvironmentObject var observer: ObserverModel

  let cloneImage: Image
  let originalImage: Image
  let imagePadding: CGFloat = 0

  var body: some View {

    VStack{

      HStack(alignment: .top){
        Spacer().frame(width: 10, height: 10)

        ZStack{
          originalImage
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 140, height: 140)
            .clipShape(Circle())

          BeforeAfter(text: "     Original")
            .offset(x: -50)
        }


        Spacer()
        Spacer().frame(width: 10, height: 10)
      }

        cloneImage
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: UIScreen.main.bounds.size.width - imagePadding, height: UIScreen.main.bounds.size.width - imagePadding )
          .clipShape(Circle())
          .offset(x:0, y: -70)
    }
  }
}

struct BubblePromptView: View {
  @EnvironmentObject var observer: ObserverModel

  let image: Image
  let imagePadding: CGFloat = 50

  var body: some View {

    VStack{
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: UIScreen.main.bounds.size.width - imagePadding, height: UIScreen.main.bounds.size.width - imagePadding )
        .clipShape(Circle())
    }
  }
}

#Preview {
//  BubbleView(cloneImage: Image("pods-1"), originalImage: Image("pods-2"), leftLayout: false, textStatic: "This is a test to test the text").environmentObject(ObserverModel())
//    .preferredColorScheme(.dark)


  BubblePromptView(image: Image("pods-1")).environmentObject(ObserverModel())
    .preferredColorScheme(.dark)

}
