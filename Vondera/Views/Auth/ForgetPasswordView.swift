//
//  ForgetPasswordView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import SwiftUI
import AlertToast
import FirebaseAuth

struct ForgetPasswordView: View {
    @State var email = ""
    @State var msg:LocalizedStringKey?
    var body: some View {
        VStack {
            Spacer().frame(height: 24)
            
            FloatingTextField(title: "Email Address", text: $email, caption: "That's your signed email, we will send a mail to this address with instructions to reset your password", required: nil, keyboard: .emailAddress)
            
            Spacer().frame(height: 24)
            
            ButtonLarge(label: "Send Email") {
                if !email.isValidEmail {
                    msg = "Enter a valid email address"
                    return
                }
                
                sendResetEmail()
            }
            
            Spacer()
        }
        .padding()
        .toast(isPresenting: Binding(value: $msg), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        })
        .navigationTitle("Forget Password")
    }
    
    func sendResetEmail() {
        Auth.auth().sendPasswordReset(withEmail:email) { error in
            if let error = error {
                self.msg = error.localizedDescription.localize()
            } else {
                self.msg = "Email sent !".localize()
            }
        }
    }
}

struct ForgetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgetPasswordView()
    }
}
