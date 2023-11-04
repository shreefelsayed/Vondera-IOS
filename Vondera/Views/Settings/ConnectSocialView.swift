//
//  ConnectSocialView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct ConnectSocialView: View {
    @ObservedObject var user = UserInformation.shared
    @ObservedObject var appleAuth = AppleSignInHelper()
    
    var body: some View {
        List {
            if let myUser = user.user {
                HStack {
                    Text("Google")
                    
                    Spacer()
                    
                    Button(myUser.connectedToGoogle() ? "Connected" : "Connect") {
                        Task {
                            await google()
                        }
                    }
                    .disabled(myUser.connectedToGoogle())
                }
                
                
                HStack {
                    Text("Apple")
                    
                    Spacer()
                    
                    Button(myUser.connectedToApple() ? "Connected" : "Connect") {
                        appleAuth.startSignInWithAppleFlow()
                    }
                    .disabled(myUser.connectedToApple())
                }
                
                HStack {
                    Text("Facebook")
                    
                    Spacer()
                    
                    Button(myUser.connectedToFB() ? "Connected" : "Connect") {
                        Task {
                            facebook()
                        }
                    }
                    .disabled(myUser.connectedToFB())
                }
            }
        }
        .onReceive(appleAuth.authPublisher) { cred in
            Task {
                await apple(cred)
            }
        }
    }
    
    func apple(_ cred: AuthProviderInfo) async {
        if let id = user.user?.id {
            if await AuthManger().connectToCred(cred: cred.cred) {
                try? await UsersDao().update(id: id, hash: ["googleId" : cred.id])
                user.user?.googleId = cred.id
                UserInformation.shared.updateUser()
            }
        }
    }
    
    func facebook()  {
        if let id = user.user?.id {
            FBAuthHelper().getCreds { cred in
                Task {
                    if await AuthManger().connectToCred(cred: cred.cred) {
                        try? await UsersDao().update(id: id, hash: ["facebookId" : cred.id])
                        user.user?.facebookId = cred.id
                        UserInformation.shared.updateUser()
                    }
                }
            }
        }
    }
    
    func google() async {
        if let id = user.user?.id {
            if let cred = await GSignInHelper().signIn() {
                if await AuthManger().connectToCred(cred: cred.cred) {
                    try? await UsersDao().update(id: id, hash: ["googleId" : cred.id])
                    user.user?.googleId = cred.id
                    UserInformation.shared.updateUser()
                }
            }
        }
    }
}

struct ConnectSocialView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectSocialView()
    }
}
