//
//  AccountHomeScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 13/03/2024.
//

import SwiftUI

struct AccountHomeScreen : View {
    @State var myUser:UserData?
    
    var body : some View {
        ZStack {
            if let myUser = myUser {
                if myUser.isStoreUser {
                    UserHome()
                } else if myUser.accountType == "Sales" {
                    #warning("Set the sales Dashboard")
                } else if myUser.accountType == "Admin" {
                    #warning("Set the Admin Dashboard")
                }
            }
        }
        .onAppear {
            self.myUser = UserInformation.shared.getUser()
        }
    }
}
