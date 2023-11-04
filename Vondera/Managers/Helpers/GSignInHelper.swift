//
//  GSignInHelper.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import Foundation

class GSignInHelper {
    func signIn() async -> AuthProviderInfo? {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("No client ID found in Firebase configuration")
            return nil
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await  windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            print("There is no root view controller!")
            return nil
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = userAuthentication.user
            
            guard let idToken = user.idToken else {
                return nil
            }
            
            
            let accessToken = user.accessToken
            
            // --> Get Credentails
            return AuthProviderInfo(id: user.userID ?? "", name: user.profile?.name ?? "", url: user.profile?.imageURL(withDimension: 500)?.absoluteString ?? "", email: user.profile?.email ?? "", provider: "google", cred: GoogleAuthProvider.credential(withIDToken: idToken.tokenString,accessToken: accessToken.tokenString))
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
