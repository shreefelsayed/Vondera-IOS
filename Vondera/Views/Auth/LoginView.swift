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
import _AuthenticationServices_SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State var creatingAccount = false
    @Environment(\.colorScheme) var colorScheme
    @State var showSavedItems = false
    @State var count = 0
    
    var body: some View {
        VStack(alignment: .center) {
            // Header
            Image("vondera_no_slogan")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(colorScheme == .dark ? Color.white : Color.accentColor)
            
            
                .padding(.top, 30)
            
            Spacer().frame(height: 36)
            
            VStack {
                Text("Welcome back")
                    .font(.title3)
                    .bold()
                
                Text("Please enter your details to sign in")
            }
            
            
            
            Spacer().frame(height: 24)
            
            //MARK : Login/Create account Methods
            /*
            HStack {
                RoundedImageButton(assetName: "apple-logo", assetSize: 25)
                    .onTapGesture {
                        #warning("Apple log in")
                    }
                
                Spacer()
                
                RoundedImageButton(assetName: "google", assetSize: 25)
                .onTapGesture {
                    googleSignIn()
                }
                
                Spacer()
                
                RoundedImageButton(assetName: "facebook", assetSize: 25)
                    .onTapGesture {
                        #warning("Facebook log in")
                    }
            }
            .frame(height: 40)
            
            
            // Login Form
            
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 2)
                
                Text("Or")
                
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 2)
            }
            */
            
            VStack(spacing: 22) {
                FloatingTextField(title: "Email address", text: $viewModel.email, required: nil ,autoCapitalize: .never, keyboard: .emailAddress)
                
                FloatingTextField(title: "Password", text: $viewModel.password, required: nil, secure: true)
                
                //TODO : Add the forget password screen
                HStack {
                    Spacer()
                    
                    Text("Forget Password ?")
                        .underline()
                }
                .hidden()
                
                ButtonLarge(label: "Sign in", action: callLogin)
                
                if count > 0 {
                    Button("Or Login to saved account") {
                        showSavedItems = true
                    }
                }
            }
            
            Spacer().frame(height: 14)
            
            HStack (spacing: 0) {
                Text("Don't have an account ? ")
                
                Text("Sign Up")
                    .bold()
                    .onTapGesture {
                        creatingAccount = true
                    }
            }
            
            
            
            Spacer()
            
            VStack {
                Text("By signing in, you agree to our ")
                    .font(.system(size: 16))
                
                HStack(spacing:0) {
                    Text("Terms & Conditions")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.accentColor)
                        .underline()
                        .onTapGesture {
                            openTermsAndConditionsLink()
                        }
                    
                    Text(" and our ")
                        .font(.system(size: 16))
                    
                    Text("Privacy Policy")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.accentColor)
                        .underline()
                        .onTapGesture {
                            openPrivacyPolicyLink()
                        }
                }
            }
            
        }
        .padding()
        .navigationDestination(isPresented: $creatingAccount) {
            CreateAccountView()
        }
        .toast(isPresenting: Binding(value: $viewModel.errorMsg)){
            AlertToast(displayMode: .alert,
                       type: .error(.red),
                       title: viewModel.errorMsg)
        }
        .sheet(isPresented: $showSavedItems) {
            NavigationStack {
                SwitchAccountView(show: $showSavedItems)
                    .presentationDetents([.fraction(0.3)])
            }
        }
        .onAppear {
            Task {
                let savedUsers = await SavedAccountManager().getAllUsers()
                count = savedUsers.count
            }
        }
    }
    
    func openTermsAndConditionsLink() {
        let url = "https://vondera.app/terms.html"
        if let Url = URL(string: url) {
            UIApplication.shared.open(Url)
        }
    }
    
    func openPrivacyPolicyLink() {
        let url = "https://vondera.app/policy.html"
        if let Url = URL(string: url) {
            UIApplication.shared.open(Url)
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
    
}


struct RoundedImageButton: View {
    var assetName = "apple.logo"
    var assetSize:CGFloat = 25
    var radius:CGFloat = 6
    var strokeColor:Color = Color.gray.opacity(0.5)
    var strokeWidth:CGFloat = 1
    
    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .stroke(strokeColor, lineWidth: strokeWidth)
            .overlay(
                Image(assetName)
                    .resizable()
                    .frame(width: assetSize)
                    .scaledToFit()
                    .padding(8)
            )
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
