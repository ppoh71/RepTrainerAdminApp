//
//  FixItem.swift
//  ImageOptimiser
//
//  Created by Peter Pohlmann on 03/03/2024.
//

import SwiftUI


struct FixItemList: View {
  @EnvironmentObject var observer: ObserverModel
  let fixArray: [FixTypes] = [.eleven, .one, .three, .six, .nine, .ten, .four, .twelve, .seven, .eight, .two]
  @State private var selectedType: FixTypes = .eleven

  var size: CGFloat = 90

  var body: some View {
    ScrollView(Axis.Set.horizontal, showsIndicators: false) {
      HStack(spacing: 10){
       Spacer().frame(width: 10, height: 5)

        ForEach(fixArray, id:\.self) { fixType in
          VStack(alignment: .leading){


            fixType.getFixItemImages().0
              .resizable()
              .scaledToFill()
              .frame(width: size, height: size) // Adjust the frame size as needed
              .clipShape(Circle())
              .overlay(Circle().stroke(selectedType == fixType ? Color.basicPrimary : Color.basicText , lineWidth: 1))

              .onTapGesture {
                selectedType = fixType
                observer.homeDisplayFixType = fixType
              }

          }
        }
      }.frame( height: size+10)
    }
  }
}

struct FixItemListForFix: View {
  @EnvironmentObject var observer: ObserverModel
  let fixArray: [FixTypes] = [.one, .two, .three]
  @State private var startSelect: Bool = false

  func fixIt(fixType: FixTypes) {
    observer.selectedFix = fixType
    startSelect = true
  }

//  func checkAlredyFixed(fixType: FixTypes) -> Bool {
//    var hasFix = false
//    for fix in observer.fixModel.fixes {
//      if fix.fixType == fixType {
//        hasFix = true
//      }
//    }
//    return hasFix
//  }

  var body: some View {
    ScrollView(Axis.Set.horizontal, showsIndicators: false) {
      HStack{
        Spacer().frame(width: 20, height: 10)
        ForEach(fixArray, id:\.self) { fixType in
          VStack(alignment: .leading){

            ZStack(alignment: .topLeading){
              SwipeItemView(fixType: fixType, width: 160)
                .frame(width: 160, height: 160)
                .cornerRadius(10)
                .overlay(Rectangle().stroke(observer.selectedFix == fixType && startSelect ? Color.basicPrimary : Color.clear, lineWidth: 15).cornerRadius(10) )
                .onTapGesture {
                  fixIt(fixType: fixType)
                }

              Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.basicPrimary)
                .font(Font.system(size: 30, weight: .regular))
                .background(Circle().fill(Color.white).frame(width: 20, height: 20))
                .offset(x: 10, y: 10)
                //.opacity(checkAlredyFixed(fixType: fixType) ? 1 : 0)
            }
            


          }
        }
      }
    }
  }
}


#Preview {
  FixItemList().environmentObject(ObserverModel())
}

