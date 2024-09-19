//
//  PrivacyLinksView.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 25/01/2024.
//

import SwiftUI

struct PrivacyLinksView: View {
  @EnvironmentObject var actionObserver: ObserverModel

  var body: some View {
    return VStack{

      // Legal/Privace Buttons
      HStack{
        Button(action: {
          if let url = URL(string: "self.actionObserver.appConfig.privacyURL") {
            UIApplication.shared.open(url)
          }
        }) {
          Text("keyPrivacy")
            .font(.caption2)
            .foregroundColor(Color.basicText)
            .underline()
        }

        Spacer().frame(width: 50)

        Button(action: {
          if let url = URL(string: "self.actionObserver.appConfig.termsConditionURL") {
            UIApplication.shared.open(url)
          }
        }) {
          Text("keyTermsCondition")
            .font(.caption2)
            .foregroundColor(Color.basicText)
            .underline()
        }
      }
    }
  }
}

#Preview {
  PrivacyLinksView().environmentObject(ObserverModel())
}
