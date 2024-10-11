//
//  SelectFamilyMember.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 20/09/2024.
//

import SwiftUI

struct PromptOption: Identifiable, Hashable {
  let id = UUID()
  var type: String
  var age: String? // Age is now optional and represented as a String for text input
}

struct SelectFamilyMember: View {
  @EnvironmentObject var observer: ObserverModel
  @State private var selectedPromptOption: [PromptOption] = [] // Store selected family members

  // Predefined family member types
  let familyOptions = ["Girl", "Boy"]
  @State private var familyDesc: String = ""

  func createFamilyDescription(from promptOption: [PromptOption]) {

    if promptOption.isEmpty {
      return
    }

    var descriptions: [String] = []

    for member in promptOption {
      if let age = member.age, !age.isEmpty {
        descriptions.append("A \(age)-year-old \(member.type.lowercased())")
      } else {
        descriptions.append("a \(member.type.lowercased())")
      }
    }

    let familyDescription = descriptions.joined(separator: ", ").replacingOccurrences(of: ",([^,]*)$", with: " and$1", options: .regularExpression)

    let totalMembers = promptOption.count
    observer.newTrainging.promptAddition =  "\(familyDescription)"

    /// Make Prompt options
    observer.newTrainging.promptOptions = [String]()


    for member in promptOption {
      observer.newTrainging.promptOptions.append(member.type.lowercased())
    }

  }

  var body: some View {
    VStack {
      Text("Select Your Family Members")
        .font(.title)
        .padding()

      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(familyOptions, id: \.self) { member in
            Button(action: {
              let newMember = PromptOption(type: member, age: nil)
              selectedPromptOption.append(newMember)
            }) {
              Text(member)
                .padding()
                .background(Color.basicPrimary)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
          }
        }
        .padding()
      }

      Divider().padding()

      if selectedPromptOption.isEmpty {
        Text("No family members selected yet")
          .foregroundColor(.gray)
      } else {
        ScrollView {
          VStack {
            ForEach(selectedPromptOption) { member in
              HStack {
                Text(member.type)
                  .font(.headline)

                Spacer()

                TextField("Enter age (optional)", text: Binding(
                  get: { member.age ?? "" },
                  set: { newValue in
                    if let index = selectedPromptOption.firstIndex(of: member) {
                      selectedPromptOption[index].age = newValue
                    }
                  }
                ))
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 120)

                Button(action: {
                  // Remove the family member
                  if let index = selectedPromptOption.firstIndex(of: member) {
                    selectedPromptOption.remove(at: index)
                  }
                }) {
                  Image(systemName: "trash")
                    .foregroundColor(.red)
                }
              }
              .padding()
              .background(Color.gray.opacity(0.1))
              .cornerRadius(10)
            }
          }
          .padding()
        }.onChange(of: selectedPromptOption) { oldState, newState in

          createFamilyDescription(from: selectedPromptOption)
        }
      }

      Spacer()

      Text(observer.newTrainging.promptAddition);

      ForEach(observer.newTrainging.promptOptions, id: \.self) { option in
        Text(option)
      }


      // Submit button
      Button(action: {
        // Submit selected family members
        observer.uploadZipToStartTraining()
        
        print("Family submitted: \(selectedPromptOption)")
      }) {
        Text("Submit Family")
          .padding()
          .background(Color.green)
          .foregroundColor(.white)
          .cornerRadius(10)
      }
      .padding()
    }
  }
}

#Preview {
    SelectFamilyMember().environmentObject(ObserverModel())
}
