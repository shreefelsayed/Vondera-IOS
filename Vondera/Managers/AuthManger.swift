//
//  AuthManger.swift
//  Vondera
//
//  Created by Shreif El Sayed on 18/06/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
class AuthManger {
    let usersDao: UsersDao
    let storesDao:StoresDao
    let mAuth = Auth.auth()
    
    init() {
        self.usersDao = UsersDao()
        self.storesDao = StoresDao()
    }
    
    func logOut() async {
        do {
            guard let currentUser = UserInformation.shared.getUser() else {
                return
            }
            
            try! await usersDao.update(id: currentUser.id, hash: ["online": false])
            await removeFCM()
            
            UserInformation.shared.clearUser()
            try! mAuth.signOut()
        }
    }
    
    func changePassword(newPass:String, user:UserData) async throws -> Bool {
        guard mAuth.currentUser != nil else {
            return false
        }
        
        // --> Reauth
        let cred = EmailAuthProvider.credential(withEmail: user.email, password: user.pass)
        
        try await mAuth.currentUser?.reauthenticate(with: cred)
        
        // --> Change password
        try await mAuth.currentUser?.updatePassword(to: newPass)
        
        return true
    }
    
    func createStoreOwnerUser(userData: inout UserData, store:Store) async -> Bool {
        do {
            let fbUserCreated = await createFirebaseUserAccount(email: userData.email, pass: userData.pass)
            
            guard fbUserCreated != nil else {
                return false
            }
            
            // --> Set the user data
            userData.id = fbUserCreated!.uid
            userData.storeId = fbUserCreated!.uid
            try await usersDao.addUser(user: userData)
            
            // --> Add the store data
            store.ownerId = fbUserCreated!.uid
            try await storesDao.addStore(store: store)
                        
            let data = try await getData()
            
            return data != nil
        } catch {
            return false
        }
    }
    
    func createFirebaseUserAccount(email:String, pass:String) async -> User? {
        do {
            let fbUser = try await Auth.auth().createUser(withEmail: email, password: pass)
            return fbUser.user
        } catch {
            return nil
        }
    }
    
    func signUserWithGoogle() async -> Bool {
        let cred = await GSignInHelper().signIn()
        if cred == nil {
            return false
        }
        
        print("Got google sign in creds")
        
        do {
            let fUser = try await Auth.auth().signIn(with: cred!)
            print("Signed in to firebase \(fUser.user.uid)")
            
            
            var loggedIn:Bool = false
            
            do {
                let data = try await getData()
                loggedIn = data != nil
            } catch {
                print(error.localizedDescription)
                return false
            }
            
            
            guard loggedIn else {
                return false
            }
            
            // --> We set some values
            
            // --> Return the user
            return true
        } catch {
            return false
        }
    }
    
    func getData() async throws -> UserData? {
        let uId = Auth.auth().currentUser?.uid
        print("Current user is \(String(describing: uId))")
        
        
        guard uId != nil else {
            print("No user id not found")
            await logOut()
            return nil
        }
        
        if var user = try await usersDao.getUser(uId: uId!).item {
            guard user.isStoreUser else {
                print("Unsporrted user type")
                await logOut()
                return nil
            }
            
            print("User \(user.name)")
                        
            if let store = try await storesDao.getStore(uId: user.storeId) {
                print("Loggin to store \(store.name)")
                user.store = store
                UserInformation.shared.updateUser(user)
                try! await usersDao.update(id: user.id, hash: ["online": true, "ios": true])
                
                // Save FCM
                await saveFCM()
                
                return user
            } else {
                print("Failed to get store")
                await logOut()
                return nil
            }
        } else {
            print("Failed to get user")
            await logOut()
            return nil
        }        
    }
    
    func removeFCM() async {
        if let userUID = Auth.auth().currentUser?.uid {
            do {
                try await UsersDao().update(id: userUID, hash: ["device_token" : ""])
                print("FCM token Cleared")
            } catch {
                print("FCM token Couldn't be Cleared")
            }
            
        }
    }
    
    func saveFCM() async {
        if let userUID = Auth.auth().currentUser?.uid {
            do {
                let token = try await Messaging.messaging().token()
                try await UsersDao().update(id: userUID, hash: ["device_token" : token])
                print("FCM token Attached")
            } catch {
                print("FCM token error \(error.localizedDescription)")
            }
            
        }
    }
    
    func signUserInViaMail(email:String, password:String) async -> Bool {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            let data = try await getData()
            guard let userData = data else {
                return false
            }
            
            // SAVE the user for later access
            await SavedAccountManager().addUser(savedItems: LoginInfo(id: userData.id, name: userData.name, email: userData.email, password: userData.pass, url: userData.userURL, accountType: userData.accountType, storeName: userData.store?.name ?? ""))
            
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
