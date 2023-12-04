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
    @ObservedObject var appleAuth = AppleSignInHelper()
    
    @State var creatingAccount = false
    @State var forgetPassword = false
    @State var showSavedItems = false

    @Environment(\.colorScheme) var colorScheme
    @State var count = 0
    @State var authInfo:AuthProviderInfo?
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Welcome Back !")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                
                Spacer()
            }
            
            
            
            Spacer().frame(height: 24)
            
            //MARK : Login/Create account Methods
            /*VStack {
                HStack {
                    RoundedImageButton(assetName: "apple-logo", assetSize: 25)
                        .onTapGesture {
                            appleAuth.startSignInWithAppleFlow()
                        }
                    
                    Spacer()
                    
                    RoundedImageButton(assetName: "google", assetSize: 25)
                    .onTapGesture {
                        Task {
                            if let provider = await GSignInHelper().signIn() {
                                let loggedIn = await viewModel.googleSignIn(cred: provider.cred, id: provider.id)
                                if !loggedIn {
                                    print("Will Create Account")
                                    authInfo = provider
                                    creatingAccount = true
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    RoundedImageButton(assetName: "facebook", assetSize: 25)
                        .onTapGesture {
                            FBAuthHelper().getCreds(onCompleted: { authProvider in
                                Task {
                                    let loggedIn = await viewModel.fbSignIn(cred:authProvider.cred, id: authProvider.id)
                                    if !loggedIn {
                                        print("Will Create Account")
                                        authInfo = authProvider
                                        creatingAccount = true
                                    }
                                }
                            })
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
            }*/
            
            VStack(spacing: 22) {
                FloatingTextField(title: "Email address", text: $viewModel.email, required: nil ,autoCapitalize: .never, keyboard: .emailAddress)
                
                FloatingTextField(title: "Password", text: $viewModel.password, required: nil, secure: true)
                
                ButtonLarge(label: "Sign in", action: callLogin)
                
                HStack {
                    Text("Forget Password ?")
                        .underline()
                        .onTapGesture {
                            forgetPassword = true
                        }
                    Spacer()
                }
                
                
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
                    .underline()
                    .foregroundStyle(Color.accentColor)
                    .onTapGesture {
                        creatingAccount = true
                    }
                
            }
                        
            Spacer()
            
            VStack(alignment: .center) {
                Text("By signing in, you agree to our ")
                    .font(.system(size: 16))
                
                HStack(spacing:0) {
                    Text("Terms & Conditions")
                        .font(.system(size: 16))
                        .bold()
                        .foregroundStyle(Color.accentColor)
                        .underline()
                        .onTapGesture {
                            openTermsAndConditionsLink()
                        }
                    
                    Text(" and our ")
                        .font(.system(size: 16))
                    
                    Text("Privacy Policy")
                        .font(.system(size: 16))
                        .bold()
                        .foregroundStyle(Color.accentColor)
                        .underline()
                        .onTapGesture {
                            openPrivacyPolicyLink()
                        }
                }
            }
            
        }
        .padding()
        .onReceive(appleAuth.authPublisher, perform: { authProvider in
            Task {
                let loggedIn = await viewModel.appleSignIn(cred: authProvider.cred, id: authProvider.id)
                if !loggedIn {
                    print("Will Create Account")
                    authInfo = authProvider
                    creatingAccount = true
                }
            }
        })
        .navigationDestination(isPresented: $creatingAccount) {
            CreateAccountView(authInfo: authInfo)
        }
        .navigationDestination(isPresented: $forgetPassword) {
            ForgetPasswordView()
        }
        .toast(isPresenting: Binding(value: $viewModel.errorMsg)){
            AlertToast(displayMode: .alert,
                       type: .error(.red),
                       title: viewModel.errorMsg)
        }
        .sheet(isPresented: $showSavedItems) {
            
                SwitchAccountView(show: $showSavedItems)
            
        }
        .onAppear {
            Task {
                let savedUsers = SavedAccountManager().getAllUsers()
                count = savedUsers.count
            }
        }
    }
    
    func openTermsAndConditionsLink() {
        let url = "https://www.vondera.app/terms-conditions"
        if let Url = URL(string: url) {
            UIApplication.shared.open(Url)
        }
    }
    
    func openPrivacyPolicyLink() {
        let url = "https://www.vondera.app/privacy-policy"
        if let Url = URL(string: url) {
            UIApplication.shared.open(Url)
        }
    }
    
    
    func callLogin() {
        Task {
            await viewModel.login()
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
