//
//  AppleSignInHelper.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/10/2023.
//
import Foundation
import FirebaseCore
import FirebaseAuth
import CryptoKit
import AuthenticationServices
import Combine

class AppleSignInHelper: NSObject, ObservableObject, ASAuthorizationControllerDelegate  {
    
    var currentNonce: String?
    var appleId:String = ""
    var authPublisher = PassthroughSubject<AuthProviderInfo, Never>()
    
    @Published var authProdiverInfo:AuthProviderInfo? {
        didSet {
            if let cred = authProdiverInfo {
                authPublisher.send(cred)
            }
        }
    }
    
    
    
    // MARK: - Password Account
    // Create, sign in, and sign out from password account functions...
    
    
    // Single-sign-on with Apple
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        // MARK : REVOKE AUTH
        let signOutReq = appleIDProvider.createRequest()
        signOutReq.requestedOperation = .operationLogout
        let logOutReq = ASAuthorizationController(authorizationRequests: [signOutReq])
        logOutReq.performRequests()
        
        // MARK : REQUEST SIGN IN
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            
            let cred = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            self.authProdiverInfo = AuthProviderInfo(id: appleIDCredential.user, name: appleIDCredential.fullName?.formatted() ?? "", url: "", email: appleIDCredential.email ?? "", provider: "apple", cred: cred)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    //MARK: - Apple sign in
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}
