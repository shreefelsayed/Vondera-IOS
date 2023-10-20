//
//  ChangePasswordView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI
import AlertToast
import LoadingButton

struct ChangePasswordView: View {
    var user:UserData
    @ObservedObject var viewModel:ChangePasswordViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(user: UserData) {
        self.user = user
        self.viewModel = ChangePasswordViewModel(user: user)
    }
    
    var body: some View {
        List {
            Section("Password") {
            
                FloatingTextField(title: "Current Password", text: $viewModel.oldPass, required: true, secure: true)
                
                FloatingTextField(title: "New Password", text: $viewModel.pass1, required: true, secure: true)
                
                FloatingTextField(title: "Repeat Password", text: $viewModel.pass2, required: true, secure: true)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Update")
                    .bold()
                    .foregroundStyle(Color.accentColor)
                    .onTapGesture {
                        save()
                    }
            }
        }
        .navigationTitle("Change Password")
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .alert,
                       type: .regular,
                       title: viewModel.msg)
        }
    }
    
    func save() {
        Task {
            await viewModel.updatePassword()
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(user: UserData.example())
    }
}
