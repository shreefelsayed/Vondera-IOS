//
//  LoginView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI
import AlertToast
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
import OmenTextField
import CocoaTextField

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State private var sheetHeight: CGFloat = .zero
    @State var creatingAccount = false
    
    let images = ["home_intro_01", "home_intro_02", "home_intro_03", "home_intro_04", "home_intro_05"]
    
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation {
                viewModel.currentSlide = (viewModel.currentSlide + 1) % images.count
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Header
                Image("logo_horz")
                    .resizable()
                    .scaledToFit()
                
                .padding(.top, 30)
                
                
                Image(images[viewModel.currentSlide])
                    .resizable()
                    .scaledToFit()
                    .onAppear(perform: {
                        _ = timer
                    })
                    .padding(.vertical, 20)
                
                Spacer()
                
                
                // Login Form
                VStack(spacing: 10) {
                    ButtonLarge(label: "Login",action: showEmail)
                    ButtonLarge(label: "Create a new Store", background: .white, textColor: .blue) {
                        creatingAccount = true
                    }
                    
                }
                
                Spacer()
                
                Text("By singing in you agree to Vondera terms and conditions")
                    .multilineTextAlignment(.center)
                
            }
            .padding()
            
            NavigationLink(destination: CreateAccountView(), isActive: $creatingAccount) { EmptyView() }
            
            BottomSheet(isShowing: $viewModel.isShowingSheet, content: {
                AnyView(currentSheet)
            }())
        }
        
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .hud,
                       type: .error(.red),
                       title: viewModel.errorMsg)
        }
    }
    
    func showEmail() {
        withAnimation {
            viewModel.showEmailSheet()
        }
    }
    
    func showLoginSheet() {
        withAnimation {
            viewModel.showLoginSheet()
        }
    }
    
    func showCreateAccountSheet() {
        withAnimation {
            viewModel.showSignUpSheet()
        }
    }
    
    func hideSheet() {
        withAnimation {
            viewModel.hideSheet()
        }
    }
    
    func callLogin() {
        Task {
            await viewModel.login()
        }
    }
    
    func googleSignIn() {
        Task {
            await viewModel.googleSignIn()
        }
    }
    
    @ViewBuilder
    var currentSheet: some View {
        switch viewModel.sheetType {
        case "Login":
            loginDialog
        case "SignUp":
            createAccountSheet
        default:
            emailSheet
        }
    }
    
    var createAccountSheet: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Start your journey by creating your store now")
                    .foregroundColor(.black.opacity(0.9))
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            Text("Create a new store account to access all the great features of Vondera, and start controlling your business")
                .font(.caption)
                .padding(.bottom, 24)
            
            ButtonLarge(label: "Continue with Google", action: {
                
            })
            
            ButtonLarge(label: "Continue with Email") {
                creatingAccount = true
            }
        }
        .padding(.horizontal, 16)
    }
    
    
    var emailSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Login to with your Email")
                    .foregroundColor(.black.opacity(0.9))
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            
            TextField("Email Address", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            ButtonLarge(label: "Login", action: callLogin)
            
        }
        .padding(.horizontal, 16)
    }
    
    var loginDialog: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Login to your store")
                    .foregroundColor(.black.opacity(0.9))
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            Text("Login to your account using google, or email and password to access your store.")
                .font(.caption)
                .padding(.bottom, 24)
            
            ButtonLarge(label: "Sign in with Google", action: googleSignIn)
            
            ButtonLarge(label: "Sign in with Email", action: showEmail)
        }
        .padding(.horizontal, 16)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
