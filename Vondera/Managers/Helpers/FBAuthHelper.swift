//
//  FBSignin.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/10/2023.
//

import Foundation
import FacebookCore
import FacebookLogin
import Firebase
import FirebaseAuth

class FBAuthHelper {
    //(AuthCredential?, String)
    func getCreds(onCompleted: @escaping (AuthProviderInfo) -> Void) {
        LoginManager().logIn(permissions: ["email", "public_profile"], from: nil) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
                        
            GraphRequest(graphPath: "me", parameters: ["fields": "id,first_name,last_name,email"])
                .start(completion: { (connection, result, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let fbProfileDetails = result as? NSDictionary {
                        let firstName = fbProfileDetails.value(forKey: "first_name") as? String ?? ""
                        let lastName = fbProfileDetails.value(forKey: "last_name") as? String ?? ""

                        let id = fbProfileDetails.value(forKey: "id") as? String
                        let email = fbProfileDetails.value(forKey: "email") as? String
                        let image = "https://graph.facebook.com/\(id ?? "")/picture?type=normal"
                        
                        if let token = AccessToken.current, !token.isExpired {
                            let cred = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
                            
                            onCompleted(AuthProviderInfo(id: id ?? "", name: "\(firstName) \(lastName)", url: image, email: email ?? "", provider: "facebook", cred: cred))
                        }
                    } else {
                        print("Couldn't get data")
                    }
                })
        }
    }
}
