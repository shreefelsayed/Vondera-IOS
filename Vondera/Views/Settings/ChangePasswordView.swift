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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 12) {
                SecureField("Current Password", text: $viewModel.oldPass)
                    .textFieldStyle(.roundedBorder)
                    
                
                SecureField("New Password", text: $viewModel.pass1)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Repeat Passsword", text: $viewModel.pass2)
                    .textFieldStyle(.roundedBorder)
                
                LoadingButton(action: {
                    save()
                }, isLoading: $viewModel.isSaving, style: LoadingButtonStyle(width: .infinity, cornerRadius: 16, backgroundColor: .accentColor, loadingColor: .white)) {
                    Text("Change Password")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .navigationTitle("Change Password")
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .banner(.slide),
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
