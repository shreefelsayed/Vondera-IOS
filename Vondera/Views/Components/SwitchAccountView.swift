//
//  SwitchAccountView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 17/10/2023.
//

import SwiftUI
import NetworkImage

struct SwitchAccountView: View {
    @Binding var show:Bool
    @State var users = [LoginInfo]()
    @State var currentAccount = ""
    
    var body: some View {
        List {
            ForEach(users) { user in
                SwitchCard(user: user, currentAccount: currentAccount == user.id, onSignin: {
                    Task {
                        if !currentAccount.isBlank {
                            await AuthManger().logOut()
                        }
                        _ = await AuthManger().signUserInViaMail(email: user.email, password: user.password)
                        
                        show = false
                    }
                })
                .listRowInsets(EdgeInsets())
                .swipeActions(edge: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation {
                            users.removeAll { $0.id == user.id}
                            Task {
                                await SavedAccountManager().removeUser(uId: user.id)
                            }
                            
                            // MARK : Close the dialog if there is no more accounts
                            if users.isEmpty {
                                show = false
                            }
                        }
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    
                }
            }
        }
        .navigationTitle("Switch Account")
        .task {
            users = await SavedAccountManager().getAllUsers()
            let currentUser = UserInformation.shared.getUser()
            guard let myUser = currentUser else {
                return
            }
            
            currentAccount = myUser.id
        }
    }
}

struct SwitchCard : View {
    var user:LoginInfo
    var currentAccount:Bool = false
    var onSignin: (() -> ())
    
    var body: some View {
        HStack(alignment: .center) {
            ImagePlaceHolder(url: user.url, placeHolder: UIImage(named: "defaultPhoto"))
            
            VStack(alignment: .leading) {
                Text(user.name).bold()
                Text("\(user.accountType) at \(user.storeName)")
            }
            
            Spacer()
            Button(currentAccount ? "Current account" : "Sign in") {
                if !currentAccount {
                    onSignin()
                }
            }
        }
        .padding()
    }
}

#Preview {
    SwitchAccountView(show: .constant(true))
}
