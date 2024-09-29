//
//  TrainerTypePicker.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 18/09/2024.
//

import SwiftUI

struct TrainerTypePicker: View {
  @EnvironmentObject var observer: ObserverModel
  //@State private var selectedModel: TrainerType = .family

  var body: some View {
    VStack {
      // Create a Picker that binds to selectedModel
      Picker("Select a Model", selection: $observer.trainerType) {
        ForEach(TrainerType.allCases) { model in
          Text(model.rawValue).tag(model)
            .font(Font.system(size: 20, weight: .bold))
        }
      }
      .pickerStyle(MenuPickerStyle())   // You can choose another style here
      .tint(.basicText)
      .onChange(of: observer.trainerType) { oldState, newState in
        // Call action function
        print("Trainer Tyoe is now \(observer.trainerType)")
        Utils.setTrainerType(observer.trainerType)
      }
    }.onAppear{
      if let storedTrainerType = Utils.getTrainerType() {
        self.observer.trainerType = storedTrainerType
      }

    }

  }
}

#Preview {
    TrainerTypePicker().environmentObject(ObserverModel())
}
