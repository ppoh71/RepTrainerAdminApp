//
//  RunDemoModel.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 19/09/2024.
//

import SwiftUI

struct RunDemoModel: View {
  @EnvironmentObject var observer: ObserverModel
  @State private var demoModelDict: [String: String] = [:]
  @State private var selectedModel: String = ""
  @State private var isLoading = true

  func loadDemoMOdels() {
    observer.getDemoModels(type: observer.trainerType.rawValue, completion: { (success, demoModels) in
      guard success, let demoModels = demoModels else {
        demoModelDict = [:]
        return
      }
      demoModelDict = demoModels.demoModels

      self.isLoading = false
      if let first = demoModelDict.first {
        observer.selectedDemoModel = SelectedDemoModel(desc: first.key, modelName: first.value)
      }
    })
  }

  func getDemoModelToRun() {
    print("demo run start")
    //observer.getDemoModelToRun(model: "cron_training_test-9", completion: { (success, demoModelToRun) in
    observer.getDemoModelToRun(model: observer.selectedDemoModel.modelName, completion: { (success, demoModelToRun) in
      guard success, let demoModelToRun = demoModelToRun else {
        print("Get demoModelToRun failded")
        return
      }
       print("Gort demo Model:")
       print(demoModelToRun)

     /// we havew to update the current prompt with the demo model values: trigger and prompt addition
      let finalPrompt = observer.fixModel.getFinalPrompt(withTrigger: demoModelToRun.trigger, andAddition: demoModelToRun.promptAddition)

      /// run the model
      observer.startIDemomageGenration(model: observer.selectedDemoModel.modelName, prompt: finalPrompt)
    })
  }

  func savePrompt() {
    if let image = observer.fixModel.fixedimage {

      FirebaseService.createPromptWithImage(db: observer.db, type: observer.trainerType.rawValue, image: image, prompt: observer.fixModel.prompt, desc: "Some Description" ) { result in
        switch result {
        case .success(let url):
          print("Success Prompt saved")
        case .failure(let error):
          print("Failure Creating Prompt")
        }
      }
    }
  }
    var body: some View {
      VStack{

        VStack{
          HStack{
            SmallButtonNoBackground(text: "Project Target", icon: "target")
            Spacer()
            TrainerTypePicker()
          }.padding(.horizontal, 20)

          HStack{
            SmallButtonNoBackground(text: "Demo Model", icon: "rectangle.portrait.and.arrow.forward.fill")
            Spacer()
            Picker("Select a Model", selection: $observer.selectedDemoModel.desc) {
              // Loop through the demoModels and display each one as an option
              if isLoading {
                Text("Loading...").tag(nil as String?)
              } else {
                ForEach(demoModelDict.keys.sorted(), id: \.self) { key in
                  Text(key).tag(key)
                    .font(Font.system(size: 14, weight: .regular))
                }
              }

            }.disabled(isLoading)
              .pickerStyle(MenuPickerStyle())  // Display as a dropdown menu
              .tint(.basicText)
              .onChange(of: observer.trainerType) { oldState, newState in
                // Call action function
                print("Trainer Tyoe is now \(observer.trainerType)")
                isLoading = true
                loadDemoMOdels()
              }
              .onAppear{
                loadDemoMOdels()
              }
          }.padding(.horizontal, 20)
        }.background(Color(UIColor.secondarySystemBackground))
        
        Spacer().frame(width: 10, height: 20)

        Button(action: {
          getDemoModelToRun()
        }) {
          SmallButtonNoBackground(text: "Run Demo Model Now", icon: "play")
        }

        Spacer().frame(width: 10, height: 30)
        BubblePromptView(image: Image(uiImage: observer.fixModel.fixedimage ?? UIImage()))
        Spacer().frame(width: 10, height: 50)

        /// get the model infos to run
        if observer.fixModel.fixedimage?.size.width ?? UIImage().size.width > 0 {
          Button(action: {
            savePrompt()
          }) {
            SmallButtonNoBackground(text: "Save Prompt", icon: "play")
          }
        }


      }
    }
}

#Preview {
    RunDemoModel().environmentObject(ObserverModel())
}
