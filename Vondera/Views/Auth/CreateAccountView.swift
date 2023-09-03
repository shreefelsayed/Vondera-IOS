//
//  CreateAccountView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI
import AlertToast

struct CreateAccountView: View {
    @StateObject var viewModel = CreateAccountViewModel()
    @Environment(\.presentationMode) private var presentationMode

    func nextScreen() {
        Task {
            await viewModel.showNextPage()
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            currentPage
            
            FloatingActionButton(symbolName: "arrow.forward", action: nextScreen)
                .padding()

        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .hud,
                type: .error(.red),
                title: viewModel.errorMsg)
        }
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .willProgress(saving: viewModel.isSaving)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            viewModel.showPrevPage()
        }){
            Image(systemName: "arrow.left")
        })
        .navigationTitle("Create New Store")
    }
    
    //MARK : This decide which page to return
    var currentPage: some View {
        if viewModel.currentPage == 1 {
            return AnyView(page1)
        } else if viewModel.currentPage == 2 {
            return AnyView(page2)
        }
        // Add a default return value here
        return AnyView(EmptyView())
    }
    
    var page2: some View {
        Form {
            Text("Please enter your Store details")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.leading)
            
            Section("Name & Slogan") {
                FloatingTextField(title: "Store Name", text: $viewModel.storeName, caption: "This is your store name, it will be printed on the receipts and in your website, it can be changed later", required: true)
                    .textInputAutocapitalization(.words)
                
                FloatingTextField(title: "Slogan", text: $viewModel.slogan, caption: "Your store slogan, it will be shown on your receipts and in your website", required: false)
                    .textInputAutocapitalization(.words)
                
            }
            
            Section("Communication") {
                FloatingTextField(title: "Business phone number", text: $viewModel.bPhone, caption: "We will use this number to contact you for any inquaries", required: true)
                    .keyboardType(.phonePad)
                
                Picker("Government", selection: $viewModel.gov) {
                    ForEach(GovsUtil().govs, id: \.self) { option in
                        Text(option)
                    }
                }
                
                FloatingTextField(title: "Address", text: $viewModel.address, caption: "We won't share your address, we collect it for analyze perpose", required: true, multiLine: true)
                    

            }
           
            FloatingTextField(title: "Refer Code", text: $viewModel.refferCode, caption: "If one of Vondera team invited you, enter his refer code", required: false)
                .textInputAutocapitalization(.never)

        }
        .lineLimit(1, reservesSpace: true)
    }
    
    var page1: some View {
        Form {
            Text("Please enter your account details")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.leading)
                
            Section("Personal Info") {
                FloatingTextField(title: "Name", text: $viewModel.name, caption: "Your personal legal name", required: true)
                    .textInputAutocapitalization(.words)

                FloatingTextField(title: "Phone Number", text: $viewModel.phone, caption: "This will not be visible anywere", required: true)
                    .textInputAutocapitalization(.words)
            }
            
            Section("Login Credintals") {
                FloatingTextField(title: "Email Address", text: $viewModel.email, caption: "This is your main email address, note you can't change it later, you will use it to login to your store", required: true)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            
                
                FloatingTextField(title: "Password", text: $viewModel.password, caption: "Choose a strong password, it must be 6 chars at least", required: true, secure: true)
                    .autocapitalization(.none)
            }
           
        }
        .lineLimit(1, reservesSpace: true)
        //.textFieldStyle(.roundedBorder)
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            CreateAccountView()
        }
    }
}
