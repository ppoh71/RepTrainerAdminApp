//
//  HomeView.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 10/01/2024.
// Debug Token_ EB5B957B-EA8B-4450-91E6-3C8BB4B83035

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct HomeView: View {
  @EnvironmentObject var observer: ObserverModel

  var body: some View {
    VStack(spacing: 0){

      //      if observer.showPaywall {
      //        SubscriptionView()
      //      } else {

      if observer.currentPath == .home {
        HomeContent()
          .onAppear{
            observer.loadingPhoto = false
          }
      }

      if observer.currentPath == .fix {
        FixView()

      }

      if observer.currentPath == .savedFixes {
        SavedFixes()
      }

      if observer.currentPath == .settings {
        SettingsView()
      }

      BottomNavigation()
      //      }

    }.overlay{

      if observer.loadingPhoto {
        LoadingImageProgress()
          .onTapGesture {
            observer.loadingPhoto = false
          }
      }
    }



    .ignoresSafeArea(edges: .bottom)
    .navigationBarTitle("keyTranslateAndChat", displayMode: .large)
     
  }
}

struct HomeContent: View {
  @EnvironmentObject var observer: ObserverModel
  @Environment(\.colorScheme) var colorScheme

  @State var showingOptions: Bool = false

  let bubleLoop: [BubbleLoop] = [
    BubbleLoop(image: FixTypes.one, layoutLeft: false, test: "Let´s see some examples"),
    BubbleLoop(image: FixTypes.six, layoutLeft: false, test: "Sometimes better than the original"),
    BubbleLoop(image: FixTypes.five, layoutLeft: false, test: "Not a copy. A (re)ima-\ngination"),
    BubbleLoop(image: FixTypes.three, layoutLeft: false, test: "Works with drawings"),
    BubbleLoop(image: FixTypes.four, layoutLeft: true, test: "Clone any stock image"),
    BubbleLoop(image: FixTypes.ten, layoutLeft: true, test: "We can handle also text"),
    BubbleLoop(image: FixTypes.seven, layoutLeft: true, test: "Clone master- pieces"),
    BubbleLoop(image: FixTypes.eight, layoutLeft: false, test: "Clone from normal to amazing"),
    BubbleLoop(image: FixTypes.nine, layoutLeft: true, test: "Works with any kindo of photo"),
  ]


  var body: some View {
    ScrollViewReader { value in
      ScrollView(Axis.Set.vertical, showsIndicators: false) {

        HStack{
          VStack(alignment: .leading){


            Spacer().frame(width: 10, height: 120)

            Text("Flux Photo Clone")
              .foregroundColor(.basicText)
              .font(.footnote.weight(.bold))
              .multilineTextAlignment(.leading)

            RunDemoModel()

            Text("Clone any Photo or Image with AI.")
              .foregroundColor(.basicText)
              .font(.title.weight(.bold))
              .multilineTextAlignment(.leading)

            Spacer().frame(width: 10, height: 30)

            HStack{
              Image(systemName: "1.circle")
                .foregroundColor(.basicText)
                .font(Font.system(size: 23, weight: .bold))

              Text("Upload any image")
                .foregroundColor(.basicText)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.leading)
            }

            Spacer().frame(width: 10, height: 10)

            HStack{
              Image(systemName: "2.circle")
                .foregroundColor(.basicText)
                .font(Font.system(size: 23, weight: .bold))

              Text("Get your own clone")
                .foregroundColor(.basicText)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.leading)
            }
          } .frame(width: 280)
        }

          Spacer().frame(height: 30)

          PhotosPicker(selection: $observer.imageSelection,
                       matching: .images,
                       photoLibrary: .shared()) {
            ButtonDefaultShape(buttonType: .addPhotos)

          }

        Spacer().frame(height: 120)

        ForEach(bubleLoop, id:\.self) { item in
          BubbleView(cloneImage: item.image.getFixItemImages().0 , originalImage: item.image.getFixItemImages().1, leftLayout: item.layoutLeft, textStatic: item.test)
          Spacer().frame(width: 10, height: 20)


        }


        }
      }.frame(alignment: .center)
        .navigationBarTitle("", displayMode: .inline)
        .edgesIgnoringSafeArea(.all)
    }


}


#Preview {
  HomeView().environmentObject(ObserverModel())
    .preferredColorScheme(.light)
}
