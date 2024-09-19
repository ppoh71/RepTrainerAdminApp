//
//  BottomNavigationView.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 01/02/2024.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct BottomNavigation: View {
  @Environment(\.colorScheme) var colorSch
  @EnvironmentObject var observer: ObserverModel

  var iconSize: CGFloat = 15
  var fontSize: CGFloat = 10
  var rectSize: CGFloat = 35

  var body: some View {
    ZStack() {

      VStack(spacing: 0){
        Spacer().frame(width: 10, height: 10)

        HStack {

          Spacer()
          VStack{
            Image(systemName: "house")
              .foregroundColor(Color.basicText)
              .font(Font.system(size: iconSize, weight: .regular))
              .frame(height: 25)

            Text("Home")
              .foregroundStyle(Color.basicText)
              .font(Font.system(size: fontSize, weight: .regular))

            Rectangle()
              .fill(observer.currentPath == .home ? Color.basicPrimary : Color.clear)
              .frame(width: rectSize, height: 3, alignment: .bottom)
              .cornerRadius(15)

          }.opacity(observer.currentPath == .home ? 1 :  0.7)
            .onTapGesture {
              observer.path = NavigationPath()
              observer.currentPath = .home

            }
            .accessibilityLabel(Text("keyMenuButtonHome"))

          Spacer()
          VStack{
            Image(systemName: "photo.on.rectangle.angled")
              .foregroundColor(Color.basicText)
              .font(Font.system(size: iconSize, weight: .regular))
              .frame(height: 25)

            Text("Make Prompt")
              .foregroundStyle(Color.basicText)
              .font(Font.system(size: fontSize, weight: .regular))

            Rectangle()
              .fill(observer.currentPath == .fix ? Color.basicPrimary : Color.clear)
              .frame(width: rectSize, height: 3, alignment: .bottom)
              .cornerRadius(15)

          }.opacity(observer.currentPath == .fix ? 1 :  0.7)
            .onTapGesture {
              observer.currentPath = .fix
            }
            .accessibilityLabel(Text("keyMenuButtonChat"))

          Spacer()
          VStack{
            Image(systemName: "photo.on.rectangle.angled")
              .foregroundColor(Color.basicText)
              .font(Font.system(size: iconSize, weight: .regular))
              .frame(height: 25)

            Text("All Prompts")
              .foregroundStyle(Color.basicText)
              .font(Font.system(size: fontSize, weight: .regular))

            Rectangle()
              .fill(observer.currentPath == .savedPrompts ? Color.basicPrimary : Color.clear)
              .frame(width: rectSize, height: 3, alignment: .bottom)
              .cornerRadius(15)

          }.opacity(observer.currentPath == .savedPrompts ? 1 :  0.7)
            .onTapGesture {
              observer.currentPath = .savedPrompts
            }
            .accessibilityLabel(Text("keyMenuButtonChat"))
          Spacer()

          VStack{
            Image(systemName: "square.stack.3d.down.right")
              .foregroundColor(Color.basicText)
              .font(Font.system(size: iconSize, weight: .regular))
              .rotationEffect(.degrees(120))
              .frame(height: 25)

            Text("History")
              .foregroundStyle(Color.basicText)
              .font(Font.system(size: fontSize, weight: .regular))

            Rectangle()
              .fill(observer.currentPath == .savedFixes ? Color.basicPrimary : Color.clear)
              .frame(width: rectSize, height: 3, alignment: .bottom)
              .cornerRadius(15)

          }.opacity(observer.currentPath == .savedFixes ? 1 :  0.7)
            .onTapGesture {
              observer.currentPath = .savedFixes
            }
            .accessibilityLabel(Text("keyMenuButtonSavedChats"))

          Spacer()
          VStack{

            Image(systemName: "ellipsis.bubble")
              .foregroundColor(Color.basicText)
              .font(Font.system(size: iconSize, weight: .regular))
              .frame(height: 25)

            Text("More")
              .foregroundStyle(Color.basicText)
              .font(Font.system(size: fontSize, weight: .regular))

            Rectangle()
              .fill(observer.currentPath == .settings ? Color.basicPrimary : Color.clear)
              .frame(width: rectSize, height: 3, alignment: .bottom)
              .cornerRadius(15)

          }.opacity(observer.currentPath == .settings ? 1 :  0.7)
            .onTapGesture {
              observer.currentPath = .settings
            }
            .accessibilityLabel(Text("keyMenuButtonMore"))


          Spacer()
        }

        HStack{
          Spacer().frame(height: 30)
        }.background(Color(UIColor.secondarySystemBackground))


      }.background(Color(UIColor.secondarySystemBackground))

//      ZStack{
//
//        HStack{
//          Spacer()
//          PhotosPicker(selection: $observer.imageSelection,
//                       matching: .images,
//                       photoLibrary: .shared()) {
//            Image(systemName: "plus.circle.fill")
//              .font(.system(size:50))
//              .foregroundColor(Color.basicPrimary)
//          }
//          .frame(width: 300)
//          Spacer()
//        }
//      }.offset(x:0, y:-45)
    }
  }
}

#Preview {
  BottomNavigation().environmentObject(ObserverModel())
}
