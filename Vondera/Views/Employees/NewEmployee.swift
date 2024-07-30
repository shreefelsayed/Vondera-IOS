//
//  NewEmployee.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import Foundation
import FirebaseCore
import FirebaseAuth

class NewEmployeeViewModel : ObservableObject {
    @Published var name = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var pass = ""
   
    @Published var perc:Double = 0.0
    
    @Published var isSaving = false
    
    @Published var selectedAccountType:UserRoles = .employee
    @Published var levels = AccessLevels().getEmployeeDefault()
    
    
    private func check() -> Bool {
        guard email.isValidEmail else {
            showTosat(msg: "Enter a valid employee email")
            return false
        }
        
        guard pass.isValidPassword else {
            showTosat(msg: "Enter a valid password")
            return false
        }
        
        guard !name.isBlank else {
            showTosat(msg: "Fill the Employee name")
            return false
        }
        
        guard phone.isPhoneNumber else {
            showTosat(msg: "Fill the Employee phone")
            return false
        }
        
        guard perc <= 99 && perc >= 0 else {
            showTosat(msg: "Enter a valid commission percentage")
            return false
        }
        
        return true
    }
    
    func save() async throws {
        guard check(), let user = UserInformation.shared.user else { return }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        let fbUser = try await Auth.auth().createUser(withEmail: email, password: pass)
        
        // --> Update the database
        var userData = UserData(id: fbUser.user.uid, name: name, email: email, phone: phone, addedBy: user.id, accountType: selectedAccountType.rawValue, pass: pass)
        
        userData.accessLevels = levels
        userData.storeId = user.storeId
        userData.percentage = Double(perc / 100)
        
        try await UsersDao().addUser(user: userData)
        
        // --> Saving Local
        if let myUser = UserInformation.shared.getUser() {
            if var employeesCount = myUser.store?.employeesCount {
                employeesCount = employeesCount + 1
                myUser.store?.employeesCount = employeesCount
                UserInformation.shared.updateUser(myUser)
            }
        }

        DispatchQueue.main.async {
            self.isSaving = false
        }
    }
    
    func createFirebaseOptions() -> FirebaseOptions {
        let firebaseOptions = FirebaseOptions.defaultOptions()
        firebaseOptions!.databaseURL = "brands-61c3d-default-rtdb"
        firebaseOptions!.apiKey = "AIzaSyC3Af2bq7ufCuC38UjHxBwsWUkCoKjjUZw"
        firebaseOptions!.googleAppID = "1:473830923339:android:02c4c0e62ca2c67db141ce"
        
        return firebaseOptions!
    }
    
    
    func showTosat(msg: LocalizedStringKey) {
        ToastManager.shared.showToast(msg: msg, toastType: .error)
    }
}

struct NewEmployee: View {
    @ObservedObject var viewModel = NewEmployeeViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                NavigationLink {
                    EmployeeAccessLevel(accessLevels: $viewModel.levels, currentRole: $viewModel.selectedAccountType)
                } label: {
                    HStack {
                        Text("Access Levels")
                            .bold()
                        
                        Spacer()
                        
                        Text(viewModel.selectedAccountType.getDisplayName())
                        
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.vertical, 12)
                
                Text("User Info")
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 8)
                
                FloatingTextField(title: "Name", text: $viewModel.name, caption: "The name of the member you want to add", required: true, autoCapitalize: .words)

                
                FloatingTextField(title: "Phone Number", text: $viewModel.phone, caption: "Use the whatsapp number of the member", required: true, keyboard: .phonePad)
                
                Divider()
                    .padding(.vertical, 12)
                
                
                Text("Authntication")
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 8)
                
                FloatingTextField(title: "Email Address", text: $viewModel.email, caption: "User email this will be used by the user to sign in", required: true, autoCapitalize: .never, keyboard: .emailAddress)
                
                FloatingTextField(title: "Password", text: $viewModel.pass, caption: "User password this will be used by the user to log in, DON'T ENTER YOUR PASSWORD", required: true, secure: true)
                
                Divider()
                    .padding(.vertical, 12)
                
                
                Text("Orders Commission")
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 8)
                
                HStack {
                    FloatingTextField(title: "Commission", text: .constant(""), caption: "This commission will be calculate from the order's netprofit From 1% to 99%", required: false, isNumric: true, number: $viewModel.perc)
                    
                    Text("%")
                }
            }
        }
        .padding()
        .navigationTitle("Create team member")
        .willProgress(saving: viewModel.isSaving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") { createUser() }
            }
        }
        .withPaywall(accessKey: .members, presentation: presentationMode)
        .withAccessLevel(accessKey: .teamMembersAdd, presentation: presentationMode)
    }
    
    private func createUser() {
        Task {
            do {
               try await viewModel.save()
                DispatchQueue.main.async {
                    ToastManager.shared.showToast(msg: "Account Created !")
                    self.presentationMode.wrappedValue.dismiss()
                }
            } catch {
                
            }
        }
    }
}
