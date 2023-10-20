//
//  StoreFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import NetworkImage

struct SettingsFragment: View {
    @ObservedObject var myUser = UserInformation.shared
    
    @State var showContactDialog = false
    var customerServiceNumber = "01551542514"
    
    @State var showSavedItems = false
    @State var count = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            if let myUser = myUser.user {
                VStack {
                    StoreToolbar(myUser: myUser)
                        .padding()
                    
                    List {
                        // MARK : Header
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                ZStack {
                                    NetworkImage(url: URL(string: myUser.userURL)) { image in
                                      image.centerCropped()
                                    } placeholder: {
                                      ProgressView()
                                    } fallback: {
                                        Image("defaultPhoto")
                                            .resizable()
                                            .centerCropped()
                                    }
                                    .background(Color.gray)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                }
                                .overlay(alignment: .bottomTrailing, content: {
                                    NetworkImage(url: URL(string: myUser.store?.logo ?? "" )) { image in
                                        image.centerCropped()
                                    } placeholder: {
                                        ProgressView()
                                    } fallback: {
                                        Image("app_icon")
                                            .resizable()
                                            .centerCropped()
                                    }
                                    .background(Color.yellow)
                                    .frame(width: 30, height: 30, alignment: .bottomTrailing)
                                    .clipShape(Circle())
                                })
                                
                                
                                VStack(alignment: .leading) {
                                    Text(myUser.name)
                                        .font(.title.bold())
                                        .foregroundColor(.accentColor)
                                    
                                    Text("\(myUser.getAccountTypeString()) at \(myUser.store?.name ?? "")")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                
                                Spacer()
                            }
                            
                            if myUser.accountType == "Owner" {
                                if let store = myUser.store {
                                    PlanCard(store: store)
                                }
                            }
                        }
                        
                        if myUser.accountType == "Owner" {
                            Section("Store Settings") {
                                NavigationLink("Subscriptions", destination: SubscribtionsView())
                                    .bold()
                                
                                NavigationLink("Store Info", destination: StoreInfoView(store: myUser.store!))
                                    .bold()
                                
                                /*
                                NavigationLink {
                                    AgelWallet(myUser: viewModel.user)
                                } label: {
                                    HStack {
                                        Text("Agel Wallet")
                                        Spacer()
                                        Text("EGP \(viewModel.user?.store?.agelWallet ?? 0)")
                                    }
                                    .bold()
                                }*/

                                
                                /*NavigationLink("Reffer Program", destination: RefferView(user:viewModel.user!))
                                    .bold()*/
                            }
                        }
                        
                        Section("Account Settings") {
                            NavigationLink("My Orders", destination: UserOrders(id: myUser.id, storeId: myUser.storeId))
                                .bold()
                            
                            NavigationLink("Edit my info", destination: EditInfoView(user: myUser))
                                .bold()
                            
                            
                            NavigationLink("Change Password", destination: ChangePasswordView(user: myUser))
                                .bold()
                            
                            NavigationLink("Change Phone", destination: ChangePhoneView())
                                .bold()
                            
                            /*NavigationLink("Connect to social media", destination: ConnectSocialView())
                                .bold()*/
                        }
                        
                        Section("App Settings") {
                            NavigationLink("Notification Settings", destination: NotificationsSettingsView())
                                .bold()
                            
                            /*NavigationLink("App Language", destination: Text("App Language"))
                                .bold()
                                .isHidden(true)*/
                            
                            Button("Privacy Policy") {
                                let url = "https://vondera.app/policy.html"
                                if let Url = URL(string: url) {
                                    UIApplication.shared.open(Url)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .bold()
                            
                            Button("Terms & Condtions") {
                                let url = "https://vondera.app/terms.html"
                                if let Url = URL(string: url) {
                                    UIApplication.shared.open(Url)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            .bold()
                            
                            NavigationLink("About app", destination: AboutAppView())
                                .bold()
                        
                            
                            Button("Contact customer service") {
                               showContactDialog.toggle()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .bold()
                        }
                        
                        Section () {
                            Button(role: .destructive) {
                                Task {
                                    await AuthManger().logOut()
                                }
                            } label: {
                                Text("Log Out")
                            }
                            
                            // SWITCH accounts button
                            if count > 0 {
                                Button("Switch Account") {
                                    withAnimation {
                                        showSavedItems.toggle()
                                    }
                                }
                            }
                        }
                        
                    }
                }
            } else {
                ProgressView()
            }
        }
        .refreshable {
            if let user = try? await UsersDao().getUserWithStore(userId: myUser.user?.id ?? "") {
                UserInformation.shared.updateUser(user)
            }
        }
        .task {
            count = SavedAccountManager().getAllUsers().count
        }
        .sheet(isPresented: $showContactDialog) {
            ContactDialog(phone:customerServiceNumber, toggle: $showContactDialog)
        }
        .sheet(isPresented: $showSavedItems, content: {
            NavigationStack {
                SwitchAccountView(show: $showSavedItems)
                    .presentationDetents([.fraction(0.3)])
            }
        })
        .navigationTitle("Settings")
        
    }
}

#Preview {
    SettingsFragment()
}
