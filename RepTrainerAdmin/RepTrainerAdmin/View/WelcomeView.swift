//
//  HomeView.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 27/12/2023.
//

import SwiftUI

struct WelcomeView: View {
  @EnvironmentObject var observer: ObserverModel

  @State private var selection = 0

  var body: some View {
    TabView(selection: $selection) {
      OnboardingView1(selection: $selection)
        .tag(0)
      OnboardingView2(selection: $selection)
        .tag(1)
      OnboardingView3(selection: $selection)
        .tag(2)

    }
    .tabViewStyle(PageTabViewStyle())
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
  }
}

struct OnboardingView1: View {
  @Binding var selection: Int
  @Environment(\.colorScheme) var colorScheme

  var body: some View {

      VStack(alignment: .leading) {

        Text("keyWelcomeTitle1")
          .font(Font.system(size: 36, weight: .black))
          .foregroundStyle(Color.basicText)

        Spacer().frame(height: 30)

        Text("keyWelcomeCopy1")
          .font(.title.weight(.bold))
          .foregroundStyle(Color.basicText)

        Spacer().frame(height: 15)

        HStack{

//          Image(colorScheme == .dark ? "ChatGPT" : "ChatGPTLight")
//            .resizable()
//            .scaledToFit()
//            .frame(width: 20)
//            .padding(.horizontal, 0)

          Text("keyPoweredByGPT")
            .font(.body.weight(.regular))
            .foregroundStyle(Color.basicText)
        }

        VStack{
          Spacer()

          HStack{
            Spacer()
            ZStack{
              Image(systemName: "bubble.right.fill")
                .foregroundColor(Color.basicPrimary)
                .font(Font.system(size: 200, weight: .heavy))
                .rotationEffect(.degrees(-15))
                .offset(y:8)
                .accessibilityLabel(Text("keyNextButton"))
                .shadow(color: Color.basicShadow, radius: 10, x: 10, y: 10)

              Image(colorScheme == .dark ? "ChatIcon" : "ChatIconLight")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .rotationEffect(.degrees(-15))
                .padding(0)
                .accessibilityLabel(Text("keyNextButton"))
            }

            Spacer()

          }.onTapGesture {
            withAnimation {
              selection = 1
            }
          }
          Spacer()
        }
        Spacer()
      }.padding(40)
  }
}

struct OnboardingView2: View {
  @Binding var selection: Int
  @Environment(\.colorScheme) var colorScheme

  var body: some View {

    VStack(alignment: .leading) {

      Text("keyWelcomeTitle2")
        .font(Font.system(size: 36, weight: .black))
        .foregroundStyle(Color.basicText)

      Spacer().frame(height: 30)

      Text("keyWelcomeCopy2")
        .font(.title.weight(.bold))
        .foregroundStyle(Color.basicText)

      VStack{
        Spacer()

        HStack{
          BubbleWord(text: "keyMusic", left: false, size: 100, rotate: true)
            .accessibilityLabel(Text("keyNextButton"))
          BubbleWord(text: "keyArt", left: true, size: 120, rotate: true)
            .accessibilityLabel(Text("keyNextButton"))
        }
        HStack{
          BubbleWord(text: "keyTravel", left: true, size: 110, rotate: false)
            .accessibilityLabel(Text("keyNextButton"))
          BubbleWord(text: "keyFood", left: false, size: 100, rotate: true)
            .accessibilityLabel(Text("keyNextButton"))
        }

        Spacer()
      }.onTapGesture {
        withAnimation {
          selection = 2
        }
      }
      Spacer()
    }.padding(40)
  }
}


struct BubbleWord: View {
  var text: String
  var left: Bool
  var size: CGFloat
  var rotate: Bool
  var body: some View {
    ZStack{
      Image(systemName: left ? "bubble.left.fill" : "bubble.right.fill")
        .foregroundColor(Color.basicPrimary)
        .font(Font.system(size: size, weight: .heavy))
        .offset(y:8)
        .rotationEffect(.degrees(rotate ? 180 : 0 ))

      Text(LocalizedStringKey(text))
        .foregroundStyle(Color.basicText)
        .font(Font.system(size: 16, weight: .heavy))
    }.rotationEffect(.degrees(Double.random(in: -31..<30)))
     .shadow(color: Color.basicShadow, radius: 10, x: 10, y: 10)
  }
}


struct OnboardingView3: View {
  @AppStorage(UserDefaultsKeys.hasLaunchedBefore) var hasLaunchedBefore: Bool = false
  @Binding var selection: Int
  @Environment(\.colorScheme) var colorScheme

  @State private var words: [String] = ["O", "que", "vai", "fazer"]
  let activeWord = 3

  var body: some View {

    ScrollView(Axis.Set.vertical, showsIndicators: false) {

      VStack(alignment: .leading) {

        Text("keyLexikonFingertips")
          .font(Font.system(size: 36, weight: .black))
          .foregroundStyle(Color.basicText)
          .fixedSize(horizontal: false, vertical: true)

        Spacer().frame(height: 30)

        Text("keyLexikonExplain")
          .font(.title.weight(.bold))
          .foregroundStyle(Color.basicText)
          .fixedSize(horizontal: false, vertical: true)

        ZStack{

          ZStack{
            Image(systemName: "bubble.left.fill")
              .foregroundColor(Color.basicPrimary)
              .font(Font.system(size: 220, weight: .heavy))
              .accessibilityLabel(Text("keyNextButton"))
              .shadow(color: Color.basicShadow, radius: 10, x: 10, y: 10)

          }
          .offset(x: 0, y: 20)
          
          ZStack{
            Image(systemName: "bubble.right.fill")
              .foregroundColor(Color.basicText)
              .font(Font.system(size: 130, weight: .heavy))
              .rotationEffect(.degrees(-180))
              .accessibilityLabel(Text("keyNextButton"))
              .shadow(color: Color.basicShadow, radius: 10, x: 10, y: 10)

            Text("keyWordFazer")
              .font(Font.system(size: 14, weight: .regular))
              .foregroundColor(Color.basicBackground)
              .frame(width: 110)
              .offset(x: 0, y: 10)
              .accessibilityLabel(Text("keyNextButton"))
          }
          .frame(width: 100)
          .offset(x: 50, y: 100)
        }
        .rotationEffect(.degrees(-15))
        .offset(x: 0, y: -30)
          .onTapGesture {
            hasLaunchedBefore = true
          }

        HStack{
          Spacer()
          Button(action: {
            hasLaunchedBefore = true
          }) {

            Text("keyStartnow")
              .foregroundStyle(Color.basicText)
              .font(Font.system(size: 20, weight: .bold))
              .padding(.horizontal, 40)
              .padding(.vertical, 30)
              .background(Color.basicPrimary)
              .cornerRadius(8.0)
          }
          Spacer()
        }
        Spacer().frame(height: 40)
      }.padding(40)
    }
  }
}


#Preview {

  OnboardingView1(selection: .constant(2))

 // WelcomeView().environmentObject(ObserverModel())
}
