//
//  ContentView.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 22/12/2023.
//

import SwiftUI
import Firebase

struct ContentView: View {
  @EnvironmentObject var observer: ObserverModel
  @AppStorage(UserDefaultsKeys.hasLaunchedBefore) var hasLaunchedBefore: Bool = false
  @AppStorage(UserDefaultsKeys.isFirstLaunchLanguage) var isFirstLaunchLanguage: Bool = false
  @State private var showSubscription: Bool = false
  @Environment(\.requestReview) var requestReview

  func startUp() {

    FileOps.createDirectoriesCheck()
    
    
    /// DEBUG ONLY
    /// delete from keychain
    /// KeychainHandler.service.delete(service: UserDefaultsKeys.kcServiceName, account: UserDefaultsKeys.kcAccountName)

    /// Set default language for first selection
    if !hasLaunchedBefore {
      FirebaseService.logout()
      Utils.setFirstLaunchLanguage()
      Utils.storeAppUUID()
    }


    /// check for user, or login, or register
    if Utils.getUserId() != nil {
      
    }
  }

    var body: some View {

      NavigationStack(path: $observer.path) {
        ZStack {

          HomeView()

        }.navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: NavigationItem.self) { item in

          switch item {
          case .none:
            HomeView()
          case .home:
            HomeView()
          case .welcome:
            WelcomeView()
          case .fix:
            FixView()
          case .savedFixes:
            HomeView()
          case .settings:
            SettingsView()
          }

        }.onAppear {
          startUp()
        }
      }.accentColor(Color.basicText)

    }
}

#Preview {
    ContentView().environmentObject(ObserverModel())
}
