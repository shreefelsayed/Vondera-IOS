//
//  AuthManger.swift
//  Vondera
//
//  Created by Shreif El Sayed on 18/06/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManger {
    let usersDao: UsersDao
    let storesDao:StoresDao
    let mAuth = Auth.auth()
    
    init() {
        self.usersDao = UsersDao()
        self.storesDao = StoresDao()
    }
    
    func logOut() async {
        /*
         mail : erey@fools.com
         Password : ##erey322003##
         */
        do {
            if mAuth.currentUser != nil {
                do {
                    try await usersDao.update(id: mAuth.currentUser!.uid, hash: ["online": false])
                } catch {
                    
                }
            }

            print("Logging out")
            await LocalInfo().saveUser(user: nil)
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
                        
            return try await getData()
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
                loggedIn = try await getData()
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
    
    func getData() async throws -> Bool {
        let uId = Auth.auth().currentUser?.uid
        print("Current user is \(String(describing: uId))")
        
        
        guard uId != nil else {
            print("No user id not found")
            await logOut()
            return false
        }
        
        
        var user = try await usersDao.getUser(uId: uId!)
        
        guard user != nil else {
            print("Failed to get user")
            await logOut()
            return false
        }
        
        if user!.accountType != "Owner" && user!.accountType != "Store Admin" && user!.accountType != "Marketing" && user!.accountType != "Worker" {
        
            print("Unsporrted user type")
            await logOut()
            
            return false
        }
        
        let store = try await storesDao.getStore(uId: user!.storeId)
        
        
        guard store != nil else {
            print("Failed to get store")
            await logOut()
            return false
        }
        
        user?.store = store
        
        let saved = await LocalInfo().saveUser(user: user!)
        guard saved else {
            print("Failed to save user")
            await logOut()
            return false
        }
        
        try! await usersDao.update(id: user!.id, hash: ["online": true, "ios": true])
        
        // Assign Notifications
        let pushManager = PushNotificationManager(userID: user!.id)
        await pushManager.registerForPushNotifications()
        
        return true
    }
    
    func signUserInViaMail(email:String, password:String) async -> Bool {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            return try await getData()
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
