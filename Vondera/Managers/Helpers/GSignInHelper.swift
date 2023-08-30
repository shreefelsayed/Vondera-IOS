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
    func signIn() async -> AuthCredential? {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
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
            return GoogleAuthProvider.credential(withIDToken: idToken.tokenString,accessToken: accessToken.tokenString)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
