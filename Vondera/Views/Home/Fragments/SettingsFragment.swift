//
//  StoreFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI
import NetworkImage
import AlertToast

struct SettingsFragment: View {
    @ObservedObject var myUser = UserInformation.shared
    
    @State var showContactDialog = false
    var customerServiceNumber = "01551542514"
    
    @State var showSavedItems = false
    @State var count = 0
    @State var msg:String?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let myUser = myUser.user {
                VStack {
                    StoreToolbar()
                        .padding()
                    
                    List {
                        // MARK : Header
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                ImagePlaceHolder(url: myUser.userURL, placeHolder: UIImage(named: "defaultPhoto"), reduis: 60)
                                .overlay(alignment: .bottomTrailing, content: {
                                    ImagePlaceHolder(url: myUser.store?.logo ?? "", placeHolder: UIImage(named: "app_icon"), reduis: 30)
                                })
                                
                                VStack(alignment: .leading) {
                                    Text(myUser.name)
                                        .font(.title3)
                                        .bold()
                                    
                                    Text("\(myUser.getAccountTypeString().toString()) at \(myUser.store?.name ?? "")")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("@\(myUser.store?.merchantId ?? "")")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .onTapGesture {
                                            msg = "Copied to clipboard"
                                            CopyingData().copyToClipboard(myUser.store?.merchantId ?? "")
                                        }
                                }
                                .padding(.horizontal, 12)
                                
                                Spacer()
                            }
                            
                            if myUser.accountType == "Owner", let store = myUser.store {
                                PlanCard(store: store)
                            }
                        }
                        
                        if myUser.accountType == "Owner" {
                            Section("Store Settings") {
                                NavigationLink("Subscriptions", destination: SubscribtionsView())
                                    .bold()
                                
                                NavigationLink("Store Info", destination: StoreInfoView(store: myUser.store!))
                                    .bold()
                                
                                
                                if let amount = myUser.store?.agelWallet, amount > 500 {
                                    NavigationLink {
                                        AgelWallet()
                                    } label: {
                                        HStack {
                                            Text("Agel Wallet")
                                            Spacer()
                                            Text("EGP \(myUser.store?.agelWallet ?? 0)")
                                        }
                                        .bold()
                                    }
                                }
                                

                                
                                /*NavigationLink("Reffer Program", destination: RefferView(user:viewModel.user!))
                                    .bold()*/
                            }
                        }
                        
                        Section("Account Settings") {
                            NavigationLink("Edit my info", destination: EditInfoView(user: myUser))
                                .bold()
                            
                            NavigationLink("Change Password", destination: ChangePasswordView(user: myUser))
                                .bold()
                            
                            NavigationLink("Change Phone", destination: ChangePhoneView())
                                .bold()
                            
                            NavigationLink("Connect to social media", destination: ConnectSocialView())
                                .bold()
                        }
                        
                        Section("App Settings") {
                            NavigationLink("Notification Settings", destination: NotificationsSettingsView())
                                .bold()
                            
                            NavigationLink("App Language", destination: AppLanguage())
                                .bold()
                            
                            NavigationLink("About app", destination: AboutAppView())
                                .bold()
                        
                            
                            Button("Contact customer service") {
                               showContactDialog.toggle()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .bold()
                            
                            Button("Privacy Policy") {
                                let url = "https://www.vondera.app/privacy-policy"
                                if let Url = URL(string: url) {
                                    UIApplication.shared.open(Url)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .bold()
                            
                            Button("Terms & Conditions") {
                                let url = "https://www.vondera.app/terms-conditions"
                                if let Url = URL(string: url) {
                                    UIApplication.shared.open(Url)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .bold()
                        }
                        
                        Section ("Login Settings") {
                            // SWITCH accounts button
                            if count > 0 {
                                Button("Switch Account") {
                                    withAnimation {
                                        showSavedItems.toggle()
                                    }
                                }
                                .foregroundStyle(Color.accentColor)
                            }
                            
                            Button(role: .destructive) {
                                Task {
                                    await AuthManger().logOut()
                                }
                            } label: {
                                Text("Log Out")
                            }                            
                        }
                    }
                    .backgroundStyle(.secondary)
                    .listStyle(.plain)
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
            SwitchAccountView(show: $showSavedItems)
        })
        .toast(isPresenting: Binding(value: $msg), alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        })
        .navigationTitle("Settings")
        
    }
}

#Preview {
    SettingsFragment()
}
