//
//  RunDemoModel.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 19/09/2024.
//

import SwiftUI

struct RunDemoModel: View {
  @EnvironmentObject var observer: ObserverModel

  func getDemoModelToRun() {
    print("demo run start")
    observer.getDemoModelToRun(model: "cron_training_test-9", completion: { (success, demoModelToRun) in
    //observer.getDemoModelToRun(model: observer.selectedDemoModel, completion: { (success, demoModelToRun) in
      guard success, let demoModelToRun = demoModelToRun else {
        print("Get demoModelToRun failded")
        return
      }
     print("Gort demo Model:")
     print(demoModelToRun)

      /// run the model
      observer.startIDemomageGenration(model: "cron_training_test-9", prompt: "Show me speed")
    })
  }

    var body: some View {
      VStack{

        Button(action: {
          getDemoModelToRun()


        }) {
          SmallButtonNoBackground(text: "Run Demo Model Now", icon: "play")
        }


        /// get the model infos to run


      }
    }
}

#Preview {
    RunDemoModel().environmentObject(ObserverModel())
}
