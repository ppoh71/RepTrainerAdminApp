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
  @State private var isLoading = false
  @State private var isProccessPrediction = false


  func loadDemoModels() {
    self.isLoading = true

    observer.getDemoModels(type: observer.trainerType.rawValue, completion: { (success, demoModels) in
      guard success, let demoModels = demoModels else {
        demoModelDict = [:]
        return
      }

      observer.selectedDemoModelList = [SelectedDemoModel]()

      for model in demoModels.demoModels {
        let newItem = SelectedDemoModel(desc: model.key, modelName: model.value)
        observer.selectedDemoModelList.append(newItem)
      }

      /// set first as default always
      if let first = observer.selectedDemoModelList.first {
        observer.selectedDemoModel = first
      }

      self.isLoading = false
    })
  }

  func getDemoModelToRun() {
    print("demo run start")
    isProccessPrediction = true
    observer.isLoading = true
    observer.getDemoModelToRun(model: observer.selectedDemoModel.modelName, completion: { (success, demoModelToRun) in
      guard success, let demoModelToRun = demoModelToRun else {
        print("Get demoModelToRun failded")
        return
      }
      print("Gort demo Model:")
      print(demoModelToRun)

     // let finalPrompt = observer.fixModel.getFinalPrompt(withTrigger: demoModelToRun.trigger, andAddition: demoModelToRun.promptAddition)

      guard  let baseImage = observer.fixModel.baseImage else { print("No base image"); return}

      observer.startIDemoImageGeneration(model: observer.selectedDemoModel.modelName, prompt: observer.fixModel.prompt, image: baseImage, options: observer.selectedOptions, promptAddition: demoModelToRun.promptAddition)
    })
  }

  func savePrompt() {
    if let image = observer.fixModel.baseImage {
      FirebaseService.createPromptWithImage(db: observer.db, type: observer.trainerType.rawValue, image: image, prompt: observer.fixModel.prompt, desc: "Some Description", options: observer.selectedOptions, sortOrder: 1 ) { result in
        switch result {
        case .success(_):
          print("Success Prompt saved")
        case .failure(_):
          print("Failure Creating Prompt")
        }
      }
    }
  }


  func toggleOption(_ option: PromptOptions) {
    if let index = observer.selectedOptions.firstIndex(of: option.rawValue) {
      observer.selectedOptions.remove(at: index)  // Remove if already selected
    } else {
      observer.selectedOptions.append(option.rawValue)  // Add if not selected
    }
  }

  func isSelected(_ option: PromptOptions) -> Bool {
    observer.selectedOptions.contains(option.rawValue)
  }

  var body: some View {
    VStack{

      VStack{

        HStack{
          SmallButtonNoBackground(text: "Project Target", icon: "target")
          Spacer()
          TrainerTypePicker()
        }.padding(.horizontal, 20)

        Spacer().frame(width: 10, height: 30)
        
        HStack{
          SmallButtonNoBackground(text: "Demo Model", icon: "rectangle.portrait.and.arrow.forward.fill")
          Spacer()

          if !isLoading {
            Picker("Select a Model", selection: $observer.selectedDemoModel) {
              if isLoading {
                Text("Loading...").tag(nil as String?)
              } else {
                ForEach(observer.selectedDemoModelList, id: \.self) { model in
                  Text(model.desc).tag(model.modelName)
                    .font(Font.system(size: 14, weight: .regular))
                }
              }

            }
              .pickerStyle(MenuPickerStyle())  // Display as a dropdown menu
              .tint(.basicText)
              .onChange(of: observer.trainerType) { oldState, newState in
                print("Trainer Tyoe is now \(observer.trainerType)")
                isLoading = true
                loadDemoModels()
              }

          }
        }.padding(.horizontal, 20)
      }.background(Color(UIColor.secondarySystemBackground))
        .onAppear{
          loadDemoModels()
        }

      Spacer().frame(width: 10, height: 40)

      HStack{
        Button(action: {
          getDemoModelToRun()
        }) {
          SmallButtonNoBackground(text: "Run Demo Model Now (\(observer.selectedDemoModel.desc))", icon: "play")
        }
        if observer.isLoading {
          ProgressView()
        }
      }

      Spacer().frame(width: 10, height: 30)

      BubblePromptView(image: Image(uiImage: observer.fixModel.fixedimage ?? UIImage()))
        .frame(height:  UIScreen.main.bounds.size.width - 10)

      Spacer().frame(width: 10, height: 50)

      // MARK: Save

      VStack{

        HStack{
          Button(action: {
            getDemoModelToRun()
          }) {
            SmallButtonNoBackground(text: "Run Demo Model Now (\(observer.selectedDemoModel.desc))", icon: "play")
          }
          if observer.isLoading {
            ProgressView()
          }
        }

        Spacer().frame(width: 10, height: 30)
        Text("Save Prompt for type: \(observer.trainerType.rawValue)")
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
          .font(.body.bold())
          .foregroundColor(Color.basicText)
        Spacer().frame(width: 10, height: 20)

        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            Spacer().frame(width: 10, height: 20)
            ForEach(PromptOptions.allCases) { option in
              Button(action: {
                toggleOption(option)
              }) {
                Text(option.rawValue.capitalized)
                  .font(.system(size: 14))
                  .padding(10)
                  .background(isSelected(option) ? Color.basicPrimary : Color.basicBackground)
                  .foregroundColor(.basicText)
                  .cornerRadius(8)
              }
            }
            Spacer().frame(width: 10, height: 20)
          }
        }
        Spacer().frame(width: 10, height: 20)
        Button(action: {
          savePrompt()
        }) {
          ButtonDefaultShape(buttonType: .savePrompt)
        }
        Spacer().frame(width: 10, height: 30)
      }.background(Color(UIColor.secondarySystemBackground))

    }
  }
}


#Preview {
  //PromptOptionsView()
  RunDemoModel().environmentObject(ObserverModel())
  //DemoModelPickerView()
}
