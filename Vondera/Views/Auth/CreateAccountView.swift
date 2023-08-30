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
    
    func nextScreen() {
        Task {
            await viewModel.showNextPage()
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading) {
                    currentPage
                }
            }
            
            FloatingActionButton(symbolName: "arrow.forward", action: nextScreen)
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .hud,
                type: .error(.red),
                title: viewModel.errorMsg)
        }
        .navigationTitle("Create New Store")
        .padding()
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
        VStack(alignment: .leading, spacing: 10) {
            Text("Please enter your Store details")
                .font(.title2)
                .multilineTextAlignment(.leading)
            
            Spacer().frame(height: 20)
            
            TextField("Store Name", text: $viewModel.storeName)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
            
            
            TextField("Slogan (Optional)", text: $viewModel.slogan)
                .textFieldStyle(.roundedBorder)
            
            TextField("Business phone number", text: $viewModel.bPhone)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.sentences)
            
            TextField("Address", text: $viewModel.address, axis: .vertical)
                .lineLimit(5, reservesSpace: true)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.sentences)
            
            TextField("Refer Code (Optional)", text: $viewModel.refferCode)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
        }
    }
    
    var page1: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Please enter your account details")
                .font(.title2)
                .multilineTextAlignment(.leading)
            
            Spacer().frame(height: 20)
            
            TextField("Email Address", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            TextField("Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
            
            TextField("Phone number", text: $viewModel.phone)
                .keyboardType(.phonePad)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
            
        }
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            CreateAccountView()
        }
    }
}
