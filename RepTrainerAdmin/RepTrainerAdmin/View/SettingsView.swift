//
//  SettingsView.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 10/01/2024.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
  @EnvironmentObject var observer: ObserverModel
  @Environment(\.requestReview) var requestReview

    var body: some View {

      List {

        Spacer().frame(height: 120)
          .listRowBackground(Color.basicBackground)
          .listSectionSeparator(.hidden)

        Section(header: Text("Manage Subscription")) {

          Button(action: {
            observer.showSubscription = true
          }){
            SettingRowView(title: "Subscription",
                           systemImageName: "leaf.circle", divider: 0)
          }

          Button(action: {
           // observer.restorePruchaseFromRevenueCat()
          }){
            SettingRowView(title: "Restore Purchases",
                           systemImageName: "leaf.arrow.triangle.circlepath", divider: 0)
          }
        }

      }
      .edgesIgnoringSafeArea(.all)
      .listStyle(.grouped)

      .navigationBarTitle("More", displayMode: .large)

    }
}

struct SettingRowView : View {
  var title : String
  var systemImageName : String
  var divider: Double

  var body : some View {
    VStack(alignment: .leading) {
      HStack (spacing : 15) {
        Text(" ")
        Image(systemName: systemImageName)
          .font(.title2.weight(.regular))

        Text (LocalizedStringKey(title))
          .font(.body)

      }.padding(.vertical, 10)

    }.listRowSeparator(.visible)

  }
}

struct SettingsDetailView: View {
  var body: some View {
    Text("")
  }
}


#Preview {
  SettingsView().environmentObject(ObserverModel())
}
