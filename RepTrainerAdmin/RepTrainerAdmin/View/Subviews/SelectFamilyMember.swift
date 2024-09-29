//
//  SelectFamilyMember.swift
//  RepTrainerAdmin
//
//  Created by Peter Pohlmann on 20/09/2024.
//

import SwiftUI

struct FamilyMember: Identifiable, Hashable {
  let id = UUID()
  var type: String
  var age: String? // Age is now optional and represented as a String for text input
}

struct SelectFamilyMember: View {
  @EnvironmentObject var observer: ObserverModel
  @State private var selectedFamilyMembers: [FamilyMember] = [] // Store selected family members

  // Predefined family member types
  let familyOptions = ["Father", "Mother", "Son", "Daughter", "Grandfather", "Grandmother"]
  @State private var familyDesc: String = "My family consists of ..."

  func createFamilyDescription(from familyMembers: [FamilyMember]) {

    if familyMembers.isEmpty {
      return
    }

    var descriptions: [String] = []

    for member in familyMembers {
      if let age = member.age, !age.isEmpty {
        descriptions.append("a \(member.type.lowercased()) (\(age))")
      } else {
        descriptions.append("a \(member.type.lowercased())")
      }
    }

    let familyDescription = descriptions.joined(separator: ", ").replacingOccurrences(of: ",([^,]*)$", with: " and$1", options: .regularExpression)

    let totalMembers = familyMembers.count
    observer.newTrainging.promptAddition =  "The family includes \(familyDescription). There are \(totalMembers) people in the family."
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
              let newMember = FamilyMember(type: member, age: nil)
              selectedFamilyMembers.append(newMember)
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

      if selectedFamilyMembers.isEmpty {
        Text("No family members selected yet")
          .foregroundColor(.gray)
      } else {
        ScrollView {
          VStack {
            ForEach(selectedFamilyMembers) { member in
              HStack {
                Text(member.type)
                  .font(.headline)

                Spacer()

                TextField("Enter age (optional)", text: Binding(
                  get: { member.age ?? "" },
                  set: { newValue in
                    if let index = selectedFamilyMembers.firstIndex(of: member) {
                      selectedFamilyMembers[index].age = newValue
                    }
                  }
                ))
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 120)

                Button(action: {
                  // Remove the family member
                  if let index = selectedFamilyMembers.firstIndex(of: member) {
                    selectedFamilyMembers.remove(at: index)
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
        }.onChange(of: selectedFamilyMembers) { oldState, newState in

          createFamilyDescription(from: selectedFamilyMembers)
        }
      }

      Spacer()

      Text(familyDesc);
        
      // Submit button
      Button(action: {
        // Submit selected family members
        observer.uploadZipToStartTraining()
        
        print("Family submitted: \(selectedFamilyMembers)")
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
